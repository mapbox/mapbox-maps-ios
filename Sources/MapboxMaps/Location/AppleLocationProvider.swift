import UIKit
import Foundation
import MapboxCommon

/// The ``AppleLocationProviderDelegate`` protocol defines a set of optional methods that you
/// can use to receive events from an associated location provider object.
public protocol AppleLocationProviderDelegate: AnyObject {

    /// Tells the delegate that an attempt to locate the user’s position failed.
    /// - Parameters:
    ///   - locationProvider: The location provider that is tracking the user’s location.
    ///   - error: An error object containing the reason why location tracking failed.
    func appleLocationProvider(_ locationProvider: AppleLocationProvider, didFailWithError error: Error)

    /// Tells the delegate that the accuracy authorization has changed.
    /// - Parameters:
    ///   - locationProvider: The location provider that is tracking the user’s location.
    ///   - accuracyAuthorization: The updated accuracy authorization value.
    func appleLocationProvider(_ locationProvider: AppleLocationProvider,
                               didChangeAccuracyAuthorization accuracyAuthorization: CLAccuracyAuthorization)

    /// Asks the delegate whether the heading calibration alert should be displayed.
    /// - Parameter locationProvider: The location provider object coordinating the display of the heading calibration alert.
    /// - Returns: `true` if you want to allow the heading calibration alert to be displayed; `false` if you do not.
    func appleLocationProviderShouldDisplayHeadingCalibration(_ locationProvider: AppleLocationProvider) -> Bool
}

/// A location provider based on CoreLocation's `CLLocationManager`.
public final class AppleLocationProvider {

    public struct Options: Equatable, Sendable {
        /// Specifies the minimum distance (measured in meters) a device must move horizontally
        /// before a location update is generated.
        ///
        /// The default value of this property is `kCLDistanceFilterNone`.
        public var distanceFilter: CLLocationDistance

        /// Specifies the accuracy of the location data.
        ///
        /// The default value is `kCLLocationAccuracyBest`.
        public var desiredAccuracy: CLLocationAccuracy

        /// Sets the type of user activity associated with the location updates.
        ///
        /// The default value is `CLActivityType.other`.
        public var activityType: CLActivityType

        /// Initializes provider options.
        /// - Parameters:
        ///   - distanceFilter: Specifies the minimum distance (measured in meters) a device must move horizontally
        /// before a location update is generated.
        ///   - desiredAccuracy: Specifies the accuracy of the location data.
        ///   - activityType: Sets the type of user activity associated with the location.
        public init(
            distanceFilter: CLLocationDistance = kCLDistanceFilterNone,
            desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest,
            activityType: CLActivityType = .other
        ) {
            self.distanceFilter = distanceFilter
            self.desiredAccuracy = desiredAccuracy
            self.activityType = activityType
        }
    }

    /// Location manager options.
    public var options: Options = Options() {
        didSet {
            locationManager.distanceFilter = options.distanceFilter
            locationManager.desiredAccuracy = options.desiredAccuracy
            locationManager.activityType = options.activityType
        }
    }

    /// A delegate of location provider.
    public weak var delegate: AppleLocationProviderDelegate?

    /// A stream of location updates.
    ///
    /// An observer will receive a cached value (if any) upon subscription.
    ///
    /// - Note: When the first observer is added, the underlying `CLLocationManager` instance will
    /// ask for permissions (if needed) and start to produce the location updates. When the last observer is gone it will stop.
    public var onLocationUpdate: Signal<[Location]> { locationSubject.signal.skipNil() }

    /// A stream of heading (compass) updates.
    ///
    /// An observer will receive a cached value (if any) upon subscription.
    ///
    /// - Note: When the first observer is added, the underlying `CLLocationManager` instance will
    /// start to produce the heading updates. When the last observer is gone, it will stop.
#if swift(>=5.9)
    @available(visionOS, unavailable)
#endif
    public var onHeadingUpdate: Signal<Heading> {
#if !(swift(>=5.9) && os(visionOS))
        headingSubject.signal.skipNil()
#else
        fatalError()
#endif
}

    /// A latest known location.
    ///
    /// - Note: The location updates only when there is at least one observer of location updates.
    /// In general, it's recommended to observe the location via ``AppleLocationProvider/onLocationUpdate``.
    public var latestLocation: Location? { locationSubject.value?.last }

    private let locationSubject = CurrentValueSignalSubject<[Location]?>()
    private lazy var locationObservingAdapter = SignalObservingAdapter(signal: onLocationUpdate, notify: notifyLocationObserver(_:_:))

#if !(swift(>=5.9) && os(visionOS))
    private let headingSubject = CurrentValueSignalSubject<Heading?>()
    private lazy var headingObservingAdapter = SignalObservingAdapter(signal: onHeadingUpdate, notify: notifyHeadingObserver(_:_:))
#endif

