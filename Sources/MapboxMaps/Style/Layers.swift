import Foundation
import MapboxCoreMaps

/// Layer rendering types
public enum LayerType: String, Codable {
    /// A filled polygon with an optional stroked border.
    case fill = "fill"

    /// A stroked line.
    case line = "line"

    /// An icon or a text label.
    case symbol = "symbol"

    /// A filled circle.
    case circle = "circle"

    /// A heatmap.
    case heatmap = "heatmap"

    /// An extruded (3D) polygon.
    case fillExtrusion = "fill-extrusion"

    /// Raster map textures such as satellite imagery.
    case raster = "raster"

    /// Client-side hillshading visualization based on DEM data.
    /// Currently, the implementation only supports Mapbox Terrain RGB and Mapzen Terrarium tiles.
    case hillshade = "hillshade"

    /// The background color or pattern of the map.
    case background = "background"

    /// Layer representing the location indicator
    case locationIndicator = "location-indicator"

    /// Layer representing the sky
    case sky = "sky"

    /// Layer used for a 3D model
    case model = "model"
}

public protocol Layer: Codable, StyleEncodable, StyleDecodable {
    /// Unique layer name
    var id: String { get set }

    /// Rendering type of this layer.
    var type: LayerType { get set }

    /// A expression specifying conditions on source features.
    /// Only features that match the filter are displayed.
    var filter: Expression? { get set }

    /// Name of a source description to be used for this layer.
    /// Required for all layer types except background.
    var source: String? { get set }

    /// Layer to use from a vector tile source.
    /// Required for vector tile sources/
    /// Prohibited for all other source types, including GeoJSON sources.
    var sourceLayer: String? { get set }

    /// The minimum zoom level for the layer. At zoom levels less than the minzoom, the layer will be hidden.
    var minZoom: Double? { get set }

    /// The maximum zoom level for the layer. At zoom levels equal to or greater than the maxzoom, the layer will be hidden.
    var maxZoom: Double? { get set }
}

public extension Layer {
    /// Initializes a Layer given a JSON dictionary
    /// - Throws: Errors occurring during decoding
    init(jsonObject: [String: AnyObject]) throws {
        let layerData = try JSONSerialization.data(withJSONObject: jsonObject)
        self = try JSONDecoder().decode(Self.self, from: layerData)
    }
}

public extension LayerPosition {
    convenience init(above: String? = nil, below: String? = nil, at: Int? = nil) {
        self.init(__above: above, below: below, at: at?.NSNumber)
    }
}
