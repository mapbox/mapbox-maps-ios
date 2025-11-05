import CoreLocation
import UIKit
@_spi(Experimental) import MapboxCommon
import Combine

/// The data model delivers the raw location and compass updates to the map features.
///
/// Currently the `Puck` (location indicator) and ``Viewport`` are using this data.
public class LocationDataModel {
    /// A publisher that delivers location updates.
    ///
    /// - Important:The publisher must deliver updates on main thread.
    let location: AnyPublisher<[Location], Never>

    /// A publisher that delivers compass heading updates.
    ///
    /// Optional, if you don't need Viewport and Puck to use the compass (heading) data, see ``PuckBearing``.
    ///
    /// The heading values should not be adjusted to to the user interface orientation. The ``LocationManager`` adjusts the user interface orientation internally.
    /// If you use `CLLocationManager` as heading source, don't update the `headingOrientation` property.
    ///
    /// - Important: The publisher must deliver updates on main thread.
    let heading: AnyPublisher<Heading, Never>?

    /// Creates the model.
    ///
    /// - Important: The publisher must deliver updates on main thread.
    ///
    /// - Parameters:
    ///   - location: A publisher that delivers location updates.
    ///   - heading: A publisher that delivers heading updates.
    public init (location: AnyPublisher<[Location], Never>,
                 heading: AnyPublisher<Heading, Never>? = nil) {
        self.location = location
        self.heading = heading
    }

    /// Creates the default location data model.
    ///
    /// It uses ``AppleLocationProvider`` internally and automatically requests the location permissions upon first location indicator render request.
    ///
    /// - Parameters:
    ///   - options: The options of the location provider.
    /// - Returns: Location data model.
    static public func createDefault(_ options: AppleLocationProvider.Options? = nil) -> LocationDataModel {
        let provider = AppleLocationProvider()
        if let options {
            provider.options = options
        }
        return LocationDataModel(
            location: provider.onLocationUpdate.retaining(provider).eraseToAnyPublisher(),
            heading: provider.onHeadingUpdate.retaining(provider).eraseToAnyPublisher()
        )
    }

    /// Creates the default location driven by the MapboxCommon implementation.
    ///
    /// This variant uses implementation from ``LocationServiceFactory`` found in MapboxCommon.
    ///
    /// The core location model has some difference:
    /// - It doesn't automatically asks user permissions. You control when to ask user for the location permission.
    /// - It works with `CLLocationManager` on background thread.
    /// - The underlying `CLLocationManager` will be shared with Mapbox Navigation SDK if you use it.
    ///
    /// - Important: When using this option, request the location permissions manually.
    ///
    /// - Returns: Location data model.
    @_spi(Experimental)
    @_documentation(visibility: public)
    static public func createCore() -> LocationDataModel {
        let location = LocationServiceFactory.createDefaultLocationPublisher()
        let heading = LocationServiceFactory.createDefaultHeadingPublisher()

        return LocationDataModel(
            location: location.receive(on: DispatchQueue.main).eraseToAnyPublisher(),
            heading: heading.receive(on: DispatchQueue.main).eraseToAnyPublisher())
    }
}

/// An object responsible for managing user location indicator(Puck).
public final class LocationManager {
    /// A stream of location change events that drive the puck.
    public var onLocationChange: Signal<[Location]> { onLocationChangeProxy.signal }

    /// A stream of heading update events that drive the puck.
    ///
    /// Heading is used when puck uses ``PuckBearing/heading`` as a bearing type.
    public var onHeadingChange: Signal<Heading> { onHeadingChangeProxy.signal }

    /// A stream of puck render events.
    ///
    /// A subscriber will get the accurate (interpolated) data used to render puck,
    /// as opposed to the ``onLocationChange`` and ``onHeadingChange`` that emit non-interpolated source data.
    ///
    /// Observe this stream to adjust any elements that connected the actual puck position, such as route line, annotations, camera position,
    /// or you can render a custom puck.
    public let onPuckRender: Signal<PuckRenderingData>

