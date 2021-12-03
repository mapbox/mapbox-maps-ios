/// Errors related to MapProjection API
@_spi(Experimental) public enum MapProjectionError: Error {
    case unsupportedProjection
}

/// Describes the projection used to render the map.
///
/// Mapbox map supports Mercator and Globe projections.
@_spi(Experimental) public enum MapProjection: Codable, Hashable {
    // Wraps `MercatorMapProjection`
    case mercator(_ projection: MercatorMapProjection = MercatorMapProjection())

    // Wraps `GlobeMapProjection`
    case globe(_ projection: GlobeMapProjection = GlobeMapProjection())

    /// Name of the wrapped projection
    public var name: String {
        switch self {
        case .mercator(let projection):
            return projection.name
        case .globe(let projection):
            return projection.name
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .mercator(let projection):
            try container.encode(projection)
        case .globe(let projection):
            try container.encode(projection)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let projection = try? container.decode(GlobeMapProjection.self) {
            self = .globe(projection)
        } else if let projection = try? container.decode(MercatorMapProjection.self) {
            self = .mercator(projection)
        } else {
            throw MapProjectionError.unsupportedProjection
        }
    }
}

/// Mercator projection.
///
/// Mercator projection description: https://en.wikipedia.org/wiki/Mercator_projection
@_spi(Experimental) public struct MercatorMapProjection: Codable, Hashable {
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
                codingPath: container.codingPath + [CodingKeys.name],
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
///  - custom
///  - fill extrusion
///  - location indicator
///
/// If Globe projection is set it will be switched automatically to Mercator projection
/// when passing `GlobeMapProjection.transitionZoomLevel` during zooming in.
///
/// See `GlobeMapProjection.transitionZoomLevel` for more details what projection will be used depending on current zoom level.
@_spi(Experimental) public struct GlobeMapProjection: Codable, Hashable {
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
                codingPath: container.codingPath + [CodingKeys.name],
                debugDescription: "Decoded projection name doesn't match expected value"
            ))
        }
    }

    /// Zoom level threshold where `MapboxMap` will automatically switch projection
    /// from `MapProjection.mercator` to `MapProjection.globe` or vice-versa
    /// if `MapboxMap.setMapProjection` was configured to use `MapProjection.globe`.
    ///
    /// If `MapboxMap` is using `MapProjection.globe` and current map zoom level is >= `GlobeMapProjection.transitionZoomLevel` -
    /// map will use `MapProjection.mercator` and `MapboxMap.getMapProjection` will return `MapProjection.mercator`.
    ///
    /// If `MapboxMap` is using `MapProjection.globe` and current map zoom level is < `GlobeMapProjection.transitionZoomLevel` -
    /// map will use `MapProjection.globe` and `MapboxMap.getMapProjection` will return `MapProjection.globe`.
    ///
    /// If `MapboxMap` is using `MapProjection.mercator` - map will use `MapProjection.mercator` for any zoom level and
    /// `MapboxMap.getMapProjection` will return `MapProjection.mercator`.
    public static let transitionZoomLevel: CGFloat = 5.0
}
