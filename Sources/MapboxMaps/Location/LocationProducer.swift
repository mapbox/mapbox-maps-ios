import UIKit
@_implementationOnly import MapboxCommon_Private

internal protocol LocationProducerProtocol: AnyObject {
    var delegate: LocationProducerDelegate? { get set }
    var latestLocation: Location? { get }
    var consumers: NSHashTable<LocationConsumer> { get }
    var locationProvider: LocationProvider { get set }
    func add(_ consumer: LocationConsumer)
    func remove(_ consumer: LocationConsumer)
    func addHeadingConsumer(_ consumer: HeadingConsumer)
    func removeHeadingConsumer(_ consumer: HeadingConsumer)
}

internal protocol LocationProducerDelegate: AnyObject {
    func locationProducer(_ locationProducer: LocationProducerProtocol,
                          didFailWithError error: Error)

    func locationProducer(_ locationProducer: LocationProducerProtocol,
                          didChangeAccuracyAuthorization accuracyAuthorization: CLAccuracyAuthorization)

    func locationProducerShouldDisplayHeadingCalibration(_ locationProducer: LocationProducerProtocol) -> Bool
}

internal final class LocationProducer: LocationProducerProtocol {

    internal weak var delegate: LocationProducerDelegate?

    /// Represents the latest location received from the location provider.
    internal var latestLocation: Location? {
        return latestCLLocation.map {
            Location(
                location: $0,
                heading: latestHeading,
                accuracyAuthorization: latestAccuracyAuthorization)
        }
    }

    private var latestCLLocation: CLLocation? {
        didSet {
            notifyLocationConsumers()
        }
    }

    private var latestHeading: CLHeading? {
        didSet {
            notifyHeadingConsumers()
        }
    }

    private var latestAccuracyAuthorization: CLAccuracyAuthorization {
        didSet {
            if latestAccuracyAuthorization != oldValue {
                delegate?.locationProducer(self, didChangeAccuracyAuthorization: latestAccuracyAuthorization)
            }
            notifyLocationConsumers()
        }
    }

    private let _locationConsumers = NSHashTable<LocationConsumer>.weakObjects()
    private let _headingConsumers = WeakSet<HeadingConsumer>()
    internal var consumers: NSHashTable<LocationConsumer> {
        // swiftlint:disable:next force_cast
        return _locationConsumers.copy() as! NSHashTable<LocationConsumer>
    }

    private var isUpdatingLocation = false {
        didSet {
            guard isUpdatingLocation != oldValue else {
                return
            }
            if isUpdatingLocation {
                /// Get permissions if needed
                if mayRequestWhenInUseAuthorization,
                   locationProvider.authorizationStatus == .notDetermined {
                    locationProvider.requestWhenInUseAuthorization()
                }
                locationProvider.startUpdatingLocation()
            } else {
                locationProvider.stopUpdatingLocation()
            }
        }
    }

    private var isUpdatingHeading = false {
        didSet {
            guard isUpdatingHeading != oldValue else {
                return
            }

            if isUpdatingHeading {
                /// Get permissions if needed
                if mayRequestWhenInUseAuthorization,
                   locationProvider.authorizationStatus == .notDetermined {
                    locationProvider.requestWhenInUseAuthorization()
                }
                locationProvider.startUpdatingHeading()
                updateHeadingOrientationIfNeeded()
                startUpdatingInterfaceOrientation()
            } else {
                locationProvider.stopUpdatingHeading()
                stopUpdatingInterfaceOrientation()
            }
        }
    }

