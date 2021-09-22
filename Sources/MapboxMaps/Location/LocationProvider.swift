import CoreLocation

/// The ``LocationProvider`` protocol defines a set of methods that a class must
/// implement in order to serve as the location events provider.
public protocol LocationProvider {

    /// Configures the location provider.
    var locationProviderOptions: LocationOptions { get set }

    /// Returns the current localization authorization status.
    var authorizationStatus: CLAuthorizationStatus { get }

    /// Returns the current accuracy authorization that the user has granted.
    /// The default value is `CLAccuracyAuthorization.fullAccuracy` on iOS versions prior to iOS 14.
    var accuracyAuthorization: CLAccuracyAuthorization { get }

    /// Returns the latest heading update received, or `nil` if none is available.
    var heading: CLHeading? { get }

    /**
     Sets the delegate for `LocationProvider`

     - Note: Calling this will override the delegate in `AppleLocationProvider` and is highly discouraged
             Instead implement a LocationConsumer
     */
    func setDelegate(_ delegate: LocationProviderDelegate)

    /// Requests permission to use the location services whenever the app is running.
    func requestAlwaysAuthorization()

    /// Requests permission to use the location services while the app is in
    /// the foreground.
    func requestWhenInUseAuthorization()

    /// Requests temporary permission for precise accuracy
    @available(iOS 14.0, *)
    func requestTemporaryFullAccuracyAuthorization(withPurposeKey purposeKey: String)

    /// Starts the generation of location updates that reports the device's current location.
    func startUpdatingLocation()

    /// Stops the generation of location updates.
    func stopUpdatingLocation()

    /// Specifies a physical device orientation.
    var headingOrientation: CLDeviceOrientation { get set }

    /// Starts the generation of heading updates that reports the devices's current heading.
    func startUpdatingHeading()

    /// Stops the generation of heading updates.
    func stopUpdatingHeading()

    /// Dismisses immediately the heading calibration view from screen.
    func dismissHeadingCalibrationDisplay()

}
