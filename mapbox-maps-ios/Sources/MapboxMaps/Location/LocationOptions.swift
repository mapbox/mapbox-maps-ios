import Foundation
import CoreLocation

/// A struct to configure a `LocationManager`
public struct LocationOptions: Equatable {

    /// Specifies the minimum distance (measured in meters) a device must move horizontally
    /// before a location update is generated.
    ///
    /// The default value of this property is `kCLDistanceFilterNone`.
    public var distanceFilter: CLLocationDistance

    /// Specifies the accuracy of the location data.
    ///
    /// The default value is `kCLLocationAccuracyBest`.
    public var desiredAccuracy: CLLocationAccuracy

    /// Sets the type of user activity associated with the location updates.
    ///
    /// The default value is `CLActivityType.other`.
    public var activityType: CLActivityType

    /// Sets the type of puck that should be used
    public var puckType: PuckType?

    /// Specifies if a `Puck` should use `Heading` or `Course` for the bearing.
    ///
    /// The default value is `PuckBearing.heading`.
    public var puckBearing: PuckBearing

    /// Whether the puck rotates to track the bearing source.
    ///
    /// The default value is `true`.
    public var puckBearingEnabled: Bool

    /// Initializes a `LocationOptions`.
    /// - Parameters:
    ///   - distanceFilter: Specifies the minimum distance (measured in meters) a device must move horizontally
    /// before a location update is generated.
    ///   - desiredAccuracy: Specifies the accuracy of the location data.
    ///   - activityType: Sets the type of user activity associated with the location.
    ///   - puckType: Sets the type of puck that should be used.
    ///   - puckBearing: Specifies if a `Puck` should use `Heading` or `Course` for the bearing.
    ///   - puckBearingEnabled: Whether the puck rotates to track the bearing source.
    public init(
        distanceFilter: CLLocationDistance = kCLDistanceFilterNone,
        desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest,
        activityType: CLActivityType = .other,
        puckType: PuckType? = nil,
        puckBearing: PuckBearing = .heading,
        puckBearingEnabled: Bool = true
    ) {
        self.distanceFilter = distanceFilter
        self.desiredAccuracy = desiredAccuracy
        self.activityType = activityType
        self.puckType = puckType
        self.puckBearing = puckBearing
        self.puckBearingEnabled = puckBearingEnabled
    }
}

/// Controls how the puck is oriented
public enum PuckBearing: Equatable {
    /// The puck should set its bearing using `heading: CLHeading`. Bearing will mimic user's
    /// spatial orientation.
    case heading

    /// The puck should set its bearing using `course: CLLocationDirection`. Bearing will mimic
    /// the general direction of travel.
    case course
}

/// :nodoc:
@available(*, deprecated, renamed: "PuckBearing")
public typealias PuckBearingSource = PuckBearing

// MARK: Deprecated

extension LocationOptions {

    /// :nodoc:
    @available(*, deprecated, renamed: "puckBearing")
    public var puckBearingSource: PuckBearingSource {
        get { puckBearing }
        set { puckBearing = newValue }
    }

    /// :nodoc:
    @available(*, deprecated, renamed: "LocationOptions.init(distanceFilter:desiredAccuracy:activityType:puckType:puckBearing:puckBearingEnabled:)")
    public init(
        distanceFilter: CLLocationDistance = kCLDistanceFilterNone,
        desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest,
        activityType: CLActivityType = .other,
        puckType: PuckType? = nil,
        puckBearingSource: PuckBearingSource,
        puckBearingEnabled: Bool = true
    ) {
        self.distanceFilter = distanceFilter
        self.desiredAccuracy = desiredAccuracy
        self.activityType = activityType
        self.puckType = puckType
        self.puckBearing = puckBearingSource
        self.puckBearingEnabled = puckBearingEnabled
    }
}
