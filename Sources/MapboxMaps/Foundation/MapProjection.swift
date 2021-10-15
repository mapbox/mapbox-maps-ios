/// Describes the projection used to render the map.
///
/// Mapbox map supports Mercator and Globe projections.
@_spi(Experimental) public protocol MapProjectionOption: Codable {
    var name: String { get }
}

/// Mercator projection.
///
/// Mercator projection description: https://en.wikipedia.org/wiki/Mercator_projection
@_spi(Experimental) public struct MercatorMapProjection: MapProjectionOption {
    public let name = "mercator"

    enum CodingKeys: String, CodingKey {
        case name
    }

    public init() {}

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        guard name == self.name else {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Decoded projection name doesn't match expected value"
            ))
        }
    }
}

/// Globe projection is a custom map projection mode for rendering the map wrapped around a full 3D globe.
/// Conceptually it is the undistorted and unskewed “ground truth” view of the map
/// that preserves true proportions between different areas of the map.
///
/// Some layers are not supported when map is in Globe projection:
///  - circle
///  - custom
///  - fill extrusion
///  - heatmap
///  - location indicator
///
/// If Globe projection is set it will be switched automatically to Mercator projection
/// when passing `GlobeMapProjection.transitionZoomLevel` during zooming in.
///
/// See `GlobeMapProjection.transitionZoomLevel` for more details what projection will be used depending on current zoom level.
@_spi(Experimental) public struct GlobeMapProjection: MapProjectionOption {
    public let name = "globe"

    enum CodingKeys: String, CodingKey {
        case name
    }

    public init() {}

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        guard name == self.name else {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Decoded projection name doesn't match expected value"
            ))
        }
    }

    /// Zoom level threshold where MapboxMap will automatically switch projection
    /// from `MercatorMapProjection` to `MapProjection.globe` or vice-versa
    /// if MapboxMap.setMapProjection was configured to use `MapProjection.globe`.
    ///
    /// If MapboxMap is using `GlobeMapProjection` and current map zoom level is >= `GlobeMapProjection.transitionZoomLevel` -
    /// map will use `MercatorMapProjection` and MapboxMap.getMapProjection will return `MercatorMapProjection`.
    ///
    /// If MapboxMap is using `GlobeMapProjection` and current map zoom level is < `GlobeMapProjection.transitionZoomLevel` -
    /// map will use `MapProjection.globe` and MapboxMap.getMapProjection will return `MapProjection.globe`.
    ///
    /// If MapboxMap is using `MercatorMapProjection` - map will use `MercatorMapProjection` for any zoom level and
    /// MapboxMap.getMapProjection will return `MercatorMapProjection`.
    public static let transitionZoomLevel: CGFloat = 5.0
}
