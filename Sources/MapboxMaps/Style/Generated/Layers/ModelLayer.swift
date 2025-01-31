// This file is generated.
import UIKit

/// A layer to render 3D Models.
@_documentation(visibility: public)
@_spi(Experimental) public struct ModelLayer: Layer, Equatable {

    // MARK: - Conformance to `Layer` protocol
    /// Unique layer name
    @_documentation(visibility: public)
    public var id: String

    /// Rendering type of this layer.
    @_documentation(visibility: public)
    public let type: LayerType

    /// An expression specifying conditions on source features.
    /// Only features that match the filter are displayed.
    @_documentation(visibility: public)
    public var filter: Exp?

    /// Name of a source description to be used for this layer.
    /// Required for all layer types except ``BackgroundLayer``, ``SkyLayer``, and ``LocationIndicatorLayer``.
    @_documentation(visibility: public)
    public var source: String?

    /// Layer to use from a vector tile source.
    ///
    /// Required for vector tile sources.
    /// Prohibited for all other source types, including GeoJSON sources.
    @_documentation(visibility: public)
    public var sourceLayer: String?

    /// The slot this layer is assigned to. If specified, and a slot with that name exists, it will be placed at that position in the layer order.
    @_documentation(visibility: public)
    public var slot: Slot?

    /// The minimum zoom level for the layer. At zoom levels less than the minzoom, the layer will be hidden.
    @_documentation(visibility: public)
    public var minZoom: Double?

    /// The maximum zoom level for the layer. At zoom levels equal to or greater than the maxzoom, the layer will be hidden.
    @_documentation(visibility: public)
    public var maxZoom: Double?

    /// Whether this layer is displayed.
    @_documentation(visibility: public)
    public var visibility: Value<Visibility>

    /// Model to render. It can be either a string referencing an element to the models root property or an internal or external URL
    /// Default value: "".
    @_documentation(visibility: public)
    public var modelId: Value<String>?

    /// Intensity of the ambient occlusion if present in the 3D model.
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    public var modelAmbientOcclusionIntensity: Value<Double>?

    /// Transition options for `modelAmbientOcclusionIntensity`.
    @_documentation(visibility: public)
    public var modelAmbientOcclusionIntensityTransition: StyleTransition?

    /// Enable/Disable shadow casting for this layer
    /// Default value: true.
    @_documentation(visibility: public)
    public var modelCastShadows: Value<Bool>?

    /// The tint color of the model layer. model-color-mix-intensity (defaults to 0) defines tint(mix) intensity - this means that, this color is not used unless model-color-mix-intensity gets value greater than 0.
    /// Default value: "#ffffff".
    @_documentation(visibility: public)
    public var modelColor: Value<StyleColor>?

    /// Transition options for `modelColor`.
    @_documentation(visibility: public)
    public var modelColorTransition: StyleTransition?
    /// This property defines whether to use colorTheme defined color or not.
    /// By default it will use color defined by the root theme in the style.
    /// NOTE: - Expressions set to this property currently don't work.
    @_spi(Experimental) public var modelColorUseTheme: Value<ColorUseTheme>?

    /// Intensity of model-color (on a scale from 0 to 1) in color mix with original 3D model's colors. Higher number will present a higher model-color contribution in mix.
    /// Default value: 0. Value range: [0, 1]
    @_documentation(visibility: public)
    public var modelColorMixIntensity: Value<Double>?

    /// Transition options for `modelColorMixIntensity`.
    @_documentation(visibility: public)
    public var modelColorMixIntensityTransition: StyleTransition?

    /// This parameter defines the range for the fade-out effect before an automatic content cutoff  on pitched map views. The automatic cutoff range is calculated according to the minimum required zoom level of the source and layer. The fade range is expressed in relation to the height of the map view. A value of 1.0 indicates that the content is faded to the same extent as the map's height in pixels, while a value close to zero represents a sharp cutoff. When the value is set to 0.0, the cutoff is completely disabled. Note: The property has no effect on the map if terrain is enabled.
    /// Default value: 0. Value range: [0, 1]
    @_documentation(visibility: public)
    public var modelCutoffFadeRange: Value<Double>?

    /// Selects the base of the model. Some modes might require precomputed elevation data in the tileset.
    /// Default value: "ground".
    @_documentation(visibility: public)
    public var modelElevationReference: Value<ModelElevationReference>?

