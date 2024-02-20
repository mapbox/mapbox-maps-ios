/// Represents the interpolated data ready to render the user location puck.
public struct PuckRenderingData: Equatable {
    /// Puck's location.
    public var location: Location

    /// Puck's heading.
    public var heading: Heading?

    /// Creates a puck rendering data.
    public init(
        location: Location,
        heading: Heading? = nil
    ) {
        self.location = location
        self.heading = heading
    }
}

extension PuckRenderingData {
    init(locationChange: LocationChange) {
        self.location = locationChange.location
        self.heading = locationChange.heading
    }
}
