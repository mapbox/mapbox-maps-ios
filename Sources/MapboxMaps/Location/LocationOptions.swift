import Foundation
import CoreLocation

/// A struct to configure a `LocationManager`
public struct LocationOptions: Equatable {

    /// Specifies the minimum distance (measured in meters) a device must move horizontally
    /// before a location update is generated.

    /// The default value of this property is `kCLDistanceFilterNone`.
    public var distanceFilter: CLLocationDistance = kCLDistanceFilterNone

    /// Specifies the accuracy of the location data.
    /// The default value is `kCLLocationAccuracyBest`.
    public var desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest

    /// Sets the type of user activity associated with the location updates.
    /// The default value is `CLActivityType.other`.
    public var activityType: CLActivityType = .other

    /// Sets the type of puck that should be used
    public var puckType: PuckType?

    /// Specifies if a `Puck` should use `Heading` or `Course` for the bearing
    /// This is an experimental option. The default value is `PuckBearingSource.heading`.
    public var puckBearingSource: PuckBearingSource = .heading

    /// Whether the puck rotates to track the bearing source.
    public var puckBearingEnabled: Bool = true

    public init() {}
}

/// Controls how the puck is oriented
public enum PuckBearingSource: Equatable {
    /// The puck should set its bearing using `heading: CLHeading`
    case heading

    /// The puck should set its bearing using `course: CLLocationDirection`
    case course
}