    private var latestLocationAndAccuracyAuth: ([CLLocation], CLAccuracyAuthorization) {
        didSet {
            if latestLocationAndAccuracyAuth.1 != oldValue.1 {
                delegate?.appleLocationProvider(self, didChangeAccuracyAuthorization: latestLocationAndAccuracyAuth.1)
            }

            let (locations, accuracyAuth) = latestLocationAndAccuracyAuth
            if !locations.isEmpty {
                locationSubject.value = locations.map {
                    Location(clLocation: $0, extra: Location.makeExtra(for: accuracyAuth))
                }
            }
        }
    }

    private var isLocationUpdating = false {
        didSet {
            if isLocationUpdating {
                /// Get permissions if needed
                if mayRequestWhenInUseAuthorization,
                   locationManager.authorizationStatus == .notDetermined {
                    locationManager.requestWhenInUseAuthorization()
                }
                locationManager.startUpdatingLocation()
            } else {
                locationManager.stopUpdatingLocation()
            }
        }
    }

#if !(swift(>=5.9) && os(visionOS))
    private var isHeadingUpdating = false {
        didSet {
            if isHeadingUpdating {
                locationManager.startUpdatingHeading()
                orientationChangeToken = interfaceOrientation.observe { [weak self] newOrientation in
                    self?.updateHeadingOrientationIfNeeded(newOrientation)
                }
            } else {
                locationManager.stopUpdatingHeading()
                orientationChangeToken = nil
            }
        }
    }
#endif

    private let locationManager: CLLocationManagerProtocol
    internal let interfaceOrientation: Signal<UIInterfaceOrientation>
    internal let locationManagerDelegateProxy: CLLocationManagerDelegateProxy
    private let mayRequestWhenInUseAuthorization: Bool

#if !(swift(>=5.9) && os(visionOS))
    // cache heading orientation for performance reasons,
    // as this property is going to be accessed fairly regularly
    private var headingOrientation: CLDeviceOrientation {
        didSet { locationManager.headingOrientation = headingOrientation }
    }

    private var orientationChangeToken: AnyCancelable?
    var orientationProvider: DefaultInterfaceOrientationProvider?
#endif

    /// Initializes the built-in location provider.
    public convenience init() {
#if swift(>=5.9) && os(visionOS)
        let interfaceOrientation = Signal(just: UIInterfaceOrientation.unknown)
#else
        let orientationProvider = DefaultInterfaceOrientationProvider(
            notificationCenter: NotificationCenter.default,
            device: UIDevice.current)
        let interfaceOrientation = orientationProvider.onInterfaceOrientationChange
#endif

        self.init(locationManager: CLLocationManager(),
                  interfaceOrientation: interfaceOrientation,
                  mayRequestWhenInUseAuthorization: Bundle.main.infoDictionary?["NSLocationWhenInUseUsageDescription"] != nil,
                  locationManagerDelegateProxy: CLLocationManagerDelegateProxy())

#if !(swift(>=5.9) && os(visionOS))
        self.orientationProvider = orientationProvider
#endif
    }

    internal init(locationManager: CLLocationManagerProtocol,
                  interfaceOrientation: Signal<UIInterfaceOrientation>,
                  mayRequestWhenInUseAuthorization: Bool,
                  locationManagerDelegateProxy: CLLocationManagerDelegateProxy) {
        self.locationManager = locationManager
        self.mayRequestWhenInUseAuthorization = mayRequestWhenInUseAuthorization
        self.latestLocationAndAccuracyAuth = ([], locationManager.accuracyAuthorization)
        self.interfaceOrientation = interfaceOrientation
#if !(swift(>=5.9) && os(visionOS))
        self.headingOrientation = locationManager.headingOrientation
#endif
        self.locationManagerDelegateProxy = locationManagerDelegateProxy
        self.locationManager.delegate = locationManagerDelegateProxy

        locationSubject.onObserved = { [weak self] in self?.isLocationUpdating = $0 }
#if !(swift(>=5.9) && os(visionOS))
        headingSubject.onObserved = { [weak self] in self?.isHeadingUpdating = $0 }
#endif
        locationManagerDelegateProxy.delegate = self
    }

    deinit {
        // note that property observers (didSet) don't run during deinit
        if isLocationUpdating {
            locationManager.stopUpdatingLocation()
        }
#if !(swift(>=5.9) && os(visionOS))
        if isHeadingUpdating {
            locationManager.stopUpdatingHeading()
        }
#endif
    }