    /// Strength of the emission. There is no emission for value 0. For value 1.0, only emissive component (no shading) is displayed and values above 1.0 produce light contribution to surrounding area, for some of the parts (e.g. doors). Expressions that depend on measure-light are not supported when using GeoJSON or vector tile as the model layer source.
    /// Default value: 0. Value range: [0, 5]
    @_documentation(visibility: public)
    public var modelEmissiveStrength: Value<Double>?

    /// Transition options for `modelEmissiveStrength`.
    @_documentation(visibility: public)
    public var modelEmissiveStrengthTransition: StyleTransition?

    /// Emissive strength multiplier along model height (gradient begin, gradient end, value at begin, value at end, gradient curve power (logarithmic scale, curve power = pow(10, val)).
    /// Default value: [1,1,1,1,0].
    @_documentation(visibility: public)
    public var modelHeightBasedEmissiveStrengthMultiplier: Value<[Double]>?

    /// Transition options for `modelHeightBasedEmissiveStrengthMultiplier`.
    @_documentation(visibility: public)
    public var modelHeightBasedEmissiveStrengthMultiplierTransition: StyleTransition?

    /// The opacity of the model layer.
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    public var modelOpacity: Value<Double>?

    /// Transition options for `modelOpacity`.
    @_documentation(visibility: public)
    public var modelOpacityTransition: StyleTransition?

    /// Enable/Disable shadow receiving for this layer
    /// Default value: true.
    @_documentation(visibility: public)
    public var modelReceiveShadows: Value<Bool>?

    /// The rotation of the model in euler angles [lon, lat, z].
    /// Default value: [0,0,0]. The unit of modelRotation is in degrees.
    @_documentation(visibility: public)
    public var modelRotation: Value<[Double]>?

    /// Transition options for `modelRotation`.
    @_documentation(visibility: public)
    public var modelRotationTransition: StyleTransition?

    /// Material roughness. Material is fully smooth for value 0, and fully rough for value 1. Affects only layers using batched-model source.
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    public var modelRoughness: Value<Double>?

    /// Transition options for `modelRoughness`.
    @_documentation(visibility: public)
    public var modelRoughnessTransition: StyleTransition?

    /// The scale of the model.
    /// Default value: [1,1,1].
    @_documentation(visibility: public)
    public var modelScale: Value<[Double]>?

    /// Transition options for `modelScale`.
    @_documentation(visibility: public)
    public var modelScaleTransition: StyleTransition?

    /// Defines scaling mode. Only applies to location-indicator type layers.
    /// Default value: "map".
    @_documentation(visibility: public)
    public var modelScaleMode: Value<ModelScaleMode>?

    /// The translation of the model in meters in form of [longitudal, latitudal, altitude] offsets.
    /// Default value: [0,0,0].
    @_documentation(visibility: public)
    public var modelTranslation: Value<[Double]>?

    /// Transition options for `modelTranslation`.
    @_documentation(visibility: public)
    public var modelTranslationTransition: StyleTransition?

    /// Defines rendering behavior of model in respect to other 3D scene objects.
    /// Default value: "common-3d".
    @_documentation(visibility: public)
    public var modelType: Value<ModelType>?

