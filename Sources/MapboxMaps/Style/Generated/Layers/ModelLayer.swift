// This file is generated.
import Foundation

/// Defines rendering behavior of model in respect to other 3D scene objects.
internal enum ModelType: String, Codable, CaseIterable {

    /// Integrated to 3D scene, using depth testing, along with terrain, fill-extrusions and custom layer.
    case common3d = "common-3d"

    /// Displayed over other 3D content, occluded by terrain.
    case locationIndicator = "location-indicator"
}

/// A layer to render 3D Models.
internal struct ModelLayer: Layer {

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

    /// 
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

    /// 
    public var modelReceiveShadows: Value<Bool>?

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
        var container = encoder.container(keyedBy: RootCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(filter, forKey: .filter)
        try container.encodeIfPresent(source, forKey: .source)
        try container.encodeIfPresent(sourceLayer, forKey: .sourceLayer)
        try container.encodeIfPresent(minZoom, forKey: .minZoom)
        try container.encodeIfPresent(maxZoom, forKey: .maxZoom)

        var paintContainer = container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint)
        try paintContainer.encodeIfPresent(modelCastShadows, forKey: .modelCastShadows)
        try paintContainer.encodeIfPresent(modelColor, forKey: .modelColor)
        try paintContainer.encodeIfPresent(modelColorTransition, forKey: .modelColorTransition)
        try paintContainer.encodeIfPresent(modelColorMixIntensity, forKey: .modelColorMixIntensity)
        try paintContainer.encodeIfPresent(modelColorMixIntensityTransition, forKey: .modelColorMixIntensityTransition)
        try paintContainer.encodeIfPresent(modelOpacity, forKey: .modelOpacity)
        try paintContainer.encodeIfPresent(modelOpacityTransition, forKey: .modelOpacityTransition)
        try paintContainer.encodeIfPresent(modelReceiveShadows, forKey: .modelReceiveShadows)
        try paintContainer.encodeIfPresent(modelRotation, forKey: .modelRotation)
        try paintContainer.encodeIfPresent(modelRotationTransition, forKey: .modelRotationTransition)
        try paintContainer.encodeIfPresent(modelScale, forKey: .modelScale)
        try paintContainer.encodeIfPresent(modelScaleTransition, forKey: .modelScaleTransition)
        try paintContainer.encodeIfPresent(modelTranslation, forKey: .modelTranslation)
        try paintContainer.encodeIfPresent(modelTranslationTransition, forKey: .modelTranslationTransition)
        try paintContainer.encodeIfPresent(modelType, forKey: .modelType)

        var layoutContainer = container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)
        try layoutContainer.encodeIfPresent(visibility, forKey: .visibility)
        try layoutContainer.encodeIfPresent(modelId, forKey: .modelId)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootCodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = .model
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
            modelReceiveShadows = try paintContainer.decodeIfPresent(Value<Bool>.self, forKey: .modelReceiveShadows)
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
        case modelReceiveShadows = "model-receive-shadows"
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
