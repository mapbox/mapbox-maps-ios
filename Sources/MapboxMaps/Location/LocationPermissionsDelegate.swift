import CoreLocation

/// The `LocationPermissionsDelegate` protocol defines a set of optional methods that you
/// can use to receive events from an associated location manager object.
@objc public protocol LocationPermissionsDelegate {
    /// Tells the delegate that an attempt to locate the user’s position failed.
    /// - Parameters:
    ///   - locationManager: The location manager that is tracking the user’s location.
    ///   - error: An error object containing the reason why location tracking failed.
    @objc optional func locationManager(_ locationManager: LocationManager, didFailToLocateUserWithError error: Error)

    /// Tells the delegate that the accuracy authorization has changed.
    /// - Parameters:
    ///   - locationManager: The location manager that is tracking the user’s location.
    ///   - accuracyAuthorization: The updated accuracy authorization value.
    @objc optional func locationManager(_ locationManager: LocationManager,
                                        didChangeAccuracyAuthorization accuracyAuthorization: CLAccuracyAuthorization)

    /// Asks the delegate whether the heading calibration alert should be displayed.
    /// - Parameter locationManager: The location manager object coordinating the display of the heading calibration alert.
    /// - Returns: `true` if you want to allow the heading calibration alert to be displayed; `false` if you do not.
    @objc optional func locationManagerShouldDisplayHeadingCalibration(_ locationManager: LocationManager) -> Bool
}