    @_documentation(visibility: public)
    public init(id: String, source: String) {
        self.source = source
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
        try container.encodeIfPresent(slot, forKey: .slot)
        try container.encodeIfPresent(minZoom, forKey: .minZoom)
        try container.encodeIfPresent(maxZoom, forKey: .maxZoom)

        var paintContainer = container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint)
        try paintContainer.encodeIfPresent(modelAmbientOcclusionIntensity, forKey: .modelAmbientOcclusionIntensity)
        try paintContainer.encodeIfPresent(modelAmbientOcclusionIntensityTransition, forKey: .modelAmbientOcclusionIntensityTransition)
        try paintContainer.encodeIfPresent(modelCastShadows, forKey: .modelCastShadows)
        try paintContainer.encodeIfPresent(modelColor, forKey: .modelColor)
        try paintContainer.encodeIfPresent(modelColorTransition, forKey: .modelColorTransition)
        try paintContainer.encodeIfPresent(modelColorUseTheme, forKey: .modelColorUseTheme)
        try paintContainer.encodeIfPresent(modelColorMixIntensity, forKey: .modelColorMixIntensity)
        try paintContainer.encodeIfPresent(modelColorMixIntensityTransition, forKey: .modelColorMixIntensityTransition)
        try paintContainer.encodeIfPresent(modelCutoffFadeRange, forKey: .modelCutoffFadeRange)
        try paintContainer.encodeIfPresent(modelElevationReference, forKey: .modelElevationReference)
        try paintContainer.encodeIfPresent(modelEmissiveStrength, forKey: .modelEmissiveStrength)
        try paintContainer.encodeIfPresent(modelEmissiveStrengthTransition, forKey: .modelEmissiveStrengthTransition)
        try paintContainer.encodeIfPresent(modelHeightBasedEmissiveStrengthMultiplier, forKey: .modelHeightBasedEmissiveStrengthMultiplier)
        try paintContainer.encodeIfPresent(modelHeightBasedEmissiveStrengthMultiplierTransition, forKey: .modelHeightBasedEmissiveStrengthMultiplierTransition)
        try paintContainer.encodeIfPresent(modelOpacity, forKey: .modelOpacity)
        try paintContainer.encodeIfPresent(modelOpacityTransition, forKey: .modelOpacityTransition)
        try paintContainer.encodeIfPresent(modelReceiveShadows, forKey: .modelReceiveShadows)
        try paintContainer.encodeIfPresent(modelRotation, forKey: .modelRotation)
        try paintContainer.encodeIfPresent(modelRotationTransition, forKey: .modelRotationTransition)
        try paintContainer.encodeIfPresent(modelRoughness, forKey: .modelRoughness)
        try paintContainer.encodeIfPresent(modelRoughnessTransition, forKey: .modelRoughnessTransition)
        try paintContainer.encodeIfPresent(modelScale, forKey: .modelScale)
        try paintContainer.encodeIfPresent(modelScaleTransition, forKey: .modelScaleTransition)
        try paintContainer.encodeIfPresent(modelScaleMode, forKey: .modelScaleMode)
        try paintContainer.encodeIfPresent(modelTranslation, forKey: .modelTranslation)
        try paintContainer.encodeIfPresent(modelTranslationTransition, forKey: .modelTranslationTransition)
        try paintContainer.encodeIfPresent(modelType, forKey: .modelType)