    /// Configuration options for the location manager.
    public var options: LocationOptions {
        get { puckManager.locationOptions }
        set { puckManager.locationOptions = newValue }
    }

    /// Location data model.
    ///
    /// Use this property to access or override the raw location and heading data used by the map.
    ///
    /// - Important: When overriding the data model, make sure the data is delivered on main thread.
    public var dataModel: LocationDataModel {
        didSet {
            if self.dataModel !== oldValue {
                self.updateDataModel()
            }
        }
    }

    /// Sets the custom providers that supply puck with the location data.
    ///
    /// - Parameters:
    ///   - locationProvider: Signal that drives puck location.
    ///   - headingProvider: Signal that drives the puck's bearing when it's configured as ``PuckBearing/heading``.
    @available(*, deprecated, message: "Use dataModel instead")
    public func override(
        locationProvider: Signal<[Location]>,
        headingProvider: Signal<Heading>? = nil
    ) {
        self.dataModel = LocationDataModel(
            location: locationProvider.eraseToAnyPublisher(),
            heading: headingProvider?.eraseToAnyPublisher())
    }

    /// Sets the custom providers that supply puck with the location data.
    ///
    /// - Parameters:
    ///   - locationProvider: Provider that drives puck location.
    ///   - headingProvider: Provider that drives the puck's bearing when it's configured as ``PuckBearing/heading``.
    @available(*, deprecated, message: "Use dataModel instead")
    public func override(
        locationProvider: LocationProvider,
        headingProvider: HeadingProvider? = nil
    ) {
        self.override(locationProvider: locationProvider.toSignal(), headingProvider: headingProvider?.toSignal())
    }

    /// Sets the custom provider that supply puck with the location and heading data.
    ///
    /// - Note: On visionOS, the ``AppleLocationProvider`` doesn't implement ``HeadingProvider``.
    /// If you are using a custom instance of a location provider, override it using the ``LocationManager/override(locationProvider:headingProvider:)-8xcsf`` .
    ///
    /// - Parameters:
    ///   - provider: An object that provides both location and heading data, such as ``AppleLocationProvider``.
    @available(*, deprecated, message: "Use dataModel instead")
    public func override(provider: LocationProvider & HeadingProvider) {
        self.override(locationProvider: provider, headingProvider: provider)
    }

    private let onLocationChangeProxy = CurrentValueSignalProxy<[Location]>()
    private let onHeadingChangeProxy = CurrentValueSignalProxy<Heading>()
    private let puckAnimator: ValueAnimator<PuckRenderingData?>
    private let puckManager: PuckManager<Puck2DRenderer, Puck3DRenderer>

#if !os(visionOS)
    private let orientationProvider = DefaultInterfaceOrientationProvider()
#endif

    init(
        interfaceOrientationView: Ref<UIView?>,
        styleManager: StyleProtocol,
        mapboxMap: MapboxMapProtocol,
        displayLink: Signal<Void>,
        dataModel: LocationDataModel,
        nowTimestamp: Ref<Date>
    ) {
        self.dataModel = dataModel

#if !os(visionOS)
        self.orientationProvider.view = interfaceOrientationView
#endif

        let tracedDisplayLink = displayLink
            .tracingInterval(SignpostName.mapViewDisplayLink, "Participant: LocationManager")

        let locationInterpolator = LocationInterpolator()

        puckAnimator = ValueAnimator(
            ValueInterpolator(
                duration: 1.1,
                input: onLocationChangeProxy.signal,
                interpolate: locationInterpolator.interpolate(from:to:fraction:),
                nowTimestamp: nowTimestamp),
            ValueInterpolator(
                duration: 0.3,
                input: onHeadingChangeProxy.signal,
                interpolate: interpolateHeading(from:to:fraction:),
                nowTimestamp: nowTimestamp),
            trigger: tracedDisplayLink,
            reduce: PuckRenderingData.init(locations:heading:)
        )

        onPuckRender = puckAnimator.output.skipNil().skipRepeats()

        puckManager = PuckManager(
            locationOptionsSubject: CurrentValueSignalSubject(LocationOptions()),
            onPuckRender: onPuckRender,
            make2DRenderer: {
                Puck2DRenderer(
                    style: styleManager,
                    mapboxMap: mapboxMap,
                    displayLink: displayLink,
                    timeProvider: DefaultTimeProvider())
            },
            make3DRenderer: {
                Puck3DRenderer(style: styleManager)
            }
        )

        self.updateDataModel()
    }

