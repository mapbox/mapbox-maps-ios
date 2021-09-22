import Foundation
import CoreLocation

@objc public class Location: NSObject {

    /// The orientation of the user's device. The default value is `nil` if the device heading cannot be accessed.
    public let heading: CLHeading?
    internal let internalLocation: CLLocation

    /// A `CLLocationCoordinate2D` that represents a physical location.
    public var coordinate: CLLocationCoordinate2D {
        return internalLocation.coordinate
    }

    /// The direction that the device is moving in degrees true North.
    public var course: CLLocationDirection {
        return internalLocation.course
    }

    /// The horizontal accuracy of a location.
    public var horizontalAccuracy: CLLocationAccuracy {
        return internalLocation.horizontalAccuracy
    }

    /// The optional heading direction. Returns `nil` if `Location.heading` is `nil`.
    /// If the heading relative to true north can be determined, that value will be used. Otherwise, magnetic north will be used.
    public var headingDirection: CLLocationDirection? {
        guard let heading = self.heading else { return nil }

        if heading.trueHeading >= 0 {
            return heading.trueHeading
        }

        return heading.magneticHeading
    }

    /// Initialize a `Location` object.
    public init(with location: CLLocation, heading: CLHeading? = nil) {
        internalLocation = location
        self.heading = heading
    }
}

/// The `LocationConsumer` protocol defines a method that a class must implement to consume location updates from LocationManager
@objc public protocol LocationConsumer {

    /// New location update received
    func locationUpdate(newLocation: Location)
}
