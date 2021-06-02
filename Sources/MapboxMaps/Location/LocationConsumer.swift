import Foundation
import CoreLocation

@objc public class Location: NSObject {
    public let heading: CLHeading?
    internal let internalLocation: CLLocation

    public var coordinate: CLLocationCoordinate2D {
        return internalLocation.coordinate
    }

    public var course: CLLocationDirection {
        return internalLocation.course
    }

    public var horizontalAccuracy: CLLocationAccuracy {
        return internalLocation.horizontalAccuracy
    }

    public var headingDirection: CLLocationDirection? {
        guard let heading = self.heading else { return nil }

        if heading.trueHeading >= 0 {
            return heading.trueHeading
        }

        return heading.magneticHeading
    }

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
