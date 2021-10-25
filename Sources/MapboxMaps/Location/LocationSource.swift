import UIKit
@_implementationOnly import MapboxCommon_Private

internal protocol LocationSourceProtocol: AnyObject {
    var delegate: LocationSourceDelegate? { get set }
    var latestLocation: Location? { get }
    var headingOrientation: CLDeviceOrientation { get set }
    var consumers: NSHashTable<LocationConsumer> { get }
    var locationProvider: LocationProvider { get set }
    func add(_ consumer: LocationConsumer)
    func remove(_ consumer: LocationConsumer)
}

internal protocol LocationSourceDelegate: AnyObject {
    func locationSource(_ locationSource: LocationSourceProtocol,
                        didFailWithError error: Error)

    func locationSource(_ locationSource: LocationSourceProtocol,
                        didChangeAccuracyAuthorization accuracyAuthorization: CLAccuracyAuthorization)
}

internal final class LocationSource: LocationSourceProtocol {

    internal weak var delegate: LocationSourceDelegate?

    /// Represents the latest location received from the location provider.
    internal var latestLocation: Location? {
        latestCLLocation.map {
            Location(
                location: $0,
                heading: latestHeading,
                accuracyAuthorization: latestAccuracyAuthorization)
        }
    }

    internal var headingOrientation: CLDeviceOrientation {
        get {
            return locationProvider.headingOrientation
        }
        set {
            locationProvider.headingOrientation = newValue
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
                delegate?.locationSource(self, didChangeAccuracyAuthorization: latestAccuracyAuthorization)
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
            } else {
                locationProvider.stopUpdatingLocation()
                locationProvider.stopUpdatingHeading()
            }
        }
    }

    internal var locationProvider: LocationProvider {
        willSet {
            isUpdating = false
            locationProvider.setDelegate(EmptyLocationProviderDelegate())
        }
        didSet {
            locationProvider.setDelegate(self)
            if _consumers.count > 0 {
                isUpdating = true
            }
        }
    }

    private var mayRequestWhenInUseAuthorization: Bool

    internal init(locationProvider: LocationProvider,
                  mayRequestWhenInUseAuthorization: Bool) {
        self.locationProvider = locationProvider
        self.mayRequestWhenInUseAuthorization = mayRequestWhenInUseAuthorization
        self.latestAccuracyAuthorization = locationProvider.accuracyAuthorization
        self.locationProvider.setDelegate(self)
    }

    deinit {
        // note that property observers (didSet) don't run during deinit
        if isUpdating {
            locationProvider.stopUpdatingLocation()
            locationProvider.stopUpdatingHeading()
        }
        // replace the delegate since we can't guarantee that
        // locationProvider has a zeroing weak ref to self
        locationProvider.setDelegate(EmptyLocationProviderDelegate())
    }

    /// The location manager holds weak references to consumers, client code should retain these references.
    internal func add(_ consumer: LocationConsumer) {
        _consumers.add(consumer)
        isUpdating = true
    }

    /// Removes a location consumer from the location manager.
    internal func remove(_ consumer: LocationConsumer) {
        _consumers.remove(consumer)
        isUpdating = (_consumers.count > 0)
    }

    private func notifyConsumers() {
        if let latestLocation = latestLocation {
            for consumer in _consumers.allObjects {
                consumer.locationUpdate(newLocation: latestLocation)
            }
        }
    }
}

// At the beginning of each required method, check whether there are still any consumers and if not,
// set `isUpdating` to false and return early. This is necessary to ensure we stop using location
// services when there are no consumers due to the fact that we only keep weak references to them, and
// they may be deinited without ever being explicitly removed.
extension LocationSource: LocationProviderDelegate {

    private func stopUpdatingIfNeeded() {
        // check _consumers.anyObject != nil instead of simply _consumers.count
        // which may still include objects that have been deinited
        isUpdating = (_consumers.anyObject != nil)
    }

    internal func locationProvider(_ provider: LocationProvider, didUpdateLocations locations: [CLLocation]) {
        stopUpdatingIfNeeded()
        latestCLLocation = locations.last
    }

    internal func locationProvider(_ provider: LocationProvider, didUpdateHeading newHeading: CLHeading) {
        stopUpdatingIfNeeded()
        latestHeading = newHeading
    }

    internal func locationProvider(_ provider: LocationProvider, didFailWithError error: Error) {
        stopUpdatingIfNeeded()
        Log.error(forMessage: "\(provider) did fail with error: \(error)", category: "Location")
        delegate?.locationSource(self, didFailWithError: error)
    }

    internal func locationProviderDidChangeAuthorization(_ provider: LocationProvider) {
        stopUpdatingIfNeeded()
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
