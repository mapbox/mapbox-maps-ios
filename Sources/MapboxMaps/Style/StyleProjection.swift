/// Describes the projection used to render the map.
public struct StyleProjection: Hashable, Codable {

    /// The name of the projection.
    public var name: StyleProjectionName

    /// Initializes a projection
    public init(name: StyleProjectionName) {
        self.name = name
    }

    internal enum CodingKeys: String, CodingKey {
        case name
    }
}

/// The name of a style projection as defined in the Mapbox Style Spec
public struct StyleProjectionName: RawRepresentable, Hashable, Codable {

    /// The style projection's rawValue string
    public var rawValue: String

    /// Initializes a `StyleProjectionName` with a string
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// The name of the mercator projection
    ///
    /// Mercator projection description: https://en.wikipedia.org/wiki/Mercator_projection
    public static let mercator = StyleProjectionName(rawValue: "mercator")

    /// The name of the globe projection
    ///
    /// Globe projection is a custom map projection mode for rendering the map wrapped around a full 3D globe.
    /// Conceptually it is the undistorted and unskewed “ground truth” view of the map
    /// that preserves true proportions between different areas of the map.
    ///
    /// Some layers are not supported when map is in globe projection:
    ///  - custom
    ///  - fill extrusion
    ///  - location indicator
    public static let globe = StyleProjectionName(rawValue: "globe")
}
