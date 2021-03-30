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

    /// A video source.
    case video = "video"

    /// A model source
    case model = "model"

    internal enum CodingKeys: String, CodingKey {
        case vector = "vector"
        case raster = "raster"
        case rasterDem = "raster-dem"
        case geojson = "geojson"
        case image = "image"
        case video = "video"
        case model = "model"
    }
}

public protocol Source: Codable, StyleEncodable { }