    /// Requests permission to temporarily use location services with full accuracy.
    public func requestTemporaryFullAccuracyAuthorization(withPurposeKey purposeKey: String) {
        locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: purposeKey)
    }

    // MARK: - Location

#if !(swift(>=5.9) && os(visionOS))
    private func updateHeadingOrientationIfNeeded(_ newInterfaceOrientation: UIInterfaceOrientation) {
        let headingOrientation = CLDeviceOrientation(interfaceOrientation: newInterfaceOrientation)

        // Setting this property causes a heading update,
        // so we only set it when it changes to avoid unnecessary work.
        if self.headingOrientation != headingOrientation {
            self.headingOrientation = headingOrientation
        }
    }
#endif
}

extension AppleLocationProvider: LocationProvider {
    /// Returns a latest observed location.
    public func getLastObservedLocation() -> Location? {
        latestLocation
    }

    /// Adds a location observer.
    ///
    /// The observer will receive a cached value upon subscription.
    ///
    /// - Note: When the first observer is added, the underlying `CLLocationManager` instance will
    /// ask for permissions (if needed) and start to produce the location updates.
    public func addLocationObserver(for observer: LocationObserver) {
        locationObservingAdapter.add(observer: observer)
    }

    /// Removes the location observer
    ///
    /// When the last observer is gone, the underlying `CLLocationManager` it will stop location updates.
    public func removeLocationObserver(for observer: LocationObserver) {
        locationObservingAdapter.remove(observer: observer)
    }
}

#if swift(>=5.9)
    @available(visionOS, unavailable)
#endif
extension AppleLocationProvider: HeadingProvider {
    /// A latest known heading.
    ///
    /// - Note: The heading updates only when there is at least one observer of heading updates.
#if swift(>=5.9)
    @available(visionOS, unavailable)
#endif
    public var latestHeading: Heading? {
#if swift(>=5.9) && os(visionOS)
        fatalError()
#else
        headingSubject.value
#endif
    }

    /// Adds a heading updates observer.
    ///
    /// An observer will receive a cached value (if any) upon subscription.
    ///
    /// - Note: When the first observer is added, the underlying `CLLocationManager` instance will
    /// start to produce the heading updates.
#if swift(>=5.9)
    @available(visionOS, unavailable)
#endif
    public func add(headingObserver: HeadingObserver) {
#if swift(>=5.9) && os(visionOS)
        fatalError()
#else
        headingObservingAdapter.add(observer: headingObserver)
#endif
    }

    /// Removes heading observer.
    ///
    /// When the last observer is gone, the underlying `CLLocationManager` it will stop heading updates.
#if swift(>=5.9)
    @available(visionOS, unavailable)
#endif
    public func remove(headingObserver: HeadingObserver) {
#if swift(>=5.9) && os(visionOS)
        fatalError()
#else
        headingObservingAdapter.remove(observer: headingObserver)
#endif
    }
}

// At the beginning of each required method, check whether there are still any consumers and if not,
// set `isUpdating` to false and return early. This is necessary to ensure we stop using location
// services when there are no consumers due to the fact that we only keep weak references to them, and
// they may be deinited without ever being explicitly removed.
extension AppleLocationProvider: CLLocationManagerDelegateProxyDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        latestLocationAndAccuracyAuth.0 = locations
    }

#if !(swift(>=5.9) && os(visionOS))
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        headingSubject.value = Heading(from: newHeading)
    }
#endif

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Log.error("\(self) did fail with error: \(error)", category: "Location")
        delegate?.appleLocationProvider(self, didFailWithError: error)
    }

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let accuracyAuthorization = locationManager.accuracyAuthorization
        if isLocationUpdating,
           locationManager.authorizationStatus.isAuthorized,
           accuracyAuthorization == .reducedAccuracy {
            locationManager.requestTemporaryFullAccuracyAuthorization(
                withPurposeKey: "LocationAccuracyAuthorizationDescription")
        }
        latestLocationAndAccuracyAuth.1 = accuracyAuthorization
    }

    public func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return delegate?.appleLocationProviderShouldDisplayHeadingCalibration(self) ?? false
    }
}

private extension CLAuthorizationStatus {
    var isAuthorized: Bool {
        #if swift(>=5.9) && os(visionOS)
        return [.authorizedWhenInUse].contains(self)
        #else
        return [.authorizedAlways, .authorizedWhenInUse].contains(self)
        #endif
    }
}

private func notifyLocationObserver(_ observer: LocationObserver, _ locations: [Location]) {
    observer.onLocationUpdateReceived(for: locations)
}

private func notifyHeadingObserver(_ observer: HeadingObserver, _ heading: Heading) {
    observer.onHeadingUpdate(heading)
}
