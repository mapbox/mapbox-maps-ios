import Foundation

/// Struct of supported Source Types
/// Docs : https://docs.mapbox.com/mapbox-gl-js/style-spec/sources/
public struct SourceType: ExpressibleByStringLiteral, RawRepresentable, Codable, Hashable, Sendable {

    /// The raw value of the source type.
    public let rawValue: String

    /// A vector tile source.
    public static let vector: SourceType = "vector"

    /// A raster tile source.
    public static let raster: SourceType = "raster"

    /// A raster DEM source.
    public static let rasterDem: SourceType = "raster-dem"

    /// A GeoJSON source.
    public static let geoJson: SourceType = "geojson"

    /// An image source.
    public static let image: SourceType = "image"

    /// A model source.
    public static let model: SourceType = "model"

    /// A raster array tile source.
    @_spi(Experimental)
    public static let rasterArray: SourceType = "raster-array"

    /// A custom geometry source.
    public static let customGeometry: SourceType = "custom-geometry"

    /// A custom raster source.
    @_spi(Experimental)
    public static let customRaster: SourceType = "custom-raster"

    public init(stringLiteral type: String) {
        self.rawValue = type
    }

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// The associated Swift struct type
    public var sourceType: Source.Type? {
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
        case .customGeometry:
            return CustomGeometrySource.self
        case .customRaster:
            return CustomRasterSource.self
        default:
            return nil
        }
    }
}
