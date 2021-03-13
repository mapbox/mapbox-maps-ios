import Foundation
import CoreLocation

@objc public class Location: NSObject {
    public let heading: CLHeading?
    public let internalLocation: CLLocation

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

/// The `LocationConsumer` protocol defines a set of methods that a class must implement to consume location updates and track device location
@objc public protocol LocationConsumer {

    /// Represents whether the locationConsumer is currently tracking
    /// Set this to `false` to stop tracking
    /// Set this to `true` to start tracking
    var shouldTrackLocation: Bool { get set }

    /// New location update received
    func locationUpdate(newLocation: Location)
}