    // TODO: remove this when `LocationProvider` gets constrained to AnyObject
    private var _ignoreLocationProviderUpdate = false
    internal var locationProvider: LocationProvider {
        willSet {
            if _ignoreLocationProviderUpdate { return }
            isUpdatingLocation = false
            // setDelegate doesn't accept nil, so provide
            // an empty delegate implementation to clear
            // out the old locationProvider's reference to
            // self. This helps to ensure that we don't
            // receive any more callbacks from the old
            // locationProvider.
            locationProvider.setDelegate(EmptyLocationProviderDelegate())
        }
        didSet {
            if _ignoreLocationProviderUpdate { return }
            // reinitialize latest values to mimic setup in init
            latestCLLocation = nil
            latestHeading = nil
            latestAccuracyAuthorization = locationProvider.accuracyAuthorization
            locationProvider.setDelegate(self)
            syncIsUpdatingLocation()
            syncIsUpdatingHeading()
        }
    }

    private let interfaceOrientationProvider: InterfaceOrientationProvider
    private let notificationCenter: NotificationCenterProtocol
    private let device: UIDevice
    private var mayRequestWhenInUseAuthorization: Bool
    private var headingOrientationUpdateBackupTimer: Timer?
    private weak var userInterfaceOrientationView: UIView?

    internal init(locationProvider: LocationProvider,
                  interfaceOrientationProvider: InterfaceOrientationProvider,
                  notificationCenter: NotificationCenterProtocol,
                  userInterfaceOrientationView: UIView,
                  device: UIDevice,
                  mayRequestWhenInUseAuthorization: Bool) {
        self.locationProvider = locationProvider
        self.notificationCenter = notificationCenter
        self.mayRequestWhenInUseAuthorization = mayRequestWhenInUseAuthorization
        self.latestAccuracyAuthorization = locationProvider.accuracyAuthorization
        self.interfaceOrientationProvider = interfaceOrientationProvider
        self.userInterfaceOrientationView = userInterfaceOrientationView
        self.device = device
        self.locationProvider.setDelegate(self)
    }

    deinit {
        headingOrientationUpdateBackupTimer?.invalidate()

        // note that property observers (didSet) don't run during deinit
        if isUpdatingLocation {
            locationProvider.stopUpdatingLocation()
        }

        if isUpdatingHeading {
            locationProvider.stopUpdatingHeading()
            device.endGeneratingDeviceOrientationNotifications()
        }
    }

    /// The location manager holds weak references to consumers, client code should retain these references.
    internal func add(_ consumer: LocationConsumer) {
        _locationConsumers.add(consumer)
        syncIsUpdatingLocation()
    }

    /// Removes a location consumer from the location manager.
    internal func remove(_ consumer: LocationConsumer) {
        _locationConsumers.remove(consumer)
        syncIsUpdatingLocation()
    }

    internal func addHeadingConsumer(_ consumer: HeadingConsumer) {
        _headingConsumers.add(consumer)
        syncIsUpdatingHeading()
    }

    internal func removeHeadingConsumer(_ consumer: HeadingConsumer) {
        _headingConsumers.remove(consumer)
        syncIsUpdatingHeading()
    }

    // MARK: - Location

    private func startUpdatingInterfaceOrientation() {
        // backup timer if there are some cases when `UIDevice.orientationDidChangeNotification` is not fired
        // on user interface orientation change
        // not sure if this is needed at all
        let backupTimerInterval: TimeInterval = 3
        headingOrientationUpdateBackupTimer = Timer.scheduledTimer(
            withTimeInterval: backupTimerInterval,
            repeats: true
        ) { [weak self] _ in
            self?.updateHeadingOrientationIfNeeded(showWarning: true)
        }
        headingOrientationUpdateBackupTimer?.tolerance = 0.5

        device.beginGeneratingDeviceOrientationNotifications()
        notificationCenter.addObserver(self,
                                       selector: #selector(deviceOrientationDidChange),
                                       name: UIDevice.orientationDidChangeNotification,
                                       object: nil)
    }

