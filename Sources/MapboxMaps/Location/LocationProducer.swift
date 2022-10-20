import UIKit
@_implementationOnly import MapboxCommon_Private

internal protocol LocationProducerProtocol: AnyObject {
    var delegate: LocationProducerDelegate? { get set }
    var latestLocation: Location? { get }
    var consumers: NSHashTable<LocationConsumer> { get }
    var locationProvider: LocationProvider { get set }
    func add(_ consumer: LocationConsumer)
    func remove(_ consumer: LocationConsumer)
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
            notifyConsumers()
        }
    }

    private var latestHeading: CLHeading? {
        didSet {
            notifyConsumers()
        }
    }

    private var latestAccuracyAuthorization: CLAccuracyAuthorization {
        didSet {
            if latestAccuracyAuthorization != oldValue {
                delegate?.locationProducer(self, didChangeAccuracyAuthorization: latestAccuracyAuthorization)
            }
            notifyConsumers()
        }
    }

    private let _consumers = NSHashTable<LocationConsumer>.weakObjects()
    internal var consumers: NSHashTable<LocationConsumer> {
        // swiftlint:disable:next force_cast
        return _consumers.copy() as! NSHashTable<LocationConsumer>
    }

    private var isUpdating = false {
        didSet {
            guard isUpdating != oldValue else {
                return
            }
            if isUpdating {
                /// Get permissions if needed
                if mayRequestWhenInUseAuthorization,
                   locationProvider.authorizationStatus == .notDetermined {
                    locationProvider.requestWhenInUseAuthorization()
                }
                locationProvider.startUpdatingLocation()
                locationProvider.startUpdatingHeading()
                updateHeadingOrientationIfNeeded()
                startUpdatingInterfaceOrientation()
            } else {
                locationProvider.stopUpdatingLocation()
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
            isUpdating = false
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
            syncIsUpdating()
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
        if isUpdating {
            locationProvider.stopUpdatingLocation()
            locationProvider.stopUpdatingHeading()
            device.endGeneratingDeviceOrientationNotifications()
        }
    }

    /// The location manager holds weak references to consumers, client code should retain these references.
    internal func add(_ consumer: LocationConsumer) {
        _consumers.add(consumer)
        syncIsUpdating()
    }

    /// Removes a location consumer from the location manager.
    internal func remove(_ consumer: LocationConsumer) {
        _consumers.remove(consumer)
        syncIsUpdating()
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
extension LocationProducer: LocationProviderDelegate {
    internal func locationProvider(_ provider: LocationProvider, didUpdateLocations locations: [CLLocation]) {
        syncIsUpdating()
        latestCLLocation = locations.last
    }

    internal func locationProvider(_ provider: LocationProvider, didUpdateHeading newHeading: CLHeading) {
        syncIsUpdating()
        latestHeading = newHeading
    }

    internal func locationProvider(_ provider: LocationProvider, didFailWithError error: Error) {
        syncIsUpdating()
        Log.error(forMessage: "\(provider) did fail with error: \(error)", category: "Location")
        delegate?.locationProducer(self, didFailWithError: error)
    }

    internal func locationProviderDidChangeAuthorization(_ provider: LocationProvider) {
        syncIsUpdating()
        let accuracyAuthorization = provider.accuracyAuthorization
        if #available(iOS 14.0, *),
           isUpdating,
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
