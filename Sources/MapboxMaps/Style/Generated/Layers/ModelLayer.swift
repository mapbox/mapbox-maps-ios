// This file is generated.
import Foundation

/// A layer to render 3D Models.
@_spi(Experimental) public struct ModelLayer: Layer {

    // MARK: - Conformance to `Layer` protocol
    public var id: String
    public let type: LayerType
    public var filter: Expression?
    public var source: String?
    public var sourceLayer: String?
    public var minZoom: Double?
    public var maxZoom: Double?

    /// Whether this layer is displayed.
    public var visibility: Value<Visibility>?

    /// Model to render.
    public var modelId: Value<String>?

    /// The rotation of the model in euler angles [lon, lat, z].
    public var modelRotation: Value<[Double]>?

    /// Transition options for `modelRotation`.
    public var modelRotationTransition: StyleTransition?

    /// The scale of the model.
    public var modelScale: Value<[Double]>?

    /// Transition options for `modelScale`.
    public var modelScaleTransition: StyleTransition?

    /// Defines rendering behavior of model in respect to other 3D scene objects.
    public var modelType: Value<ModelType>?

    internal var modelOpacity: Value<Double>?

    public init(id: String) {
        self.id = id
        self.type = LayerType.model
        self.visibility = .constant(.visible)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RootCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(filter, forKey: .filter)
        try container.encodeIfPresent(source, forKey: .source)
        try container.encodeIfPresent(sourceLayer, forKey: .sourceLayer)
        try container.encodeIfPresent(minZoom, forKey: .minZoom)
        try container.encodeIfPresent(maxZoom, forKey: .maxZoom)

        var paintContainer = container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint)
        try paintContainer.encodeIfPresent(modelRotation, forKey: .modelRotation)
        try paintContainer.encodeIfPresent(modelRotationTransition, forKey: .modelRotationTransition)
        try paintContainer.encodeIfPresent(modelScale, forKey: .modelScale)
        try paintContainer.encodeIfPresent(modelScaleTransition, forKey: .modelScaleTransition)
        try paintContainer.encodeIfPresent(modelType, forKey: .modelType)

        try paintContainer.encodeIfPresent(modelOpacity, forKey: .modelOpacity)

        var layoutContainer = container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)
        try layoutContainer.encodeIfPresent(visibility, forKey: .visibility)
        try layoutContainer.encodeIfPresent(modelId, forKey: .modelId)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootCodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(LayerType.self, forKey: .type)
        filter = try container.decodeIfPresent(Expression.self, forKey: .filter)
        source = try container.decodeIfPresent(String.self, forKey: .source)
        sourceLayer = try container.decodeIfPresent(String.self, forKey: .sourceLayer)
        minZoom = try container.decodeIfPresent(Double.self, forKey: .minZoom)
        maxZoom = try container.decodeIfPresent(Double.self, forKey: .maxZoom)

        if let paintContainer = try? container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint) {
            modelRotation = try paintContainer.decodeIfPresent(Value<[Double]>.self, forKey: .modelRotation)
            modelRotationTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .modelRotationTransition)
            modelScale = try paintContainer.decodeIfPresent(Value<[Double]>.self, forKey: .modelScale)
            modelScaleTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .modelScaleTransition)
            modelType = try paintContainer.decodeIfPresent(Value<ModelType>.self, forKey: .modelType)
        }

        if let layoutContainer = try? container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout) {
            visibility = try layoutContainer.decodeIfPresent(Value<Visibility>.self, forKey: .visibility)
            modelId = try layoutContainer.decodeIfPresent(Value<String>.self, forKey: .modelId)
        }
    }

    enum RootCodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case filter = "filter"
        case source = "source"
        case sourceLayer = "source-layer"
        case minZoom = "minzoom"
        case maxZoom = "maxzoom"
        case layout = "layout"
        case paint = "paint"
    }

    enum LayoutCodingKeys: String, CodingKey {
        case modelId = "model-id"
        case visibility = "visibility"
    }

    enum PaintCodingKeys: String, CodingKey {
        case modelRotation = "model-rotation"
        case modelRotationTransition = "model-rotation-transition"
        case modelScale = "model-scale"
        case modelScaleTransition = "model-scale-transition"
        case modelType = "model-type"

        case modelOpacity = "model-opacity"
    }
}

// End of generated file.
