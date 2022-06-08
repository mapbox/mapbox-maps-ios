import Foundation
import CoreLocation

/// The `LocationConsumer` protocol defines a method that a class must implement to consume location updates from LocationManager
@objc public protocol LocationConsumer {

    /// New location update received
    func locationUpdate(newLocation: Location)
}

/// The `PuckLocationConsumer` protocol defines a method that a conformer must implement to consumer a puck's accurate location.
@objc public protocol PuckLocationConsumer {

    /// To be invoked when a new puck's location is received.
    func puckLocationUpdate(newLocation: Location)
}
