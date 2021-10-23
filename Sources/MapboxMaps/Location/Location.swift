import Foundation
import CoreLocation

@objc public class Location: NSObject {

    public let heading: CLHeading?

    public let location: CLLocation

    /// A conveninece accessor for `location.coordinate`
    public var coordinate: CLLocationCoordinate2D {
        return location.coordinate
    }

    /// A convenience accessor for `location.course`
    public var course: CLLocationDirection {
        return location.course
    }

    /// A conveninece accessor for `location.horizontalAccuracy`
    public var horizontalAccuracy: CLLocationAccuracy {
        return location.horizontalAccuracy
    }

    /// Returns `nil` if `heading` is `nil`, `heading.trueHeading` if it's non-negative,
    /// and `heading.magneticHeading` otherwise.
    public var headingDirection: CLLocationDirection? {
        guard let heading = heading else {
            return nil
        }
        guard heading.trueHeading >= 0 else {
            return heading.magneticHeading
        }
        return heading.trueHeading
    }

    /// Initialize a `Location`. Deprecated. Use `init(location:heading:)` instead.
    public init(with location: CLLocation, heading: CLHeading? = nil) {
        self.location = location
        self.heading = heading
    }

    /// Initialize a `Location`
    public init(location: CLLocation, heading: CLHeading?) {
        self.location = location
        self.heading = heading
    }
}
