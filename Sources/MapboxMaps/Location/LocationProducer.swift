import UIKit
@_implementationOnly import MapboxCommon_Private

internal protocol LocationProducerProtocol: AnyObject {
    var delegate: LocationProducerDelegate? { get set }
    var latestLocation: Location? { get }
    var headingOrientation: CLDeviceOrientation { get set }
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
            } else {
                locationProvider.stopUpdatingLocation()
                locationProvider.stopUpdatingHeading()
            }
        }
    }

    internal var locationProvider: LocationProvider {
        willSet {
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
            // reinitialize latest values to mimic setup in init
            latestCLLocation = nil
            latestHeading = nil
            latestAccuracyAuthorization = locationProvider.accuracyAuthorization
            locationProvider.setDelegate(self)
            syncIsUpdating()
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
