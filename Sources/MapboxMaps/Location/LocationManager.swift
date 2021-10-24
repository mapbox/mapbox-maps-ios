import CoreLocation
import UIKit

/// An object responsible for notifying the map view about location-related events,
/// such as a change in the device’s location.
public final class LocationManager: NSObject {

    /// Represents the latest location received from the location provider.
    public var latestLocation: Location? {
        return locationSource.latestLocation
    }

    /// The object that acts as the delegate of the location manager.
    public weak var delegate: LocationPermissionsDelegate?

    /// Property that provide location and authorization updates.
    public var locationProvider: LocationProvider! {
        return locationSource.locationProvider
    }

    /// Property that has a list of items that will consume location events.
    /// The location manager holds weak references to these consumers, client code should retain these references.
    /// This property returns a copy of the underlying table, so mutating the returned hash table will have no effect.
    public var consumers: NSHashTable<LocationConsumer> {
        return locationSource.consumers
    }

    private let locationSource: LocationSourceProtocol

    /// Manager that handles the visual puck element.
    /// Only created if `showsUserLocation` is `true`.
    private let puckManager: PuckManagerProtocol

    /// The `LocationOptions` that configure the location manager.
    public var options = LocationOptions() {
        didSet {
            syncOptions()
        }
    }

    internal init(locationSource: LocationSourceProtocol,
                  puckManager: PuckManagerProtocol) {
        self.locationSource = locationSource
        self.puckManager = puckManager
        super.init()
        locationSource.delegate = self
        syncOptions()
    }

    public func overrideLocationProvider(with customLocationProvider: LocationProvider) {
        locationSource.locationProvider = customLocationProvider
    }

    /// The location manager holds weak references to consumers, client code should retain these references.
    public func addLocationConsumer(newConsumer consumer: LocationConsumer) {
        locationSource.add(consumer)
    }

    /// Removes a location consumer from the location manager.
    public func removeLocationConsumer(consumer: LocationConsumer) {
        locationSource.remove(consumer)
    }

    /// Allows a custom case to request full accuracy
    @available(iOS 14.0, *)
    public func requestTemporaryFullAccuracyPermissions(withPurposeKey purposeKey: String) {
        locationProvider.requestTemporaryFullAccuracyAuthorization(withPurposeKey: purposeKey)
    }

    public func updateHeadingForCurrentDeviceOrientation() {
        locationSource.updateHeadingForCurrentDeviceOrientation()
    }

    private func syncOptions() {
        locationSource.locationProvider.locationProviderOptions = options
        puckManager.puckType = options.puckType
        puckManager.puckBearingSource = options.puckBearingSource
    }
}

// These methods must remain to avoid breaking the API, but their implementation has been moved
// to `LocationSource`. They should be fully removed in the next major version.
extension LocationManager: LocationProviderDelegate {
    public func locationProvider(_ provider: LocationProvider, didUpdateLocations locations: [CLLocation]) {}
    public func locationProvider(_ provider: LocationProvider, didUpdateHeading newHeading: CLHeading) {}
    public func locationProvider(_ provider: LocationProvider, didFailWithError error: Error) {}
    public func locationProviderDidChangeAuthorization(_ provider: LocationProvider) {}
}

extension LocationManager: LocationSourceDelegate {
    internal func locationSource(_ locationSource: LocationSourceProtocol,
                                 didFailWithError error: Error) {
        delegate?.locationManager?(self, didFailToLocateUserWithError: error)
    }

    internal func locationSource(_ locationSource: LocationSourceProtocol,
                                 didChangeAccuracyAuthorization accuracyAuthorization: CLAccuracyAuthorization) {
        delegate?.locationManager?(self, didChangeAccuracyAuthorization: accuracyAuthorization)
    }
}