        var layoutContainer = container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)
        try layoutContainer.encode(visibility, forKey: .visibility)
        try layoutContainer.encodeIfPresent(modelId, forKey: .modelId)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootCodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(LayerType.self, forKey: .type)
        filter = try container.decodeIfPresent(Exp.self, forKey: .filter)
        source = try container.decodeIfPresent(String.self, forKey: .source)
        sourceLayer = try container.decodeIfPresent(String.self, forKey: .sourceLayer)
        slot = try container.decodeIfPresent(Slot.self, forKey: .slot)
        minZoom = try container.decodeIfPresent(Double.self, forKey: .minZoom)
        maxZoom = try container.decodeIfPresent(Double.self, forKey: .maxZoom)

        if let paintContainer = try? container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint) {
            modelAmbientOcclusionIntensity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .modelAmbientOcclusionIntensity)
            modelAmbientOcclusionIntensityTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .modelAmbientOcclusionIntensityTransition)
            modelCastShadows = try paintContainer.decodeIfPresent(Value<Bool>.self, forKey: .modelCastShadows)
            modelColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .modelColor)
            modelColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .modelColorTransition)
            modelColorUseTheme = try paintContainer.decodeIfPresent(Value<ColorUseTheme>.self, forKey: .modelColorUseTheme)
            modelColorMixIntensity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .modelColorMixIntensity)
            modelColorMixIntensityTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .modelColorMixIntensityTransition)
            modelCutoffFadeRange = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .modelCutoffFadeRange)
            modelElevationReference = try paintContainer.decodeIfPresent(Value<ModelElevationReference>.self, forKey: .modelElevationReference)
            modelEmissiveStrength = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .modelEmissiveStrength)
            modelEmissiveStrengthTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .modelEmissiveStrengthTransition)
            modelHeightBasedEmissiveStrengthMultiplier = try paintContainer.decodeIfPresent(Value<[Double]>.self, forKey: .modelHeightBasedEmissiveStrengthMultiplier)
            modelHeightBasedEmissiveStrengthMultiplierTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .modelHeightBasedEmissiveStrengthMultiplierTransition)
            modelOpacity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .modelOpacity)
            modelOpacityTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .modelOpacityTransition)
            modelReceiveShadows = try paintContainer.decodeIfPresent(Value<Bool>.self, forKey: .modelReceiveShadows)
            modelRotation = try paintContainer.decodeIfPresent(Value<[Double]>.self, forKey: .modelRotation)
            modelRotationTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .modelRotationTransition)
            modelRoughness = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .modelRoughness)
            modelRoughnessTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .modelRoughnessTransition)
            modelScale = try paintContainer.decodeIfPresent(Value<[Double]>.self, forKey: .modelScale)
            modelScaleTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .modelScaleTransition)
            modelScaleMode = try paintContainer.decodeIfPresent(Value<ModelScaleMode>.self, forKey: .modelScaleMode)
            modelTranslation = try paintContainer.decodeIfPresent(Value<[Double]>.self, forKey: .modelTranslation)
            modelTranslationTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .modelTranslationTransition)
            modelType = try paintContainer.decodeIfPresent(Value<ModelType>.self, forKey: .modelType)
        }

        var visibilityEncoded: Value<Visibility>?
        if let layoutContainer = try? container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout) {
            visibilityEncoded = try layoutContainer.decodeIfPresent(Value<Visibility>.self, forKey: .visibility)
            modelId = try layoutContainer.decodeIfPresent(Value<String>.self, forKey: .modelId)
        }
        visibility = visibilityEncoded ?? .constant(.visible)
    }

    enum RootCodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case filter = "filter"
        case source = "source"
        case sourceLayer = "source-layer"
        case slot = "slot"
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
        case modelAmbientOcclusionIntensity = "model-ambient-occlusion-intensity"
        case modelAmbientOcclusionIntensityTransition = "model-ambient-occlusion-intensity-transition"
        case modelCastShadows = "model-cast-shadows"
        case modelColor = "model-color"
        case modelColorTransition = "model-color-transition"
        case modelColorUseTheme = "model-color-use-theme"
        case modelColorMixIntensity = "model-color-mix-intensity"
        case modelColorMixIntensityTransition = "model-color-mix-intensity-transition"
        case modelCutoffFadeRange = "model-cutoff-fade-range"
        case modelElevationReference = "model-elevation-reference"
        case modelEmissiveStrength = "model-emissive-strength"
        case modelEmissiveStrengthTransition = "model-emissive-strength-transition"
        case modelHeightBasedEmissiveStrengthMultiplier = "model-height-based-emissive-strength-multiplier"
        case modelHeightBasedEmissiveStrengthMultiplierTransition = "model-height-based-emissive-strength-multiplier-transition"
        case modelOpacity = "model-opacity"
        case modelOpacityTransition = "model-opacity-transition"
        case modelReceiveShadows = "model-receive-shadows"
        case modelRotation = "model-rotation"
        case modelRotationTransition = "model-rotation-transition"
        case modelRoughness = "model-roughness"
        case modelRoughnessTransition = "model-roughness-transition"
        case modelScale = "model-scale"
        case modelScaleTransition = "model-scale-transition"
        case modelScaleMode = "model-scale-mode"
        case modelTranslation = "model-translation"
        case modelTranslationTransition = "model-translation-transition"
        case modelType = "model-type"
    }
}

extension ModelLayer {
    /// An expression specifying conditions on source features.
    /// Only features that match the filter are displayed.
    public func filter(_ newValue: Exp) -> Self {
        with(self, setter(\.filter, newValue))
    }

    /// Name of a source description to be used for this layer.
    /// Required for all layer types except ``BackgroundLayer``, ``SkyLayer``, and ``LocationIndicatorLayer``.
    public func source(_ newValue: String) -> Self {
        with(self, setter(\.source, newValue))
    }

    /// Layer to use from a vector tile source.
    ///
    /// Required for vector tile sources.
    /// Prohibited for all other source types, including GeoJSON sources.
    public func sourceLayer(_ newValue: String) -> Self {
        with(self, setter(\.sourceLayer, newValue))
    }

