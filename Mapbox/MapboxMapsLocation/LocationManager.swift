import CoreLocation
import UIKit

#if canImport(MapboxMapsFoundation)
import MapboxMapsFoundation
#endif

/// An object responsible for notifying the map view about location-related events,
/// such as a change in the user’s location.
public class LocationManager: NSObject {

    /// Represents the latest location received from the location provider
    public private(set) var latestLocation: Location?

    /// Represents the style of the user location puck
    internal var currentPuckStyle: PuckStyle = .precise {
        didSet {
            self.locationPuckManager?.changePuckStyle(newPuckStyle: currentPuckStyle)
        }
    }

    /// The object that acts as the delegate of the location manager.
    public weak var delegate: LocationPermissionsDelegate?

    /// Making variable `public private(set)` to have direct access to auth functions
    public private(set) var locationProvider: LocationProvider!

    /// Property that will determine if user location visuals should be displayed or not
    public private(set) var showUserLocation: Bool = false

    /// Property that has a list of items that will consume location events
    public private(set) lazy var consumers: NSHashTable<LocationConsumer> = {
        let hashTable = NSHashTable<LocationConsumer>.weakObjects()
        return hashTable
    }()

    /// `MapView` that has specific functionality to support location
    internal weak var locationSupportableMapView: LocationSupportableMapView!

    /// Manager that handles the visual puck element.
    /// Only created if `showsUserLocation` is `true`
    internal var locationPuckManager: LocationPuckManager?

    internal var locationOptions: LocationOptions!

    internal init(locationOptions: LocationOptions,
                  locationSupportableMapView: LocationSupportableMapView) {
        super.init()

        self.locationOptions = locationOptions

        /// Allows location updates to be reflected on screen using delegate method
        self.locationSupportableMapView = locationSupportableMapView

        /// Sets our default `locationProvider`
        self.locationProvider = AppleLocationProvider()
        self.locationProvider.setDelegate(self)
        self.locationProvider.locationProviderOptions = locationOptions

        /// Sets the local options needed to configure the user location puck
        self.showUserLocation = locationOptions.showUserLocation
        toggleUserLocationUpdates(showUserLocation: locationOptions.showUserLocation)
    }

    public func overrideLocationProvider(with customLocationProvider: LocationProvider) {

        /// Deinit original location provider
        locationProvider.stopUpdatingHeading()
        locationProvider.stopUpdatingLocation()
        locationProvider = nil

        /// Use custom location provider
        locationProvider = customLocationProvider
        locationProvider.setDelegate(self)
    }

    public func addLocationConsumer(newConsumer consumer: LocationConsumer) {
        self.consumers.add(consumer)
    }

    public func removeLocationConsumer(consumer: LocationConsumer) {
        self.consumers.remove(consumer)
    }

    internal func updateLocationOptions(with newOptions: LocationOptions) {

        guard newOptions != locationOptions else { return }

        if newOptions.showUserLocation != showUserLocation {
            self.showUserLocation = newOptions.showUserLocation
            toggleUserLocationUpdates(showUserLocation: self.showUserLocation)

            if !newOptions.showUserLocation {
                // If we should not show user location, then we should
                // not try and change source or style below
                return
            }
        }

        if newOptions.puckBackend != locationOptions.puckBackend {
            if let locationPuckManager = self.locationPuckManager {
                locationPuckManager.changePuckBackend(newPuckBackend: newOptions.puckBackend)
            }
        }


        self.locationProvider.locationProviderOptions = newOptions

        self.locationOptions = newOptions
    }

    /// Allows a custom case to request full accuracy
    @available(iOS 14.0, *)
    public func requestTemporaryFullAccuracyPermissions(withPurposeKey purposeKey: String) {
        locationProvider.requestTemporaryFullAccuracyAuthorization(withPurposeKey: purposeKey)
    }
}

// MARK: LocationProviderDelegate functions
extension LocationManager: LocationProviderDelegate {

    public func locationProvider(_ provider: LocationProvider, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }

        for consumer in consumers.allObjects {
            let location = Location(with: newLocation, heading: latestLocation?.heading)
            consumer.locationUpdate(newLocation: location)
            self.latestLocation = location
        }
    }

    public func locationProvider(_ provider: LocationProvider, didUpdateHeading newHeading: CLHeading) {

        // Ignore any heading updates that come in before a location update
        guard let validLatestLocation = latestLocation else { return }

        // Check if device orientation has changed and inform the location provider accordingly.
        self.updateHeadingForCurrentDeviceOrientation()

        for consumer in consumers.allObjects {
            let location = Location(with: validLatestLocation.internalLocation,
                                    heading: newHeading)
            consumer.locationUpdate(newLocation: location)
            self.latestLocation = location
        }
    }

    public func updateHeadingForCurrentDeviceOrientation() {
        if self.locationProvider != nil {

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
            if self.locationProvider.headingOrientation != orientation {
                self.locationProvider.headingOrientation = orientation
            }
        }
    }

    public func locationProvider(_ provider: LocationProvider, didFailWithError error: Error) {
        print("Failed with error: \(error)")
    }

    public func locationProviderDidChangeAuthorization(_ provider: LocationProvider) {
        if provider.authorizationStatus == .authorizedAlways || provider.authorizationStatus == .authorizedWhenInUse {
            if #available(iOS 14.0, *) {
                if provider.accuracyAuthorization == .reducedAccuracy {
                    let purposeKey = "LocationAccuracyAuthorizationDescription"
                    provider.requestTemporaryFullAccuracyAuthorization(withPurposeKey: purposeKey)
                    self.currentPuckStyle = .approximate
                } else {
                    self.currentPuckStyle = .precise
                }
            }
            showUserLocation = true
        } else {
            showUserLocation = false
        }

        toggleUserLocationUpdates(showUserLocation: self.showUserLocation)

        if let delegate = self.delegate {
            delegate.locationManager?(self, didChangeAccuracyAuthorization: provider.accuracyAuthorization)
        }
    }
}

// MARK: Private helper functions that only the Location Manager needs access to
private extension LocationManager {
    func toggleUserLocationUpdates(showUserLocation: Bool) {
        if showUserLocation {
            /// Get permissions if needed
            if locationProvider.authorizationStatus == .notDetermined {
                requestLocationPermissions()
            }

            locationProvider.startUpdatingLocation()
            locationProvider.startUpdatingHeading()

            if let locationPuckManager = self.locationPuckManager {
                // This serves as a reset and handles the case if permissions were changed for accuracy
                locationPuckManager.changePuckStyle(newPuckStyle: currentPuckStyle)
            }
            else {
                let locationPuckManager = LocationPuckManager(shouldTrackLocation: true,
                                                              locationSupportableMapView: self.locationSupportableMapView,
                                                              currentPuckSource: self.locationProvider.locationProviderOptions.puckBackend)

                self.consumers.add(locationPuckManager)
                self.locationPuckManager = locationPuckManager
            }
        } else {
            locationProvider.stopUpdatingLocation()
            locationProvider.stopUpdatingHeading()

            if let locationPuckManager = self.locationPuckManager {
                locationPuckManager.removePuck()
            }
        }
    }

    func requestLocationPermissions() {
        if (Bundle.main.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription")) != nil {
            locationProvider.requestWhenInUseAuthorization()
        }
    }
}
