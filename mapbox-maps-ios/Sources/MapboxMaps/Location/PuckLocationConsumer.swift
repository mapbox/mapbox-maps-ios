import Foundation

/// The `PuckLocationConsumer` protocol defines a method that a conformer must implement to consume a puck's accurate location.
public protocol PuckLocationConsumer: AnyObject {

    /// To be invoked when a new puck's location is received.
    func puckLocationUpdate(newLocation: Location)
}
