import Foundation
import MapboxCoreMaps

/// Struct of supported Layer rendering types
public struct LayerType: ExpressibleByStringLiteral, RawRepresentable, Codable, Hashable, Sendable {

    /// The raw value of the layer type.
    public let rawValue: String

    /// A filled polygon with an optional stroked border.
    public static let fill: LayerType = "fill"

    /// A stroked line.
    public static let line: LayerType = "line"

    /// An icon or a text label.
    public static let symbol: LayerType = "symbol"

    /// A filled circle.
    public static let circle: LayerType = "circle"

    /// A heatmap.
    public static let heatmap: LayerType = "heatmap"

    /// A clip layer.
    public static let clip: LayerType = "clip"

    /// An extruded (3D) polygon.
    public static let fillExtrusion: LayerType = "fill-extrusion"

    /// Raster map textures such as satellite imagery.
    public static let raster: LayerType = "raster"

    /// Layer repsenting particles on the map.
    public static let rasterParticle: LayerType = "raster-particle"

    /// Client-side hillshading visualization based on DEM data.
    /// Currently, the implementation only supports Mapbox Terrain RGB and Mapzen Terrarium tiles.
    public static let hillshade: LayerType = "hillshade"

    /// The background color or pattern of the map.
    public static let background: LayerType = "background"

    /// Layer representing the location indicator
    public static let locationIndicator: LayerType = "location-indicator"

    /// Layer representing the sky
    public static let sky: LayerType = "sky"

    /// Layer representing a place for other layers.
    public static let slot: LayerType = "slot"

    /// Layer used for a 3D model
    @_documentation(visibility: public)
    @_spi(Experimental)
    public static let model: LayerType = "model"

    /// Layer with custom rendering implementation (``CustomLayerHost``)
    ///
    /// - SeeAlso: ``CustomLayer``
    public static let custom: LayerType = "custom"

    public init(stringLiteral type: String) {
        self.rawValue = type
    }

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// The associated Swift struct type
    public var layerType: Layer.Type? {
        switch self {
        case .fill:
            return FillLayer.self
        case .line:
            return LineLayer.self
        case .symbol:
            return SymbolLayer.self
        case .circle:
            return CircleLayer.self
        case .heatmap:
            return HeatmapLayer.self
        case .fillExtrusion:
            return FillExtrusionLayer.self
        case .raster:
            return RasterLayer.self
        case .hillshade:
            return HillshadeLayer.self
        case .background:
            return BackgroundLayer.self
        case .locationIndicator:
            return LocationIndicatorLayer.self
        case .sky:
            return SkyLayer.self
        case .model:
            return ModelLayer.self
        case .custom:
            return CustomLayer.self
        default:
            return nil
        }
    }
}
