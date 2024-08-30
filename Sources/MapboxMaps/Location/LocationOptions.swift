import Foundation
import CoreLocation

/// A struct to configure a `LocationManager`
public struct LocationOptions: Equatable {

    /// Specifies the minimum distance (measured in meters) a device must move horizontally
    /// before a location update is generated.
    ///
    /// The default value of this property is `kCLDistanceFilterNone`.
    @available(*, unavailable, message: "Use AppleLocationProvider.Options.distanceFilter instead")
    public var distanceFilter: CLLocationDistance { kCLDistanceFilterNone }

    /// Specifies the accuracy of the location data.
    ///
    /// The default value is `kCLLocationAccuracyBest`.
    @available(*, unavailable, message: "Use AppleLocationProvider.Options.desiredAccuracy instead")
    public var desiredAccuracy: CLLocationAccuracy { kCLLocationAccuracyBest }

    /// Sets the type of user activity associated with the location updates.
    ///
    /// The default value is `CLActivityType.other`.
    @available(*, unavailable, message: "Use AppleLocationProvider.Options.activityType instead")
    public var activityType: CLActivityType { .other }

    /// Sets the type of puck that should be used
    public var puckType: PuckType?

    /// Specifies if a `Puck` should use `Heading` or `Course` for the bearing.
    ///
    /// The default value is `PuckBearing.heading`.
    public var puckBearing: PuckBearing

    /// Whether the puck rotates to track the bearing source.
    ///
    /// The default value is `false`.
    public var puckBearingEnabled: Bool

    /// Initializes a `LocationOptions`.
    /// - Parameters:
    ///   - puckType: Sets the type of puck that should be used.
    ///   - puckBearing: Specifies if a `Puck` should use `Heading` or `Course` for the bearing.
    ///   - puckBearingEnabled: Whether the puck rotates to track the bearing source.
    public init(
        puckType: PuckType? = nil,
        puckBearing: PuckBearing = .heading,
        puckBearingEnabled: Bool = false
    ) {
        self.puckType = puckType
        self.puckBearing = puckBearing
        self.puckBearingEnabled = puckBearingEnabled
    }
}

/// Controls how the puck is oriented
public enum PuckBearing: Equatable, Sendable {
    /// The puck should set its bearing using `heading: CLHeading`. Bearing will mimic user's
    /// spatial orientation.
    ///
    /// - Note: On visionOS, the heading-based puck bearing is not supported by default.
    /// You can supply your custom data via the ``HeadingProvider`` in ``LocationManager`` to make it work.
    case heading

    /// The puck should set its bearing using `course: CLLocationDirection`. Bearing will mimic
    /// the general direction of travel.
    case course
}
