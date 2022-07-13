// This file is generated.
import Foundation

/// A layer to render 3D Models.
@_spi(Experimental) public struct ModelLayer: Layer {

    // MARK: - Conformance to `Layer` protocol
    public var id: String
    public let type: LayerType
    public var filter: Expression? {
        didSet { modifiedProperties.insert(RootCodingKeys.filter.rawValue) }
    }
    public var source: String? {
        didSet { modifiedProperties.insert(RootCodingKeys.source.rawValue) }
    }

    public var sourceLayer: String? {
        didSet { modifiedProperties.insert(RootCodingKeys.sourceLayer.rawValue) }
    }
    public var minZoom: Double? {
        didSet { modifiedProperties.insert(RootCodingKeys.minZoom.rawValue) }
    }
    public var maxZoom: Double? {
        didSet { modifiedProperties.insert(RootCodingKeys.maxZoom.rawValue) }
    }

    /// Whether this layer is displayed.
    public var visibility: Value<Visibility>?

    /// Model to render.
    public var modelId: Value<String>?

    /// Enable/Disable shadow casting for this layer
    public var modelCastShadows: Value<Bool>?

    /// The tint color of the model layer. model-color-mix-intensity (defaults to 0) defines tint(mix) intensity - this means that, this color is not used unless model-color-mix-intensity gets value greater than 0.
    public var modelColor: Value<StyleColor>?

    /// Transition options for `modelColor`.
    public var modelColorTransition: StyleTransition?

    /// Intensity of model-color (on a scale from 0 to 1) in color mix with original 3D model's colors. Higher number will present a higher model-color contribution in mix.
    public var modelColorMixIntensity: Value<Double>?

    /// Transition options for `modelColorMixIntensity`.
    public var modelColorMixIntensityTransition: StyleTransition?

    /// The opacity of the model layer.
    public var modelOpacity: Value<Double>?

    /// Transition options for `modelOpacity`.
    public var modelOpacityTransition: StyleTransition?

    /// The rotation of the model in euler angles [lon, lat, z].
    public var modelRotation: Value<[Double]>?

    /// Transition options for `modelRotation`.
    public var modelRotationTransition: StyleTransition?

    /// The scale of the model.
    public var modelScale: Value<[Double]>?

    /// Transition options for `modelScale`.
    public var modelScaleTransition: StyleTransition?

    /// The translation of the model in meters in form of [longitudal, latitudal, altitude] offsets.
    public var modelTranslation: Value<[Double]>?

    /// Transition options for `modelTranslation`.
    public var modelTranslationTransition: StyleTransition?

    /// Defines rendering behavior of model in respect to other 3D scene objects.
    public var modelType: Value<ModelType>?

    private var modifiedProperties = Set<String>()

    public init(id: String) {
        self.id = id
        self.type = LayerType.model
        self.visibility = .constant(.visible)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RootCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try encodeIfModified(filter, forKey: .filter, to: &container)
        try encodeIfModified(source, forKey: .source, to: &container)
        try encodeIfModified(sourceLayer, forKey: .sourceLayer, to: &container)
        try encodeIfModified(minZoom, forKey: .minZoom, to: &container)
        try encodeIfModified(maxZoom, forKey: .maxZoom, to: &container)

        var paintContainer = container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint)
        try paintContainer.encode(modelCastShadows, forKey: .modelCastShadows)
        try paintContainer.encode(modelColor, forKey: .modelColor)
        try paintContainer.encode(modelColorTransition, forKey: .modelColorTransition)
        try paintContainer.encode(modelColorMixIntensity, forKey: .modelColorMixIntensity)
        try paintContainer.encode(modelColorMixIntensityTransition, forKey: .modelColorMixIntensityTransition)
        try paintContainer.encode(modelOpacity, forKey: .modelOpacity)
        try paintContainer.encode(modelOpacityTransition, forKey: .modelOpacityTransition)
        try paintContainer.encode(modelRotation, forKey: .modelRotation)
        try paintContainer.encode(modelRotationTransition, forKey: .modelRotationTransition)
        try paintContainer.encode(modelScale, forKey: .modelScale)
        try paintContainer.encode(modelScaleTransition, forKey: .modelScaleTransition)
        try paintContainer.encode(modelTranslation, forKey: .modelTranslation)
        try paintContainer.encode(modelTranslationTransition, forKey: .modelTranslationTransition)
        try paintContainer.encode(modelType, forKey: .modelType)

        var layoutContainer = container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)
        try layoutContainer.encode(visibility, forKey: .visibility)
        try layoutContainer.encode(modelId, forKey: .modelId)
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
            modelCastShadows = try paintContainer.decodeIfPresent(Value<Bool>.self, forKey: .modelCastShadows)
            modelColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .modelColor)
            modelColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .modelColorTransition)
            modelColorMixIntensity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .modelColorMixIntensity)
            modelColorMixIntensityTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .modelColorMixIntensityTransition)
            modelOpacity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .modelOpacity)
            modelOpacityTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .modelOpacityTransition)
            modelRotation = try paintContainer.decodeIfPresent(Value<[Double]>.self, forKey: .modelRotation)
            modelRotationTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .modelRotationTransition)
            modelScale = try paintContainer.decodeIfPresent(Value<[Double]>.self, forKey: .modelScale)
            modelScaleTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .modelScaleTransition)
            modelTranslation = try paintContainer.decodeIfPresent(Value<[Double]>.self, forKey: .modelTranslation)
            modelTranslationTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .modelTranslationTransition)
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
        case modelCastShadows = "model-cast-shadows"
        case modelColor = "model-color"
        case modelColorTransition = "model-color-transition"
        case modelColorMixIntensity = "model-color-mix-intensity"
        case modelColorMixIntensityTransition = "model-color-mix-intensity-transition"
        case modelOpacity = "model-opacity"
        case modelOpacityTransition = "model-opacity-transition"
        case modelRotation = "model-rotation"
        case modelRotationTransition = "model-rotation-transition"
        case modelScale = "model-scale"
        case modelScaleTransition = "model-scale-transition"
        case modelTranslation = "model-translation"
        case modelTranslationTransition = "model-translation-transition"
        case modelType = "model-type"
    }

    private func encodeIfModified<E: Encodable, Key: CodingKey>(
        _ encodable: E?,
        forKey key: Key,
        to container: inout KeyedEncodingContainer<Key>
    ) throws {
        guard modifiedProperties.contains(key.stringValue) else {
            return
        }
        try container.encode(encodable ?? defaultValue(for: key), forKey: key)
    }
}

// End of generated file.
