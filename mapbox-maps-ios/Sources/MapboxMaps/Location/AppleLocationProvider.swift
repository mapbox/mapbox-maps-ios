import UIKit
import Foundation

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

/// A location provider based on CoreLocation's `CLLocationManager`
public final class AppleLocationProvider: LocationProvider {

    public struct Options: Equatable {
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

    public var options: Options = Options() {
        didSet {
            locationManager.distanceFilter = options.distanceFilter
            locationManager.desiredAccuracy = options.desiredAccuracy
            locationManager.activityType = options.activityType
        }
    }

    public weak var delegate: AppleLocationProviderDelegate?

    /// Represents the latest location received from the location provider.
    public var latestLocation: Location? {
        return latestCLLocation.map {
            Location(
                location: $0,
                heading: latestHeading,
                accuracyAuthorization: latestAccuracyAuthorization)
        }
    }

    private var latestCLLocation: CLLocation? {
        didSet { notifyConsumers() }
    }

    private var latestHeading: CLHeading? {
        didSet { notifyConsumers() }
    }

    private var latestAccuracyAuthorization: CLAccuracyAuthorization {
        didSet {
            if latestAccuracyAuthorization != oldValue {
                delegate?.appleLocationProvider(self, didChangeAccuracyAuthorization: latestAccuracyAuthorization)
            }
            notifyConsumers()
        }
    }

    private let _consumers = WeakSet<LocationConsumer>()

    private var isUpdating = false {
        didSet {
            guard isUpdating != oldValue else {
                return
            }
            if isUpdating {
                /// Get permissions if needed
                if mayRequestWhenInUseAuthorization,
                   locationManager.compatibleAuthorizationStatus == .notDetermined {
                    locationManager.requestWhenInUseAuthorization()
                }
                locationManager.startUpdatingLocation()
                locationManager.startUpdatingHeading()
                updateHeadingOrientationIfNeeded(interfaceOrientationProvider.interfaceOrientation)
                interfaceOrientationProvider.onInterfaceOrientationChange.observe { [weak self] newOrientation in
                    self?.updateHeadingOrientationIfNeeded(newOrientation)
                }.store(in: &cancellables)
            } else {
                locationManager.stopUpdatingLocation()
                locationManager.stopUpdatingHeading()
                cancellables.removeAll()
            }
        }
    }

    private let locationManager: CLLocationManagerProtocol
    internal let interfaceOrientationProvider: InterfaceOrientationProvider
    internal let locationManagerDelegateProxy: CLLocationManagerDelegateProxy
    private let mayRequestWhenInUseAuthorization: Bool
    // cache heading orientation for performance reasons,
    // as this property is going to be accessed fairly regularly
    private var headingOrientation: CLDeviceOrientation {
        didSet { locationManager.headingOrientation = headingOrientation }
    }
    private var cancellables = Set<AnyCancelable>()

    /// Initializes the built-in location provider. The required view will be used to obtain user interface orientation
    /// for correct heading calculation.
    /// - Parameter userInterfaceOrientationViewProvider: The view used to get the user interface orientation from.
    public convenience init(userInterfaceOrientationViewProvider: @escaping () -> UIView?) {
        let orientationProvider = DefaultInterfaceOrientationProvider(
            userInterfaceOrientationView: Ref(userInterfaceOrientationViewProvider),
            notificationCenter: NotificationCenter.default,
            device: UIDevice.current)

        self.init(locationManager: CLLocationManager(),
                  interfaceOrientationProvider: orientationProvider,
                  mayRequestWhenInUseAuthorization: Bundle.main.infoDictionary?["NSLocationWhenInUseUsageDescription"] != nil,
                  locationManagerDelegateProxy: CLLocationManagerDelegateProxy())
    }

    /// Initializes the built-in location provider with a custom interface orientation provider
    /// - Parameter interfaceOrientationProvider: The interface orientation provider used for heading calculation.
    @available(iOS, deprecated: 13, message: "Use init() instead")
    public convenience init(interfaceOrientationProvider: InterfaceOrientationProvider) {
        self.init(locationManager: CLLocationManager(),
                  interfaceOrientationProvider: interfaceOrientationProvider,
                  mayRequestWhenInUseAuthorization: Bundle.main.infoDictionary?["NSLocationWhenInUseUsageDescription"] != nil,
                  locationManagerDelegateProxy: CLLocationManagerDelegateProxy())
    }

