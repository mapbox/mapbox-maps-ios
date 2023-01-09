public protocol Layer: Codable, StyleEncodable, StyleDecodable {
    /// Unique layer name
    var id: String { get set }

    /// Rendering type of this layer.
    var type: LayerType { get }

    /// An expression specifying conditions on source features.
    /// Only features that match the filter are displayed.
    var filter: Expression? { get set }

    /// Name of a source description to be used for this layer.
    /// Required for all layer types except background.
    var source: String? { get set }

    /// Layer to use from a vector tile source.
    /// Required for vector tile sources.
    /// Prohibited for all other source types, including GeoJSON sources.
    var sourceLayer: String? { get set }

    /// The minimum zoom level for the layer. At zoom levels less than the minzoom, the layer will be hidden.
    var minZoom: Double? { get set }

    /// The maximum zoom level for the layer. At zoom levels equal to or greater than the maxzoom, the layer will be hidden.
    var maxZoom: Double? { get set }
}

extension Layer {
    /// Initializes a Layer given a JSON dictionary
    /// - Throws: Errors occurring during decoding
    public init(jsonObject: [String: Any]) throws {
        let layerData = try JSONSerialization.data(withJSONObject: jsonObject)
        self = try JSONDecoder().decode(Self.self, from: layerData)
    }
}