    /// The slot this layer is assigned to.
    /// If specified, and a slot with that name exists, it will be placed at that position in the layer order.
    public func slot(_ newValue: Slot?) -> Self {
        with(self, setter(\.slot, newValue))
    }

    /// The minimum zoom level for the layer. At zoom levels less than the minzoom, the layer will be hidden.
    public func minZoom(_ newValue: Double) -> Self {
        with(self, setter(\.minZoom, newValue))
    }

    /// The maximum zoom level for the layer. At zoom levels equal to or greater than the maxzoom, the layer will be hidden.
    public func maxZoom(_ newValue: Double) -> Self {
        with(self, setter(\.maxZoom, newValue))
    }

    /// Model to render. It can be either a string referencing an element to the models root property or an internal or external URL
    /// Default value: "".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelId(_ constant: String) -> Self {
        with(self, setter(\.modelId, .constant(constant)))
    }

    /// Model to render. It can be either a string referencing an element to the models root property or an internal or external URL
    /// Default value: "".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelId(_ expression: Exp) -> Self {
        with(self, setter(\.modelId, .expression(expression)))
    }

    /// Intensity of the ambient occlusion if present in the 3D model.
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelAmbientOcclusionIntensity(_ constant: Double) -> Self {
        with(self, setter(\.modelAmbientOcclusionIntensity, .constant(constant)))
    }

    /// Transition property for `modelAmbientOcclusionIntensity`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelAmbientOcclusionIntensityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.modelAmbientOcclusionIntensityTransition, transition))
    }

    /// Intensity of the ambient occlusion if present in the 3D model.
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelAmbientOcclusionIntensity(_ expression: Exp) -> Self {
        with(self, setter(\.modelAmbientOcclusionIntensity, .expression(expression)))
    }

    /// Enable/Disable shadow casting for this layer
    /// Default value: true.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelCastShadows(_ constant: Bool) -> Self {
        with(self, setter(\.modelCastShadows, .constant(constant)))
    }

    /// Enable/Disable shadow casting for this layer
    /// Default value: true.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelCastShadows(_ expression: Exp) -> Self {
        with(self, setter(\.modelCastShadows, .expression(expression)))
    }

    /// The tint color of the model layer. model-color-mix-intensity (defaults to 0) defines tint(mix) intensity - this means that, this color is not used unless model-color-mix-intensity gets value greater than 0.
    /// Default value: "#ffffff".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelColor(_ constant: StyleColor) -> Self {
        with(self, setter(\.modelColor, .constant(constant)))
    }

    /// The tint color of the model layer. model-color-mix-intensity (defaults to 0) defines tint(mix) intensity - this means that, this color is not used unless model-color-mix-intensity gets value greater than 0.
    /// Default value: "#ffffff".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelColor(_ color: UIColor) -> Self {
        with(self, setter(\.modelColor, .constant(StyleColor(color))))
    }

    /// Transition property for `modelColor`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.modelColorTransition, transition))
    }

    /// The tint color of the model layer. model-color-mix-intensity (defaults to 0) defines tint(mix) intensity - this means that, this color is not used unless model-color-mix-intensity gets value greater than 0.
    /// Default value: "#ffffff".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelColor(_ expression: Exp) -> Self {
        with(self, setter(\.modelColor, .expression(expression)))
    }

    /// This property defines whether the `modelColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelColorUseTheme(_ useTheme: ColorUseTheme) -> Self {
        with(self, setter(\.modelColorUseTheme, .constant(useTheme)))
    }

    /// This property defines whether the `modelColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelColorUseTheme(_ expression: Exp) -> Self {
        with(self, setter(\.modelColorUseTheme, .expression(expression)))
    }

    /// Intensity of model-color (on a scale from 0 to 1) in color mix with original 3D model's colors. Higher number will present a higher model-color contribution in mix.
    /// Default value: 0. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelColorMixIntensity(_ constant: Double) -> Self {
        with(self, setter(\.modelColorMixIntensity, .constant(constant)))
    }

    /// Transition property for `modelColorMixIntensity`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelColorMixIntensityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.modelColorMixIntensityTransition, transition))
    }

    /// Intensity of model-color (on a scale from 0 to 1) in color mix with original 3D model's colors. Higher number will present a higher model-color contribution in mix.
    /// Default value: 0. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelColorMixIntensity(_ expression: Exp) -> Self {
        with(self, setter(\.modelColorMixIntensity, .expression(expression)))
    }

    /// This parameter defines the range for the fade-out effect before an automatic content cutoff  on pitched map views. The automatic cutoff range is calculated according to the minimum required zoom level of the source and layer. The fade range is expressed in relation to the height of the map view. A value of 1.0 indicates that the content is faded to the same extent as the map's height in pixels, while a value close to zero represents a sharp cutoff. When the value is set to 0.0, the cutoff is completely disabled. Note: The property has no effect on the map if terrain is enabled.
    /// Default value: 0. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelCutoffFadeRange(_ constant: Double) -> Self {
        with(self, setter(\.modelCutoffFadeRange, .constant(constant)))
    }

    /// This parameter defines the range for the fade-out effect before an automatic content cutoff  on pitched map views. The automatic cutoff range is calculated according to the minimum required zoom level of the source and layer. The fade range is expressed in relation to the height of the map view. A value of 1.0 indicates that the content is faded to the same extent as the map's height in pixels, while a value close to zero represents a sharp cutoff. When the value is set to 0.0, the cutoff is completely disabled. Note: The property has no effect on the map if terrain is enabled.
    /// Default value: 0. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelCutoffFadeRange(_ expression: Exp) -> Self {
        with(self, setter(\.modelCutoffFadeRange, .expression(expression)))
    }

    /// Selects the base of the model. Some modes might require precomputed elevation data in the tileset.
    /// Default value: "ground".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelElevationReference(_ constant: ModelElevationReference) -> Self {
        with(self, setter(\.modelElevationReference, .constant(constant)))
    }

    /// Selects the base of the model. Some modes might require precomputed elevation data in the tileset.
    /// Default value: "ground".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelElevationReference(_ expression: Exp) -> Self {
        with(self, setter(\.modelElevationReference, .expression(expression)))
    }

    /// Strength of the emission. There is no emission for value 0. For value 1.0, only emissive component (no shading) is displayed and values above 1.0 produce light contribution to surrounding area, for some of the parts (e.g. doors). Expressions that depend on measure-light are not supported when using GeoJSON or vector tile as the model layer source.
    /// Default value: 0. Value range: [0, 5]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelEmissiveStrength(_ constant: Double) -> Self {
        with(self, setter(\.modelEmissiveStrength, .constant(constant)))
    }

    /// Transition property for `modelEmissiveStrength`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelEmissiveStrengthTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.modelEmissiveStrengthTransition, transition))
    }

    /// Strength of the emission. There is no emission for value 0. For value 1.0, only emissive component (no shading) is displayed and values above 1.0 produce light contribution to surrounding area, for some of the parts (e.g. doors). Expressions that depend on measure-light are not supported when using GeoJSON or vector tile as the model layer source.
    /// Default value: 0. Value range: [0, 5]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelEmissiveStrength(_ expression: Exp) -> Self {
        with(self, setter(\.modelEmissiveStrength, .expression(expression)))
    }

    /// Emissive strength multiplier along model height (gradient begin, gradient end, value at begin, value at end, gradient curve power (logarithmic scale, curve power = pow(10, val)).
    /// Default value: [1,1,1,1,0].
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelHeightBasedEmissiveStrengthMultiplier(gradientBegin: Double, gradientEnd: Double, valueAtBegin: Double, valueAtEnd: Double, gradientCurvePower: Double) -> Self {
        with(self, setter(\.modelHeightBasedEmissiveStrengthMultiplier, .constant([gradientBegin, gradientEnd, valueAtBegin, valueAtEnd, gradientCurvePower])))
    }

    /// Transition property for `modelHeightBasedEmissiveStrengthMultiplier`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelHeightBasedEmissiveStrengthMultiplierTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.modelHeightBasedEmissiveStrengthMultiplierTransition, transition))
    }

    /// Emissive strength multiplier along model height (gradient begin, gradient end, value at begin, value at end, gradient curve power (logarithmic scale, curve power = pow(10, val)).
    /// Default value: [1,1,1,1,0].
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelHeightBasedEmissiveStrengthMultiplier(_ expression: Exp) -> Self {
        with(self, setter(\.modelHeightBasedEmissiveStrengthMultiplier, .expression(expression)))
    }

    /// The opacity of the model layer.
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelOpacity(_ constant: Double) -> Self {
        with(self, setter(\.modelOpacity, .constant(constant)))
    }

    /// Transition property for `modelOpacity`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelOpacityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.modelOpacityTransition, transition))
    }

    /// The opacity of the model layer.
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelOpacity(_ expression: Exp) -> Self {
        with(self, setter(\.modelOpacity, .expression(expression)))
    }

    /// Enable/Disable shadow receiving for this layer
    /// Default value: true.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelReceiveShadows(_ constant: Bool) -> Self {
        with(self, setter(\.modelReceiveShadows, .constant(constant)))
    }

    /// Enable/Disable shadow receiving for this layer
    /// Default value: true.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelReceiveShadows(_ expression: Exp) -> Self {
        with(self, setter(\.modelReceiveShadows, .expression(expression)))
    }

    /// The rotation of the model in euler angles [lon, lat, z].
    /// Default value: [0,0,0]. The unit of modelRotation is in degrees.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelRotation(x: Double, y: Double, z: Double) -> Self {
        with(self, setter(\.modelRotation, .constant([x, y, z])))
    }

    /// Transition property for `modelRotation`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelRotationTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.modelRotationTransition, transition))
    }

    /// The rotation of the model in euler angles [lon, lat, z].
    /// Default value: [0,0,0]. The unit of modelRotation is in degrees.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelRotation(_ expression: Exp) -> Self {
        with(self, setter(\.modelRotation, .expression(expression)))
    }

    /// Material roughness. Material is fully smooth for value 0, and fully rough for value 1. Affects only layers using batched-model source.
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelRoughness(_ constant: Double) -> Self {
        with(self, setter(\.modelRoughness, .constant(constant)))
    }

    /// Transition property for `modelRoughness`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelRoughnessTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.modelRoughnessTransition, transition))
    }

    /// Material roughness. Material is fully smooth for value 0, and fully rough for value 1. Affects only layers using batched-model source.
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelRoughness(_ expression: Exp) -> Self {
        with(self, setter(\.modelRoughness, .expression(expression)))
    }

    /// The scale of the model.
    /// Default value: [1,1,1].
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelScale(x: Double, y: Double, z: Double) -> Self {
        with(self, setter(\.modelScale, .constant([x, y, z])))
    }

    /// Transition property for `modelScale`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelScaleTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.modelScaleTransition, transition))
    }

    /// The scale of the model.
    /// Default value: [1,1,1].
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelScale(_ expression: Exp) -> Self {
        with(self, setter(\.modelScale, .expression(expression)))
    }

    /// Defines scaling mode. Only applies to location-indicator type layers.
    /// Default value: "map".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelScaleMode(_ constant: ModelScaleMode) -> Self {
        with(self, setter(\.modelScaleMode, .constant(constant)))
    }

    /// Defines scaling mode. Only applies to location-indicator type layers.
    /// Default value: "map".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelScaleMode(_ expression: Exp) -> Self {
        with(self, setter(\.modelScaleMode, .expression(expression)))
    }

    /// The translation of the model in meters in form of [longitudal, latitudal, altitude] offsets.
    /// Default value: [0,0,0].
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelTranslation(x: Double, y: Double, z: Double) -> Self {
        with(self, setter(\.modelTranslation, .constant([x, y, z])))
    }

    /// Transition property for `modelTranslation`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelTranslationTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.modelTranslationTransition, transition))
    }

    /// The translation of the model in meters in form of [longitudal, latitudal, altitude] offsets.
    /// Default value: [0,0,0].
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelTranslation(_ expression: Exp) -> Self {
        with(self, setter(\.modelTranslation, .expression(expression)))
    }

    /// Defines rendering behavior of model in respect to other 3D scene objects.
    /// Default value: "common-3d".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelType(_ constant: ModelType) -> Self {
        with(self, setter(\.modelType, .constant(constant)))
    }

    /// Defines rendering behavior of model in respect to other 3D scene objects.
    /// Default value: "common-3d".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelType(_ expression: Exp) -> Self {
        with(self, setter(\.modelType, .expression(expression)))
    }
}

extension ModelLayer: MapStyleContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        node.mount(MountedLayer(layer: self))
    }
}

// End of generated file.
