import Foundation
import CoreLocation

/// The azimuth (orientation) of the user’s device, relative to true or magnetic north.
public struct Heading: Equatable, Sendable {
    /// The heading direction (measured in degrees) relative to true or magnetic north.
    ///
    /// When heading is created from CLHeading, this value resolves to `trueHeading` (priority, if valid)
    /// or `magneticHeading`.
    public var direction: CLLocationDirection

    /// The maximum deviation (measured in degrees) between the reported heading and the true geomagnetic heading.
    public var accuracy: CLLocationDirection

    ///The time at which this heading was determined.
    public var timestamp: Date

    /// Creates a heading.
    public init(direction: CLLocationDirection,
                accuracy: CLLocationDirection,
                timestamp: Date = Date()) {
        self.direction = direction
        self.accuracy = accuracy
        self.timestamp = timestamp
    }

    /// Creates a heading from CLHeading.
#if swift(>=5.9)
    @available(visionOS, unavailable)
#endif
    public init(from clHeading: CLHeading) {
        var direction = clHeading.trueHeading
        if direction < 0 {
            direction = clHeading.magneticHeading
        }
        self.init(
            direction: direction,
            accuracy: clHeading.headingAccuracy,
            timestamp: clHeading.timestamp
        )
    }
}
