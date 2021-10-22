import Foundation
import CoreLocation

/// The `LocationConsumer` protocol defines a method that a class must implement to consume location updates from LocationManager
@objc public protocol LocationConsumer {

    /// New location update received
    func locationUpdate(newLocation: Location)
}
