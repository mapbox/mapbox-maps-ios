import Foundation
@_implementationOnly import MapboxCommon_Private

internal class LocationSource {

    internal weak var locationProviderDelegate: LocationProviderDelegate?

    /// Represents the latest location received from the location provider.
    internal private(set) var latestLocation: Location? {
        didSet {
            if let latestLocation = latestLocation {
                for consumer in _consumers.allObjects {
                    consumer.locationUpdate(newLocation: latestLocation)
                }
            }
        }
    }

    private let _consumers = NSHashTable<LocationConsumer>.weakObjects()
    internal var consumers: NSHashTable<LocationConsumer> {
        return _consumers.copy() as! NSHashTable<LocationConsumer>
    }

    private var isUpdating = false {
        didSet {
            guard isUpdating != oldValue else {
                return
            }
            if isUpdating {
                /// Get permissions if needed
                if locationProvider.authorizationStatus == .notDetermined {
                    if Bundle.main.infoDictionary?["NSLocationWhenInUseUsageDescription"] != nil {
                        locationProvider.requestWhenInUseAuthorization()
                    }
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

    internal init(locationProvider: LocationProvider) {
        self.locationProvider = locationProvider
        self.locationProvider.setDelegate(self)
    }

    deinit {
        isUpdating = false
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

    internal func updateHeadingForCurrentDeviceOrientation() {
        // note that right/left device and interface orientations
        // are opposites (see UIApplication.h)
        var orientation: CLDeviceOrientation

        switch UIApplication.shared.statusBarOrientation {
        case .landscapeLeft:
            orientation = .landscapeRight
        case .landscapeRight:
            orientation = .landscapeLeft
        case .portraitUpsideDown:
            orientation = .portraitUpsideDown
        default:
            orientation = .portrait
        }

        // Setting the location manager's heading orientation causes it to send
        // a heading event, which in turn makes us redraw, which kicks off a
        // loop... so don't do that. rdar://34059173
        if locationProvider.headingOrientation != orientation {
            locationProvider.headingOrientation = orientation
        }
    }
}

// At the beginning of each required method, check whether there are still any consumers and if not,
// set `isUpdating` to false and return early. This is necessary to ensure we stop using location
// services when there are no consumers due to the fact that we only keep weak references to them, and
// they may be deinited without ever being explicitly removed.
extension LocationSource: LocationProviderDelegate {

    internal func locationProvider(_ provider: LocationProvider, didUpdateLocations locations: [CLLocation]) {
        isUpdating = (_consumers.count > 0)
        guard isUpdating else {
            return
        }
        if let newLocation = locations.last {
            latestLocation = Location(with: newLocation, heading: latestLocation?.heading)
        }
        locationProviderDelegate?.locationProvider(provider, didUpdateLocations: locations)
    }

    internal func locationProvider(_ provider: LocationProvider, didUpdateHeading newHeading: CLHeading) {        isUpdating = (_consumers.count > 0)
        guard isUpdating else {
            return
        }
        // Ignore any heading updates that come in before a location update
        if let validLatestLocation = latestLocation {
            // Check if device orientation has changed and inform the location provider accordingly.
            updateHeadingForCurrentDeviceOrientation()
            latestLocation = Location(with: validLatestLocation.internalLocation, heading: newHeading)
        }
        locationProviderDelegate?.locationProvider(provider, didUpdateHeading: newHeading)
    }

    internal func locationProvider(_ provider: LocationProvider, didFailWithError error: Error) {
        isUpdating = (_consumers.count > 0)
        guard isUpdating else {
            return
        }
        Log.error(forMessage: "LocationProvider did fail with error: \(error)", category: "Location")
        locationProviderDelegate?.locationProvider(provider, didFailWithError: error)
    }

    internal func locationProviderDidChangeAuthorization(_ provider: LocationProvider) {
        isUpdating = (_consumers.count > 0)
        guard isUpdating else {
            return
        }
        if provider.authorizationStatus == .authorizedAlways || provider.authorizationStatus == .authorizedWhenInUse {
            if #available(iOS 14.0, *) {
                if provider.accuracyAuthorization == .reducedAccuracy {
                    let purposeKey = "LocationAccuracyAuthorizationDescription"
                    provider.requestTemporaryFullAccuracyAuthorization(withPurposeKey: purposeKey)
                }
            }
        }
        locationProviderDelegate?.locationProviderDidChangeAuthorization(provider)
    }
}
