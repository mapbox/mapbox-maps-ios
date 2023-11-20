public protocol Layer: Codable, StyleEncodable, StyleDecodable {
    /// Unique layer name
    var id: String { get set }

    /// Rendering type of this layer.
    var type: LayerType { get }

    /// Whether this layer is displayed.
    var visibility: Value<Visibility> { get set }

    /// The minimum zoom level for the layer. At zoom levels less than the minzoom, the layer will be hidden.
    var minZoom: Double? { get set }

    /// The maximum zoom level for the layer. At zoom levels equal to or greater than the maxzoom, the layer will be hidden.
    var maxZoom: Double? { get set }

    /// The slot this layer is assigned to. If specified, and a slot with that name exists, it will be placed at that position in the layer order.
    var slot: Slot? { get set }
}

extension Layer {
    /// Initializes a Layer given a JSON dictionary
    /// - Throws: Errors occurring during decoding
    public init(jsonObject: [String: Any]) throws {
        let layerData = try JSONSerialization.data(withJSONObject: jsonObject)
        self = try JSONDecoder().decode(Self.self, from: layerData)
    }
}
