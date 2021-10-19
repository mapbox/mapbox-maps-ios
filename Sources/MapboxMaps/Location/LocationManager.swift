import CoreLocation
import UIKit

/// An object responsible for notifying the map view about location-related events,
/// such as a change in the device’s location.
public class LocationManager: NSObject {

    /// Represents the latest location received from the location provider.
    public private(set) var latestLocation: Location?

    /// Represents the style of the user location puck.
    private var currentPuckStyle: PuckStyle = .precise {
        didSet {
            locationPuckManager?.changePuckStyle(to: currentPuckStyle)
        }
    }

    /// The object that acts as the delegate of the location manager.
    public weak var delegate: LocationPermissionsDelegate?

    /// Property that provide location and authorization updates.
    public private(set) var locationProvider: LocationProvider!

    /// Property that has a list of items that will consume location events.
    /// The location manager holds weak references to these consumers, client code should retain these references.
    public private(set) lazy var consumers: NSHashTable<LocationConsumer> = {
        let hashTable = NSHashTable<LocationConsumer>.weakObjects()
        return hashTable
    }()

    private var locationUserCount: Int = 0 {
        didSet {
            adjustUserLocationCount(oldValue: oldValue, newValue: locationUserCount)
        }
    }

    /// Style that has limited functionality to support location.
    internal weak var style: LocationStyleProtocol?

    /// Manager that handles the visual puck element.
    /// Only created if `showsUserLocation` is `true`.
    internal var locationPuckManager: LocationPuckManager? {
        didSet {
            if let oldValue = oldValue {
                removeLocationConsumer(consumer: oldValue)
            }

            if let locationPuckManager = locationPuckManager {
                addLocationConsumer(newConsumer: locationPuckManager)
            }
        }
    }

    /// The `LocationOptions` that configure the location manager.
    public var options = LocationOptions() {
        didSet {
            guard options != oldValue else { return }
            locationProvider.locationProviderOptions = options

            if options.puckType != oldValue.puckType {
                syncUserLocationUpdating()
            }

            if let puckType = options.puckType, puckType != oldValue.puckType {
                locationPuckManager?.changePuckType(to: puckType)
            }

            if options.puckBearingSource != oldValue.puckBearingSource {
                locationPuckManager?.puckBearingSource = options.puckBearingSource
            }
        }
    }

    internal init(style: LocationStyleProtocol) {
        self.style = style

        super.init()

        /// Sets our default `locationProvider`
        locationProvider = AppleLocationProvider()
        locationProvider.setDelegate(self)
        locationProvider.locationProviderOptions = options

        syncUserLocationUpdating()
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

    /// The location manager holds weak references to consumers, client code should retain these references.
    public func addLocationConsumer(newConsumer consumer: LocationConsumer) {
        consumers.add(consumer)
        locationUserCount += 1
    }

    /// Removes a location consumer from the location manager.
    public func removeLocationConsumer(consumer: LocationConsumer) {
        consumers.remove(consumer)
        locationUserCount -= 1
    }

    /// Allows a custom case to request full accuracy
    @available(iOS 14.0, *)
    public func requestTemporaryFullAccuracyPermissions(withPurposeKey purposeKey: String) {
        locationProvider.requestTemporaryFullAccuracyAuthorization(withPurposeKey: purposeKey)
    }
}

// MARK: LocationProviderDelegate functions
@available(iOSApplicationExtension, unavailable)
extension LocationManager: LocationProviderDelegate {

    public func locationProvider(_ provider: LocationProvider, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }

        for consumer in consumers.allObjects {
            let location = Location(with: newLocation, heading: latestLocation?.heading)
            consumer.locationUpdate(newLocation: location)
            latestLocation = location
        }
    }

    public func locationProvider(_ provider: LocationProvider, didUpdateHeading newHeading: CLHeading) {

        // Ignore any heading updates that come in before a location update
        guard let validLatestLocation = latestLocation else { return }

        // Check if device orientation has changed and inform the location provider accordingly.
        updateHeadingForCurrentDeviceOrientation()

        for consumer in consumers.allObjects {
            let location = Location(with: validLatestLocation.internalLocation,
                                    heading: newHeading)
            consumer.locationUpdate(newLocation: location)
            latestLocation = location
        }
    }

    public func updateHeadingForCurrentDeviceOrientation() {
        if locationProvider != nil {

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
        }

        syncUserLocationUpdating()

        if let delegate = self.delegate {
            delegate.locationManager?(self, didChangeAccuracyAuthorization: provider.accuracyAuthorization)
        }
    }
}

// MARK: Private helper functions that only the Location Manager needs access to
private extension LocationManager {
    func syncUserLocationUpdating() {
        // Remove puck from view
        guard let puckType = options.puckType else {
            locationPuckManager = nil
            return
        }

        if locationPuckManager == nil {
            locationPuckManager = LocationPuckManager(style: style,
                                                      puckType: puckType,
                                                      puckBearingSource: options.puckBearingSource)
        }

        // This serves as a reset and handles the case if permissions were changed for accuracy
        locationPuckManager?.changePuckStyle(to: currentPuckStyle)
    }

    func adjustUserLocationCount(oldValue: Int, newValue: Int) {
        if oldValue == 0 && newValue > 0 {
            /// Get permissions if needed
            if locationProvider.authorizationStatus == .notDetermined {
                requestLocationPermissions()
            }

            locationProvider.startUpdatingLocation()
            locationProvider.startUpdatingHeading()
        } else if oldValue > 0 && newValue == 0 {
            locationProvider.stopUpdatingLocation()
            locationProvider.stopUpdatingHeading()
        }
    }

    func requestLocationPermissions() {
        if Bundle.main.infoDictionary?["NSLocationWhenInUseUsageDescription"] != nil {
            locationProvider.requestWhenInUseAuthorization()
        }
    }
}