    private func stopUpdatingInterfaceOrientation() {
        headingOrientationUpdateBackupTimer?.invalidate()
        headingOrientationUpdateBackupTimer = nil

        device.endGeneratingDeviceOrientationNotifications()
        notificationCenter.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    @objc private func deviceOrientationDidChange(_ notification: Notification) {
        updateHeadingOrientationIfNeeded()
    }

    internal func updateHeadingOrientationIfNeeded() {
        updateHeadingOrientationIfNeeded(showWarning: false)
    }

    private func updateHeadingOrientationIfNeeded(showWarning: Bool) {
        guard let view = userInterfaceOrientationView,
              let headingOrientation = interfaceOrientationProvider.headingOrientation(for: view) else {
            return
        }

        // Setting this property causes a heading update,
        // so we only set it when it changes to avoid unnecessary work.
        if locationProvider.headingOrientation != headingOrientation {
            _ignoreLocationProviderUpdate = true
            locationProvider.headingOrientation = headingOrientation
            _ignoreLocationProviderUpdate = false
            if showWarning {
                Log.warning(forMessage: "Unexpected user interface orientation change was detected. Please file an issue at https://github.com/mapbox/mapbox-maps-ios/issues")
            }
        }
    }

    private func notifyLocationConsumers() {
        guard isUpdatingLocation else {
            return
        }
        if let latestLocation = latestLocation {
            for consumer in _locationConsumers.allObjects {
                consumer.locationUpdate(newLocation: latestLocation)
            }
        }
    }

    private func notifyHeadingConsumers() {
        guard isUpdatingHeading else {
            return
        }
        if let latestHeading = latestHeading {
            for consumer in _headingConsumers.allObjects {
                consumer.headingUpdate(newHeading: latestHeading)
            }
        }
    }

    private func syncIsUpdatingLocation() {
        // check _consumers.anyObject != nil instead of simply _consumers.count
        // which may still include objects that have been deinited
        isUpdatingLocation = (_locationConsumers.anyObject != nil)
    }

    private func syncIsUpdatingHeading() {
        // check _consumers.anyObject != nil instead of simply _consumers.count
        // which may still include objects that have been deinited
        isUpdatingHeading = (_headingConsumers.anyObject != nil)
    }
}

// At the beginning of each required method, check whether there are still any consumers and if not,
// set `isUpdating` to false and return early. This is necessary to ensure we stop using location
// services when there are no consumers due to the fact that we only keep weak references to them, and
// they may be deinited without ever being explicitly removed.
extension LocationProducer: LocationProviderDelegate {
    internal func locationProvider(_ provider: LocationProvider, didUpdateLocations locations: [CLLocation]) {
        syncIsUpdatingLocation()
        latestCLLocation = locations.last
    }

    internal func locationProvider(_ provider: LocationProvider, didUpdateHeading newHeading: CLHeading) {
        syncIsUpdatingHeading()
        latestHeading = newHeading
    }

    internal func locationProvider(_ provider: LocationProvider, didFailWithError error: Error) {
        syncIsUpdatingLocation()
        Log.error(forMessage: "\(provider) did fail with error: \(error)", category: "Location")
        delegate?.locationProducer(self, didFailWithError: error)
    }

    internal func locationProviderDidChangeAuthorization(_ provider: LocationProvider) {
        syncIsUpdatingLocation()
        let accuracyAuthorization = provider.accuracyAuthorization
        if #available(iOS 14.0, *),
           isUpdatingLocation,
           [.authorizedAlways, .authorizedWhenInUse].contains(provider.authorizationStatus),
           accuracyAuthorization == .reducedAccuracy {
            provider.requestTemporaryFullAccuracyAuthorization(
                withPurposeKey: "LocationAccuracyAuthorizationDescription")
        }
        latestAccuracyAuthorization = accuracyAuthorization
    }
}

extension LocationProducer: CalibratingLocationProviderDelegate {
    func locationProviderShouldDisplayHeadingCalibration(_ locationProvider: LocationProvider) -> Bool {
        return delegate?.locationProducerShouldDisplayHeadingCalibration(self) ?? false
    }
}
