import Foundation

/// Enum of Source Types
/// Docs : https://docs.mapbox.com/mapbox-gl-js/style-spec/sources/
public enum SourceType: String, Codable {
    /// A vector tile source.
    case vector = "vector"

    /// A raster tile source.
    case raster = "raster"

    /// A raster DEM source.
    case rasterDem = "raster-dem"

    /// A GeoJSON source.
    case geoJson = "geojson"

    /// An image source.
    case image = "image"

    /// A model source
    case model = "model"

    internal enum CodingKeys: String, CodingKey {
        case vector = "vector"
        case raster = "raster"
        case rasterDem = "raster-dem"
        case geojson = "geojson"
        case image = "image"
        case model = "model"
    }

    /// The associated Swift struct type
    public var sourceType: Source.Type {
        switch self {
        case .vector:
            return VectorSource.self
        case .raster:
            return RasterSource.self
        case .rasterDem:
            return RasterDemSource.self
        case .geoJson:
            return GeoJSONSource.self
        case .image:
            return ImageSource.self
        case .model:
            return ModelSource.self
        }
    }
}

public protocol Source: Codable, StyleEncodable, StyleDecodable {
    /// Rendering type of this source.
    var type: SourceType { get set }
}

public extension Source {
    /// Initializes a Source given a JSON dictionary
    /// - Throws: Errors occurring during decoding
    init(jsonObject: [String: Any]) throws {
        let sourceData = try JSONSerialization.data(withJSONObject: jsonObject)
        self = try JSONDecoder().decode(Self.self, from: sourceData)
    }
}

/// Information about a Source
public struct SourceInfo {
    /// The identifier of the source
    public var id: String

    /// The type of the source
    public var type: SourceType
}