    internal init(locationManager: CLLocationManagerProtocol,
                  interfaceOrientationProvider: InterfaceOrientationProvider,
                  mayRequestWhenInUseAuthorization: Bool,
                  locationManagerDelegateProxy: CLLocationManagerDelegateProxy) {
        self.locationManager = locationManager
        self.mayRequestWhenInUseAuthorization = mayRequestWhenInUseAuthorization
        self.latestAccuracyAuthorization = locationManager.compatibleAccuracyAuthorization
        self.interfaceOrientationProvider = interfaceOrientationProvider
        self.headingOrientation = locationManager.headingOrientation
        self.locationManagerDelegateProxy = locationManagerDelegateProxy
        self.locationManager.delegate = locationManagerDelegateProxy

        locationManagerDelegateProxy.delegate = self
    }

    deinit {
        // note that property observers (didSet) don't run during deinit
        if isUpdating {
            locationManager.stopUpdatingLocation()
            locationManager.stopUpdatingHeading()
        }
    }

    /// The location manager holds weak references to consumers, client code should retain these references.
    public func add(consumer: LocationConsumer) {
        _consumers.add(consumer)
        syncIsUpdating()
    }

    /// Removes a location consumer from the location manager.
    public func remove(consumer: LocationConsumer) {
        _consumers.remove(consumer)
        syncIsUpdating()
    }

    @available(iOS 14.0, *)
    public func requestTemporaryFullAccuracyAuthorization(withPurposeKey purposeKey: String) {
        locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: purposeKey)
    }

    // MARK: - Location

    private func updateHeadingOrientationIfNeeded(_ newInterfaceOrientation: UIInterfaceOrientation) {
        let headingOrientation = CLDeviceOrientation(interfaceOrientation: newInterfaceOrientation)

        // Setting this property causes a heading update,
        // so we only set it when it changes to avoid unnecessary work.
        if self.headingOrientation != headingOrientation {
            self.headingOrientation = headingOrientation
        }
    }

    private func notifyConsumers() {
        guard isUpdating else {
            return
        }
        if let latestLocation = latestLocation {
            for consumer in _consumers.allObjects {
                consumer.locationUpdate(newLocation: latestLocation)
            }
        }
    }

    private func syncIsUpdating() {
        // check _consumers.anyObject != nil instead of simply _consumers.count
        // which may still include objects that have been deinited
        isUpdating = (_consumers.anyObject != nil)
    }
}

// At the beginning of each required method, check whether there are still any consumers and if not,
// set `isUpdating` to false and return early. This is necessary to ensure we stop using location
// services when there are no consumers due to the fact that we only keep weak references to them, and
// they may be deinited without ever being explicitly removed.
extension AppleLocationProvider: CLLocationManagerDelegateProxyDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        syncIsUpdating()
        latestCLLocation = locations.last
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        syncIsUpdating()
        latestHeading = newHeading
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        syncIsUpdating()
        Log.error(forMessage: "\(self) did fail with error: \(error)", category: "Location")
        delegate?.appleLocationProvider(self, didFailWithError: error)
    }

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        syncIsUpdating()
        let accuracyAuthorization = locationManager.compatibleAccuracyAuthorization
        if #available(iOS 14.0, *),
           isUpdating,
           [.authorizedAlways, .authorizedWhenInUse].contains(locationManager.compatibleAuthorizationStatus),
           accuracyAuthorization == .reducedAccuracy {
            locationManager.requestTemporaryFullAccuracyAuthorization(
                withPurposeKey: "LocationAccuracyAuthorizationDescription")
        }
        latestAccuracyAuthorization = accuracyAuthorization
    }

    public func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return delegate?.appleLocationProviderShouldDisplayHeadingCalibration(self) ?? false
    }
}
