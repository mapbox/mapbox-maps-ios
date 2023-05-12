import Foundation
import CoreLocation

/// The `LocationConsumer` protocol defines a method that a class must implement to consume location updates from LocationManager
public protocol LocationConsumer: AnyObject {

    /// New location update received
    func locationUpdate(newLocation: Location)
}
