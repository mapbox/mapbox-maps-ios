import Foundation
import CoreLocation

/// Instances of this class are delivered to `LocationConsumer`s by `LocationManager` whenever
/// the heading, location, or accuracy authorization change.
@objc public class Location: NSObject {

    /// A heading value. May be used directly or via the higher-level `headingDirection` property.
    public let heading: CLHeading?

    /// A location value. May be used directly or via the convenience accessors `coordinate`, `course`, and `horizontalAccuracy`.
    public let location: CLLocation

    /// A conveninece accessor for `location.coordinate`
    public var coordinate: CLLocationCoordinate2D {
        return location.coordinate
    }

    /// A convenience accessor for `location.course`
    public var course: CLLocationDirection {
        return location.course
    }

    /// A convenience accessor for `location.horizontalAccuracy`
    public var horizontalAccuracy: CLLocationAccuracy {
        return location.horizontalAccuracy
    }

    /// Returns `nil` if `heading` is `nil`, `heading.trueHeading` if it's non-negative,
    /// and `heading.magneticHeading` otherwise.
    public var headingDirection: CLLocationDirection? {
        return heading.map { $0.trueHeading >= 0 ? $0.trueHeading : $0.magneticHeading }
    }

    /// An accuracy authorization value.
    public let accuracyAuthorization: CLAccuracyAuthorization

    /// :nodoc:
    /// Deprecated. Initialize a `Location`. Use `init(location:heading:accuracyAuthorization:)` instead.
    public init(with location: CLLocation, heading: CLHeading? = nil) {
        self.location = location
        self.heading = heading
        self.accuracyAuthorization = .fullAccuracy
    }

    /// Initialize a `Location`
    public init(location: CLLocation,
                heading: CLHeading?,
                accuracyAuthorization: CLAccuracyAuthorization) {
        self.location = location
        self.heading = heading
        self.accuracyAuthorization = accuracyAuthorization
    }
}