    private func updateDataModel() {
        onLocationChangeProxy.proxied = dataModel.location.eraseToSignal()

#if !os(visionOS)
        if let heading = dataModel.heading {
            onHeadingChangeProxy.proxied = Signal
                .combineLatest(
                    heading.eraseToSignal(),
                    orientationProvider.onInterfaceOrientationChange
                )
                .map { heading, orientation in
                    assert(Thread.isMainThread)
                    return adjust(heading: heading, toViewOrientation: orientation)
                }
        } else {
            onHeadingChangeProxy.proxied = nil
        }
#endif
    }

    /// Represents the latest location received from the location provider.
    ///
    /// - Note: The value is lazy and gets updated only when there is at least one consumer of location data,
    /// such as visible location puck or ``LocationManager/onLocationChange`` observer.
    ///
    /// In general, if you need to know the user location it's recommended to observe
    /// the ``LocationManager/onLocationChange`` instead.
    public var latestLocation: Location? {
        onLocationChange.latestValue?.last
    }

    /// Sets the custom providers that supply the map with the location data.
    @available(*, unavailable, message: "Use override(provider:) instead")
    public func overrideLocationProvider(with customLocationProvider: LocationProvider) {}

    /// The location manager holds weak references to consumers, client code should retain these references.
    @available(*, unavailable, message: "Use onLocationChange")
    public func addLocationConsumer(_ consumer: Void) {}

    /// Removes a location consumer from the location manager.
    @available(*, unavailable, message: "Use onLocationChange")
    public func removeLocationConsumer(_ consumer: Void) {}

    /// Adds  a puck location consumer to the location manager.
    @available(*, unavailable, message: "Use onPuckRender")
    public func addPuckLocationConsumer(_ consumer: Void) {}

    /// Removes a  puck location consumer from the location manager.
    @available(*, unavailable, message: "Use onPuckRender")
    public func removePuckLocationConsumer(_ consumer: Void) {}

    /// Allows a custom case to request full accuracy
    @available(*, unavailable, message: "Use AppleLocationProvider.requestTemporaryFullAccuracyAuthorization(withPurposeKey:) instead")
    public func requestTemporaryFullAccuracyPermissions(withPurposeKey purposeKey: String) { fatalError() }

    /// The object that acts as the delegate of the location manager.
    @available(*, unavailable, message: "Use AppleLocationProvider.delegate instead")
    public weak var delegate: LocationPermissionsDelegate? { nil }

    /// The current location provider.
    /// Use this property to override the default (CoreLocation based) location provider with the supplied one.
    @available(*, unavailable, message: "Use onLocationChange instead")
    public var locationProvider: LocationProvider? { nil }
}

func adjust(heading: Heading, toViewOrientation orientation: UIInterfaceOrientation?) -> Heading {
    guard let orientation else { return heading }

    let adjustment: CLLocationDirection = switch orientation {
    case .portrait: 0
    case .portraitUpsideDown: 180
    case .landscapeLeft: 90 // home button on the right side
    case .landscapeRight: -90 // home button on the left side
    case .unknown: 0
    @unknown default: 0
    }

    var heading = heading
    heading.direction += adjustment
    heading.direction = heading.direction.wrapped(to: 0..<360)
    return heading
}
