import CoreLocation
import UIKit

/// An object responsible for notifying the map view about location-related events,
/// such as a change in the device’s location.
public final class LocationManager {

    /// Represents the latest location received from the location provider.
    @available(*, deprecated, message: "Use LocationProvider.latestLocation instead")
    public var latestLocation: Location? {
        return locationProvider.latestLocation
    }

    /// The object that acts as the delegate of the location manager.
    @available(*, unavailable, message: "Use AppleLocationProvider.delegate instead")
    public weak var delegate: LocationPermissionsDelegate? { nil }

    /// Configuration options for the location manager.
    public var options = LocationOptions() {
        didSet {
            syncOptions()
        }
    }

    /// The current location provider.
    /// Use this property to override the default(CoreLocation based) location provider with the supplied one.
    public var provider: LocationProvider {
        didSet {
            interpolatedLocationProducer.locationProvider = provider
        }
    }

    /// The current location provider.
    /// Use this property to override the default(CoreLocation based) location provider with the supplied one.
    @available(*, deprecated, renamed: "provider")
    public var locationProvider: LocationProvider {
        get { provider }
        set { provider = newValue }
    }

    private let interpolatedLocationProducer: InterpolatedLocationProducerProtocol

    /// Manager that handles the visual puck element.
    /// Only created if `showsUserLocation` is `true`.
    private let puckManager: PuckManagerProtocol
    private weak var userInterfaceOrientationView: UIView?

    internal init(locationProvider: LocationProvider,
                  interpolatedLocationProducer: InterpolatedLocationProducerProtocol,
                  puckManager: PuckManagerProtocol,
                  userInterfaceOrientationView: UIView) {
        self.provider = locationProvider
        self.interpolatedLocationProducer = interpolatedLocationProducer
        self.puckManager = puckManager
        self.userInterfaceOrientationView = userInterfaceOrientationView
        syncOptions()
    }

    ///
    /// - Parameter customLocationProvider: The location provider to be used for location-related things.
    @available(*, deprecated, renamed: "provider")
    public func overrideLocationProvider(with customLocationProvider: LocationProvider) {
        provider = customLocationProvider
    }

    /// The location manager holds weak references to consumers, client code should retain these references.
    @available(*, deprecated, message: "Use LocationProvider.add(consumer:) directly")
    public func addLocationConsumer(_ consumer: LocationConsumer) {
        provider.add(consumer: consumer)
    }

    /// Removes a location consumer from the location manager.
    @available(*, deprecated, message: "Use LocationProvider.remove(consumer:) directly")
    public func removeLocationConsumer(_ consumer: LocationConsumer) {
        provider.remove(consumer: consumer)
    }

    /// Adds ``PuckLocationConsumer`` to the location manager.
    ///
    /// An instance of ``PuckLocationConsumer`` will get the accurate (interpolated) location of the puck as it moves,
    /// as opposed to the ``LocationConsumer`` that gets updated only when the ``LocationProvider`` has emitted a new location.
    /// - Important: The location manager holds a weak reference to the consumer, thus client should retain these references.
    public func addPuckLocationConsumer(_ consumer: PuckLocationConsumer) {
        interpolatedLocationProducer.addPuckLocationConsumer(consumer)
    }

    /// Removes a ``PuckLocationConsumer`` from the location manager.
    public func removePuckLocationConsumer(_ consumer: PuckLocationConsumer) {
        interpolatedLocationProducer.removePuckLocationConsumer(consumer)
    }

    /// Allows a custom case to request full accuracy
    @available(*, unavailable, message: "Use AppleLocationProvider.requestTemporaryFullAccuracyAuthorization(withPurposeKey:) instead")
    public func requestTemporaryFullAccuracyPermissions(withPurposeKey purposeKey: String) { fatalError() }

    private func syncOptions() {
        puckManager.puckType = options.puckType
        puckManager.puckBearing = options.puckBearing
        puckManager.puckBearingEnabled = options.puckBearingEnabled

        interpolatedLocationProducer.isEnabled = options.puckType != nil
    }
}
