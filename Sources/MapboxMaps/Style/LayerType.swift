import Foundation
import MapboxCoreMaps

/// Layer rendering types
public enum LayerType: String, Codable {
    /// A filled polygon with an optional stroked border.
    case fill

    /// A stroked line.
    case line

    /// An icon or a text label.
    case symbol

    /// A filled circle.
    case circle

    /// A heatmap.
    case heatmap

    /// An extruded (3D) polygon.
    case fillExtrusion = "fill-extrusion"

    /// Raster map textures such as satellite imagery.
    case raster

    /// Client-side hillshading visualization based on DEM data.
    /// Currently, the implementation only supports Mapbox Terrain RGB and Mapzen Terrarium tiles.
    case hillshade

    /// The background color or pattern of the map.
    case background

    /// Layer representing the location indicator
    case locationIndicator = "location-indicator"

    /// Layer representing the sky
    case sky

    @available(*, deprecated, message: "Unsupported layer type")
    case model

    public init?(rawValue: String) {
        let supportedTypes: [LayerType] = [
            .fill,
            .line,
            .symbol,
            .circle,
            .heatmap,
            .fillExtrusion,
            .raster,
            .hillshade,
            .background,
            .locationIndicator,
            .sky,
            .model,
        ]

        guard let matchingCase = supportedTypes.first(where: { $0.rawValue == rawValue }) else {
            return nil
        }

        self = matchingCase
    }

    /// The associated Swift struct type
    public var layerType: Layer.Type {
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
        }
    }
}
