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

    public init(id: String) {
        self.id = id
        self.type = LayerType.model
        self.visibility = .constant(.visible)
    }

    public func encode(to encoder: Encoder) throws {
        let nilEncoder = NilEncoder(userInfo: encoder.userInfo)

        var container = encoder.container(keyedBy: RootCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try nilEncoder.encode(filter, forKey: .filter, to: &container)
        try nilEncoder.encode(source, forKey: .source, to: &container)
        try nilEncoder.encode(sourceLayer, forKey: .sourceLayer, to: &container)
        try nilEncoder.encode(minZoom, forKey: .minZoom, to: &container)
        try nilEncoder.encode(maxZoom, forKey: .maxZoom, to: &container)

        var paintContainer = container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint)
        try nilEncoder.encode(modelColor, forKey: .modelColor, to: &paintContainer)
        try nilEncoder.encode(modelColorTransition, forKey: .modelColorTransition, to: &paintContainer)
        try nilEncoder.encode(modelColorMixIntensity, forKey: .modelColorMixIntensity, to: &paintContainer)
        try nilEncoder.encode(modelColorMixIntensityTransition, forKey: .modelColorMixIntensityTransition, to: &paintContainer)
        try nilEncoder.encode(modelOpacity, forKey: .modelOpacity, to: &paintContainer)
        try nilEncoder.encode(modelOpacityTransition, forKey: .modelOpacityTransition, to: &paintContainer)
        try nilEncoder.encode(modelRotation, forKey: .modelRotation, to: &paintContainer)
        try nilEncoder.encode(modelRotationTransition, forKey: .modelRotationTransition, to: &paintContainer)
        try nilEncoder.encode(modelScale, forKey: .modelScale, to: &paintContainer)
        try nilEncoder.encode(modelScaleTransition, forKey: .modelScaleTransition, to: &paintContainer)
        try nilEncoder.encode(modelTranslation, forKey: .modelTranslation, to: &paintContainer)
        try nilEncoder.encode(modelTranslationTransition, forKey: .modelTranslationTransition, to: &paintContainer)
        try nilEncoder.encode(modelType, forKey: .modelType, to: &paintContainer)

        var layoutContainer = container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)
        try nilEncoder.encode(visibility, forKey: .visibility, to: &layoutContainer)
        try nilEncoder.encode(modelId, forKey: .modelId, to: &layoutContainer)
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
}

// End of generated file.
