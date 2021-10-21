import Foundation
import CoreLocation

/// Represents the different types of pucks
public enum PuckType: Equatable {
    /// A 2-dimensional puck. Optionally provide `Puck2DConfiguration` to configure the puck's appearance.
    case puck2D(Puck2DConfiguration = Puck2DConfiguration())

    /// A 3-dimensional puck. Provide a `Puck3DConfiguration` to configure the puck's appearance.
    case puck3D(Puck3DConfiguration)
}

/// Controls how the puck is oriented
public enum PuckBearingSource: Equatable {
    /// The puck should set its bearing using `heading: CLHeading`
    case heading

    /// The puck should set its bearing using `course: CLLocationDirection`
    case course
}

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

    public init() {}

}
