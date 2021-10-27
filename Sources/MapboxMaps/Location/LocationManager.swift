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

    /// The current underlying location provider. Use `overrideLocationProvider(with:)` to substitute a different provider.
    /// Avoid manipulating the location provider directly. LocationManager assumes full responsibility for starting and stopping location
    /// and heading updates as needed.
    public var locationProvider: LocationProvider! {
        return locationSource.locationProvider
    }

    /// The set of objects that are currently consuming location updates.
    /// The returned object is a copy of the underlying one, so mutating it will have no effect.
    public var consumers: NSHashTable<LocationConsumer> {
        return locationSource.consumers
    }

    /// Configuration options for the location manager.
    public var options = LocationOptions() {
        didSet {
            syncOptions()
        }
    }

    private let locationSource: LocationSourceProtocol

    /// Manager that handles the visual puck element.
    /// Only created if `showsUserLocation` is `true`.
    private let puckManager: PuckManagerProtocol

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

    /// Deprecated. Calling this method is unnecessary and no longer has any effect.
    public func updateHeadingForCurrentDeviceOrientation() {
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

    /// Deprecated. This method no longer has any effect.
    public func locationProvider(_ provider: LocationProvider, didUpdateLocations locations: [CLLocation]) {}

    /// Deprecated. This method no longer has any effect.
    public func locationProvider(_ provider: LocationProvider, didUpdateHeading newHeading: CLHeading) {}

    /// Deprecated. This method no longer has any effect.
    public func locationProvider(_ provider: LocationProvider, didFailWithError error: Error) {}

    /// Deprecated. This method no longer has any effect.
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
