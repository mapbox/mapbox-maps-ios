import CoreLocation

/// The `LocationProviderDelegate` protocol defines a set of methods that respond
/// to location updates from an `LocationProvider`.
public protocol LocationProviderDelegate: AnyObject {

    /// Notifies the delegate with the new location data.
    /// - Parameters:
    ///   - provider: The location provider reporting the update.
    ///   - locations: An array of `CLLocation` objects in chronological order,
    ///                with the last object representing the most recent location.
    func locationProvider(_ provider: LocationProvider, didUpdateLocations locations: [CLLocation])

    /// Notifies the delegate with the new heading data.
    /// - Parameters:
    ///   - provider: The location provider reporting the update.
    ///   - newHeading: The new heading update.
    func locationProvider(_ provider: LocationProvider, didUpdateHeading newHeading: CLHeading)

    /// Notifies the delegate that the location provider was unable to retrieve
    /// location updates.
    /// - Parameters:
    ///   - provider: The location provider reporting the error.
    ///   - error: An error object containing the error code that indicates
    ///            why the location provider failed.
    func locationProvider(_ provider: LocationProvider, didFailWithError error: Error)

    /// Notifies the delegate that the location provider changed accuracy authorization
    /// - Parameters:
    ///   - provider: The location provider reporting the error.
    ///   - manager: The location manager that is reporting the change
    func locationProviderDidChangeAuthorization(_ provider: LocationProvider)
}

/// This implementation of LocationProviderDelegate is used by `LocationManager` to work around
/// the fact that the `LocationProvider` API does not allow the delegate to be set to `nil`.
internal class EmptyLocationProviderDelegate: LocationProviderDelegate {
    func locationProvider(_ provider: LocationProvider, didFailWithError error: Error) {}
    func locationProvider(_ provider: LocationProvider, didUpdateHeading newHeading: CLHeading) {}
    func locationProvider(_ provider: LocationProvider, didUpdateLocations locations: [CLLocation]) {}
    func locationProviderDidChangeAuthorization(_ provider: LocationProvider) {}
}

internal protocol CalibratingLocationProviderDelegate: LocationProviderDelegate {
    func locationProviderShouldDisplayHeadingCalibration(_ locationProvider: LocationProvider) -> Bool
}
