// This file is generated.
import UIKit

/// An extruded (3D) polygon.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#layers-fill-extrusion)
public struct FillExtrusionLayer: Layer, Equatable {

    // MARK: - Conformance to `Layer` protocol
    /// Unique layer name
    public var id: String

    /// Rendering type of this layer.
    public let type: LayerType

    /// An expression specifying conditions on source features.
    /// Only features that match the filter are displayed.
    public var filter: Expression?

    /// Name of a source description to be used for this layer.
    /// Required for all layer types except ``BackgroundLayer``, ``SkyLayer``, and ``LocationIndicatorLayer``.
    public var source: String?

    /// Layer to use from a vector tile source.
    ///
    /// Required for vector tile sources.
    /// Prohibited for all other source types, including GeoJSON sources.
    public var sourceLayer: String?

    /// The slot this layer is assigned to. If specified, and a slot with that name exists, it will be placed at that position in the layer order.
    public var slot: Slot?

    /// The minimum zoom level for the layer. At zoom levels less than the minzoom, the layer will be hidden.
    public var minZoom: Double?

    /// The maximum zoom level for the layer. At zoom levels equal to or greater than the maxzoom, the layer will be hidden.
    public var maxZoom: Double?

    /// Whether this layer is displayed.
    public var visibility: Value<Visibility>

    /// Radius of a fill extrusion edge in meters. If not zero, rounds extrusion edges for a smoother appearance.
    /// Default value: 0. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental) public var fillExtrusionEdgeRadius: Value<Double>?

    /// Provides a control to futher fine-tune the look of the ambient occlusion on the ground beneath the extruded buildings. Lower values give the effect a more solid look while higher values make it smoother.
    /// Default value: 0.69. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental) public var fillExtrusionAmbientOcclusionGroundAttenuation: Value<Double>?

    /// Transition options for `fillExtrusionAmbientOcclusionGroundAttenuation`.
    @_documentation(visibility: public)
    @_spi(Experimental) public var fillExtrusionAmbientOcclusionGroundAttenuationTransition: StyleTransition?

    /// The extent of the ambient occlusion effect on the ground beneath the extruded buildings in meters.
    /// Default value: 3. Minimum value: 0.
    @_documentation(visibility: public)
    @_spi(Experimental) public var fillExtrusionAmbientOcclusionGroundRadius: Value<Double>?

    /// Transition options for `fillExtrusionAmbientOcclusionGroundRadius`.
    @_documentation(visibility: public)
    @_spi(Experimental) public var fillExtrusionAmbientOcclusionGroundRadiusTransition: StyleTransition?

    /// Controls the intensity of shading near ground and concave angles between walls. Default value 0.0 disables ambient occlusion and values around 0.3 provide the most plausible results for buildings.
    /// Default value: 0. Value range: [0, 1]
    public var fillExtrusionAmbientOcclusionIntensity: Value<Double>?

    /// Transition options for `fillExtrusionAmbientOcclusionIntensity`.
    public var fillExtrusionAmbientOcclusionIntensityTransition: StyleTransition?

    /// Shades area near ground and concave angles between walls where the radius defines only vertical impact. Default value 3.0 corresponds to height of one floor and brings the most plausible results for buildings. This property works only with legacy light. When 3D lights are enabled `fill-extrusion-ambient-occlusion-wall-radius` and `fill-extrusion-ambient-occlusion-ground-radius` are used instead.
    /// Default value: 3. Minimum value: 0.
    public var fillExtrusionAmbientOcclusionRadius: Value<Double>?

    /// Transition options for `fillExtrusionAmbientOcclusionRadius`.
    public var fillExtrusionAmbientOcclusionRadiusTransition: StyleTransition?

    /// Shades area near ground and concave angles between walls where the radius defines only vertical impact. Default value 3.0 corresponds to height of one floor and brings the most plausible results for buildings.
    /// Default value: 3. Minimum value: 0.
    @_documentation(visibility: public)
    @_spi(Experimental) public var fillExtrusionAmbientOcclusionWallRadius: Value<Double>?

    /// Transition options for `fillExtrusionAmbientOcclusionWallRadius`.
    @_documentation(visibility: public)
    @_spi(Experimental) public var fillExtrusionAmbientOcclusionWallRadiusTransition: StyleTransition?

    /// The height with which to extrude the base of this layer. Must be less than or equal to `fill-extrusion-height`.
    /// Default value: 0. Minimum value: 0.
    public var fillExtrusionBase: Value<Double>?

    /// Transition options for `fillExtrusionBase`.
    public var fillExtrusionBaseTransition: StyleTransition?

    /// The base color of the extruded fill. The extrusion's surfaces will be shaded differently based on this color in combination with the root `light` settings. If this color is specified as `rgba` with an alpha component, the alpha component will be ignored; use `fill-extrusion-opacity` to set layer opacity.
    /// Default value: "#000000".
    public var fillExtrusionColor: Value<StyleColor>?

    /// Transition options for `fillExtrusionColor`.
    public var fillExtrusionColorTransition: StyleTransition?

    /// This parameter defines the range for the fade-out effect before an automatic content cutoff on pitched map views. Fade out is implemented by scaling down and removing buildings in the fade range in a staggered fashion. Opacity is not changed. The fade range is expressed in relation to the height of the map view. A value of 1.0 indicates that the content is faded to the same extent as the map's height in pixels, while a value close to zero represents a sharp cutoff. When the value is set to 0.0, the cutoff is completely disabled. Note: The property has no effect on the map if terrain is enabled.
    /// Default value: 0. Value range: [0, 1]
    public var fillExtrusionCutoffFadeRange: Value<Double>?

    /// Controls the intensity of light emitted on the source features.
    /// Default value: 0. Minimum value: 0.
    public var fillExtrusionEmissiveStrength: Value<Double>?

    /// Transition options for `fillExtrusionEmissiveStrength`.
    public var fillExtrusionEmissiveStrengthTransition: StyleTransition?

    /// The color of the flood light effect on the walls of the extruded buildings.
    /// Default value: "#ffffff".
    @_documentation(visibility: public)
    @_spi(Experimental) public var fillExtrusionFloodLightColor: Value<StyleColor>?

    /// Transition options for `fillExtrusionFloodLightColor`.
    @_documentation(visibility: public)
    @_spi(Experimental) public var fillExtrusionFloodLightColorTransition: StyleTransition?

    /// Provides a control to futher fine-tune the look of the flood light on the ground beneath the extruded buildings. Lower values give the effect a more solid look while higher values make it smoother.
    /// Default value: 0.69. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental) public var fillExtrusionFloodLightGroundAttenuation: Value<Double>?

    /// Transition options for `fillExtrusionFloodLightGroundAttenuation`.
    @_documentation(visibility: public)
    @_spi(Experimental) public var fillExtrusionFloodLightGroundAttenuationTransition: StyleTransition?

    /// The extent of the flood light effect on the ground beneath the extruded buildings in meters.
    /// Default value: 0.
    @_documentation(visibility: public)
    @_spi(Experimental) public var fillExtrusionFloodLightGroundRadius: Value<Double>?

    /// Transition options for `fillExtrusionFloodLightGroundRadius`.
    @_documentation(visibility: public)
    @_spi(Experimental) public var fillExtrusionFloodLightGroundRadiusTransition: StyleTransition?

    /// The intensity of the flood light color.
    /// Default value: 0. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental) public var fillExtrusionFloodLightIntensity: Value<Double>?

    /// Transition options for `fillExtrusionFloodLightIntensity`.
    @_documentation(visibility: public)
    @_spi(Experimental) public var fillExtrusionFloodLightIntensityTransition: StyleTransition?

    /// The extent of the flood light effect on the walls of the extruded buildings in meters.
    /// Default value: 0. Minimum value: 0.
    @_documentation(visibility: public)
    @_spi(Experimental) public var fillExtrusionFloodLightWallRadius: Value<Double>?

    /// Transition options for `fillExtrusionFloodLightWallRadius`.
    @_documentation(visibility: public)
    @_spi(Experimental) public var fillExtrusionFloodLightWallRadiusTransition: StyleTransition?

    /// The height with which to extrude this layer.
    /// Default value: 0. Minimum value: 0.
    public var fillExtrusionHeight: Value<Double>?

    /// Transition options for `fillExtrusionHeight`.
    public var fillExtrusionHeightTransition: StyleTransition?

    /// The opacity of the entire fill extrusion layer. This is rendered on a per-layer, not per-feature, basis, and data-driven styling is not available.
    /// Default value: 1. Value range: [0, 1]
    public var fillExtrusionOpacity: Value<Double>?

    /// Transition options for `fillExtrusionOpacity`.
    public var fillExtrusionOpacityTransition: StyleTransition?

    /// Name of image in sprite to use for drawing images on extruded fills. For seamless patterns, image width and height must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    public var fillExtrusionPattern: Value<ResolvedImage>?

    /// Indicates whether top edges should be rounded when fill-extrusion-edge-radius has a value greater than 0. If false, rounded edges are only applied to the sides. Default is true.
    /// Default value: true.
    @_documentation(visibility: public)
    @_spi(Experimental) public var fillExtrusionRoundedRoof: Value<Bool>?

    /// The geometry's offset. Values are [x, y] where negatives indicate left and up (on the flat plane), respectively.
    /// Default value: [0,0].
    public var fillExtrusionTranslate: Value<[Double]>?

    /// Transition options for `fillExtrusionTranslate`.
    public var fillExtrusionTranslateTransition: StyleTransition?

    /// Controls the frame of reference for `fill-extrusion-translate`.
    /// Default value: "map".
    public var fillExtrusionTranslateAnchor: Value<FillExtrusionTranslateAnchor>?

    /// Whether to apply a vertical gradient to the sides of a fill-extrusion layer. If true, sides will be shaded slightly darker farther down.
    /// Default value: true.
    public var fillExtrusionVerticalGradient: Value<Bool>?

    /// A global multiplier that can be used to scale base, height, AO, and flood light of the fill extrusions.
    /// Default value: 1. Minimum value: 0.
    @_documentation(visibility: public)
    @_spi(Experimental) public var fillExtrusionVerticalScale: Value<Double>?

    /// Transition options for `fillExtrusionVerticalScale`.
    @_documentation(visibility: public)
    @_spi(Experimental) public var fillExtrusionVerticalScaleTransition: StyleTransition?

    public init(id: String, source: String) {
        self.source = source
        self.id = id
        self.type = LayerType.fillExtrusion
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
        try paintContainer.encodeIfPresent(fillExtrusionAmbientOcclusionGroundAttenuation, forKey: .fillExtrusionAmbientOcclusionGroundAttenuation)
        try paintContainer.encodeIfPresent(fillExtrusionAmbientOcclusionGroundAttenuationTransition, forKey: .fillExtrusionAmbientOcclusionGroundAttenuationTransition)
        try paintContainer.encodeIfPresent(fillExtrusionAmbientOcclusionGroundRadius, forKey: .fillExtrusionAmbientOcclusionGroundRadius)
        try paintContainer.encodeIfPresent(fillExtrusionAmbientOcclusionGroundRadiusTransition, forKey: .fillExtrusionAmbientOcclusionGroundRadiusTransition)
        try paintContainer.encodeIfPresent(fillExtrusionAmbientOcclusionIntensity, forKey: .fillExtrusionAmbientOcclusionIntensity)
        try paintContainer.encodeIfPresent(fillExtrusionAmbientOcclusionIntensityTransition, forKey: .fillExtrusionAmbientOcclusionIntensityTransition)
        try paintContainer.encodeIfPresent(fillExtrusionAmbientOcclusionRadius, forKey: .fillExtrusionAmbientOcclusionRadius)
        try paintContainer.encodeIfPresent(fillExtrusionAmbientOcclusionRadiusTransition, forKey: .fillExtrusionAmbientOcclusionRadiusTransition)
        try paintContainer.encodeIfPresent(fillExtrusionAmbientOcclusionWallRadius, forKey: .fillExtrusionAmbientOcclusionWallRadius)
        try paintContainer.encodeIfPresent(fillExtrusionAmbientOcclusionWallRadiusTransition, forKey: .fillExtrusionAmbientOcclusionWallRadiusTransition)
        try paintContainer.encodeIfPresent(fillExtrusionBase, forKey: .fillExtrusionBase)
        try paintContainer.encodeIfPresent(fillExtrusionBaseTransition, forKey: .fillExtrusionBaseTransition)
        try paintContainer.encodeIfPresent(fillExtrusionColor, forKey: .fillExtrusionColor)
        try paintContainer.encodeIfPresent(fillExtrusionColorTransition, forKey: .fillExtrusionColorTransition)
        try paintContainer.encodeIfPresent(fillExtrusionCutoffFadeRange, forKey: .fillExtrusionCutoffFadeRange)
        try paintContainer.encodeIfPresent(fillExtrusionEmissiveStrength, forKey: .fillExtrusionEmissiveStrength)
        try paintContainer.encodeIfPresent(fillExtrusionEmissiveStrengthTransition, forKey: .fillExtrusionEmissiveStrengthTransition)
        try paintContainer.encodeIfPresent(fillExtrusionFloodLightColor, forKey: .fillExtrusionFloodLightColor)
        try paintContainer.encodeIfPresent(fillExtrusionFloodLightColorTransition, forKey: .fillExtrusionFloodLightColorTransition)
        try paintContainer.encodeIfPresent(fillExtrusionFloodLightGroundAttenuation, forKey: .fillExtrusionFloodLightGroundAttenuation)
        try paintContainer.encodeIfPresent(fillExtrusionFloodLightGroundAttenuationTransition, forKey: .fillExtrusionFloodLightGroundAttenuationTransition)
        try paintContainer.encodeIfPresent(fillExtrusionFloodLightGroundRadius, forKey: .fillExtrusionFloodLightGroundRadius)
        try paintContainer.encodeIfPresent(fillExtrusionFloodLightGroundRadiusTransition, forKey: .fillExtrusionFloodLightGroundRadiusTransition)
        try paintContainer.encodeIfPresent(fillExtrusionFloodLightIntensity, forKey: .fillExtrusionFloodLightIntensity)
        try paintContainer.encodeIfPresent(fillExtrusionFloodLightIntensityTransition, forKey: .fillExtrusionFloodLightIntensityTransition)
        try paintContainer.encodeIfPresent(fillExtrusionFloodLightWallRadius, forKey: .fillExtrusionFloodLightWallRadius)
        try paintContainer.encodeIfPresent(fillExtrusionFloodLightWallRadiusTransition, forKey: .fillExtrusionFloodLightWallRadiusTransition)
        try paintContainer.encodeIfPresent(fillExtrusionHeight, forKey: .fillExtrusionHeight)
        try paintContainer.encodeIfPresent(fillExtrusionHeightTransition, forKey: .fillExtrusionHeightTransition)
        try paintContainer.encodeIfPresent(fillExtrusionOpacity, forKey: .fillExtrusionOpacity)
        try paintContainer.encodeIfPresent(fillExtrusionOpacityTransition, forKey: .fillExtrusionOpacityTransition)
        try paintContainer.encodeIfPresent(fillExtrusionPattern, forKey: .fillExtrusionPattern)
        try paintContainer.encodeIfPresent(fillExtrusionRoundedRoof, forKey: .fillExtrusionRoundedRoof)
        try paintContainer.encodeIfPresent(fillExtrusionTranslate, forKey: .fillExtrusionTranslate)
        try paintContainer.encodeIfPresent(fillExtrusionTranslateTransition, forKey: .fillExtrusionTranslateTransition)
        try paintContainer.encodeIfPresent(fillExtrusionTranslateAnchor, forKey: .fillExtrusionTranslateAnchor)
        try paintContainer.encodeIfPresent(fillExtrusionVerticalGradient, forKey: .fillExtrusionVerticalGradient)
        try paintContainer.encodeIfPresent(fillExtrusionVerticalScale, forKey: .fillExtrusionVerticalScale)
        try paintContainer.encodeIfPresent(fillExtrusionVerticalScaleTransition, forKey: .fillExtrusionVerticalScaleTransition)

        var layoutContainer = container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)
        try layoutContainer.encode(visibility, forKey: .visibility)
        try layoutContainer.encodeIfPresent(fillExtrusionEdgeRadius, forKey: .fillExtrusionEdgeRadius)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootCodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(LayerType.self, forKey: .type)
        filter = try container.decodeIfPresent(Expression.self, forKey: .filter)
        source = try container.decodeIfPresent(String.self, forKey: .source)
        sourceLayer = try container.decodeIfPresent(String.self, forKey: .sourceLayer)
        slot = try container.decodeIfPresent(Slot.self, forKey: .slot)
        minZoom = try container.decodeIfPresent(Double.self, forKey: .minZoom)
        maxZoom = try container.decodeIfPresent(Double.self, forKey: .maxZoom)

        if let paintContainer = try? container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint) {
            fillExtrusionAmbientOcclusionGroundAttenuation = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .fillExtrusionAmbientOcclusionGroundAttenuation)
            fillExtrusionAmbientOcclusionGroundAttenuationTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .fillExtrusionAmbientOcclusionGroundAttenuationTransition)
            fillExtrusionAmbientOcclusionGroundRadius = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .fillExtrusionAmbientOcclusionGroundRadius)
            fillExtrusionAmbientOcclusionGroundRadiusTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .fillExtrusionAmbientOcclusionGroundRadiusTransition)
            fillExtrusionAmbientOcclusionIntensity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .fillExtrusionAmbientOcclusionIntensity)
            fillExtrusionAmbientOcclusionIntensityTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .fillExtrusionAmbientOcclusionIntensityTransition)
            fillExtrusionAmbientOcclusionRadius = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .fillExtrusionAmbientOcclusionRadius)
            fillExtrusionAmbientOcclusionRadiusTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .fillExtrusionAmbientOcclusionRadiusTransition)
            fillExtrusionAmbientOcclusionWallRadius = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .fillExtrusionAmbientOcclusionWallRadius)
            fillExtrusionAmbientOcclusionWallRadiusTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .fillExtrusionAmbientOcclusionWallRadiusTransition)
            fillExtrusionBase = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .fillExtrusionBase)
            fillExtrusionBaseTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .fillExtrusionBaseTransition)
            fillExtrusionColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .fillExtrusionColor)
            fillExtrusionColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .fillExtrusionColorTransition)
            fillExtrusionCutoffFadeRange = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .fillExtrusionCutoffFadeRange)
            fillExtrusionEmissiveStrength = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .fillExtrusionEmissiveStrength)
            fillExtrusionEmissiveStrengthTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .fillExtrusionEmissiveStrengthTransition)
            fillExtrusionFloodLightColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .fillExtrusionFloodLightColor)
            fillExtrusionFloodLightColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .fillExtrusionFloodLightColorTransition)
            fillExtrusionFloodLightGroundAttenuation = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .fillExtrusionFloodLightGroundAttenuation)
            fillExtrusionFloodLightGroundAttenuationTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .fillExtrusionFloodLightGroundAttenuationTransition)
            fillExtrusionFloodLightGroundRadius = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .fillExtrusionFloodLightGroundRadius)
            fillExtrusionFloodLightGroundRadiusTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .fillExtrusionFloodLightGroundRadiusTransition)
            fillExtrusionFloodLightIntensity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .fillExtrusionFloodLightIntensity)
            fillExtrusionFloodLightIntensityTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .fillExtrusionFloodLightIntensityTransition)
            fillExtrusionFloodLightWallRadius = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .fillExtrusionFloodLightWallRadius)
            fillExtrusionFloodLightWallRadiusTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .fillExtrusionFloodLightWallRadiusTransition)
            fillExtrusionHeight = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .fillExtrusionHeight)
            fillExtrusionHeightTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .fillExtrusionHeightTransition)
            fillExtrusionOpacity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .fillExtrusionOpacity)
            fillExtrusionOpacityTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .fillExtrusionOpacityTransition)
            fillExtrusionPattern = try paintContainer.decodeIfPresent(Value<ResolvedImage>.self, forKey: .fillExtrusionPattern)
            fillExtrusionRoundedRoof = try paintContainer.decodeIfPresent(Value<Bool>.self, forKey: .fillExtrusionRoundedRoof)
            fillExtrusionTranslate = try paintContainer.decodeIfPresent(Value<[Double]>.self, forKey: .fillExtrusionTranslate)
            fillExtrusionTranslateTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .fillExtrusionTranslateTransition)
            fillExtrusionTranslateAnchor = try paintContainer.decodeIfPresent(Value<FillExtrusionTranslateAnchor>.self, forKey: .fillExtrusionTranslateAnchor)
            fillExtrusionVerticalGradient = try paintContainer.decodeIfPresent(Value<Bool>.self, forKey: .fillExtrusionVerticalGradient)
            fillExtrusionVerticalScale = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .fillExtrusionVerticalScale)
            fillExtrusionVerticalScaleTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .fillExtrusionVerticalScaleTransition)
        }

        var visibilityEncoded: Value<Visibility>?
        if let layoutContainer = try? container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout) {
            visibilityEncoded = try layoutContainer.decodeIfPresent(Value<Visibility>.self, forKey: .visibility)
            fillExtrusionEdgeRadius = try layoutContainer.decodeIfPresent(Value<Double>.self, forKey: .fillExtrusionEdgeRadius)
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
        case fillExtrusionEdgeRadius = "fill-extrusion-edge-radius"
        case visibility = "visibility"
    }

    enum PaintCodingKeys: String, CodingKey {
        case fillExtrusionAmbientOcclusionGroundAttenuation = "fill-extrusion-ambient-occlusion-ground-attenuation"
        case fillExtrusionAmbientOcclusionGroundAttenuationTransition = "fill-extrusion-ambient-occlusion-ground-attenuation-transition"
        case fillExtrusionAmbientOcclusionGroundRadius = "fill-extrusion-ambient-occlusion-ground-radius"
        case fillExtrusionAmbientOcclusionGroundRadiusTransition = "fill-extrusion-ambient-occlusion-ground-radius-transition"
        case fillExtrusionAmbientOcclusionIntensity = "fill-extrusion-ambient-occlusion-intensity"
        case fillExtrusionAmbientOcclusionIntensityTransition = "fill-extrusion-ambient-occlusion-intensity-transition"
        case fillExtrusionAmbientOcclusionRadius = "fill-extrusion-ambient-occlusion-radius"
        case fillExtrusionAmbientOcclusionRadiusTransition = "fill-extrusion-ambient-occlusion-radius-transition"
        case fillExtrusionAmbientOcclusionWallRadius = "fill-extrusion-ambient-occlusion-wall-radius"
        case fillExtrusionAmbientOcclusionWallRadiusTransition = "fill-extrusion-ambient-occlusion-wall-radius-transition"
        case fillExtrusionBase = "fill-extrusion-base"
        case fillExtrusionBaseTransition = "fill-extrusion-base-transition"
        case fillExtrusionColor = "fill-extrusion-color"
        case fillExtrusionColorTransition = "fill-extrusion-color-transition"
        case fillExtrusionCutoffFadeRange = "fill-extrusion-cutoff-fade-range"
        case fillExtrusionEmissiveStrength = "fill-extrusion-emissive-strength"
        case fillExtrusionEmissiveStrengthTransition = "fill-extrusion-emissive-strength-transition"
        case fillExtrusionFloodLightColor = "fill-extrusion-flood-light-color"
        case fillExtrusionFloodLightColorTransition = "fill-extrusion-flood-light-color-transition"
        case fillExtrusionFloodLightGroundAttenuation = "fill-extrusion-flood-light-ground-attenuation"
        case fillExtrusionFloodLightGroundAttenuationTransition = "fill-extrusion-flood-light-ground-attenuation-transition"
        case fillExtrusionFloodLightGroundRadius = "fill-extrusion-flood-light-ground-radius"
        case fillExtrusionFloodLightGroundRadiusTransition = "fill-extrusion-flood-light-ground-radius-transition"
        case fillExtrusionFloodLightIntensity = "fill-extrusion-flood-light-intensity"
        case fillExtrusionFloodLightIntensityTransition = "fill-extrusion-flood-light-intensity-transition"
        case fillExtrusionFloodLightWallRadius = "fill-extrusion-flood-light-wall-radius"
        case fillExtrusionFloodLightWallRadiusTransition = "fill-extrusion-flood-light-wall-radius-transition"
        case fillExtrusionHeight = "fill-extrusion-height"
        case fillExtrusionHeightTransition = "fill-extrusion-height-transition"
        case fillExtrusionOpacity = "fill-extrusion-opacity"
        case fillExtrusionOpacityTransition = "fill-extrusion-opacity-transition"
        case fillExtrusionPattern = "fill-extrusion-pattern"
        case fillExtrusionRoundedRoof = "fill-extrusion-rounded-roof"
        case fillExtrusionTranslate = "fill-extrusion-translate"
        case fillExtrusionTranslateTransition = "fill-extrusion-translate-transition"
        case fillExtrusionTranslateAnchor = "fill-extrusion-translate-anchor"
        case fillExtrusionVerticalGradient = "fill-extrusion-vertical-gradient"
        case fillExtrusionVerticalScale = "fill-extrusion-vertical-scale"
        case fillExtrusionVerticalScaleTransition = "fill-extrusion-vertical-scale-transition"
    }
}

@_documentation(visibility: public)
@_spi(Experimental) extension FillExtrusionLayer {
    /// An expression specifying conditions on source features.
    /// Only features that match the filter are displayed.
    @_documentation(visibility: public)
    public func filter(_ newValue: Expression) -> Self {
        with(self, setter(\.filter, newValue))
    }

    /// Name of a source description to be used for this layer.
    /// Required for all layer types except ``BackgroundLayer``, ``SkyLayer``, and ``LocationIndicatorLayer``.
    @_documentation(visibility: public)
    public func source(_ newValue: String) -> Self {
        with(self, setter(\.source, newValue))
    }

    /// Layer to use from a vector tile source.
    ///
    /// Required for vector tile sources.
    /// Prohibited for all other source types, including GeoJSON sources.
    @_documentation(visibility: public)
    public func sourceLayer(_ newValue: String) -> Self {
        with(self, setter(\.sourceLayer, newValue))
    }

    /// The slot this layer is assigned to.
    /// If specified, and a slot with that name exists, it will be placed at that position in the layer order.
    @_documentation(visibility: public)
    public func slot(_ newValue: Slot?) -> Self {
        with(self, setter(\.slot, newValue))
    }

    /// The minimum zoom level for the layer. At zoom levels less than the minzoom, the layer will be hidden.
    @_documentation(visibility: public)
    public func minZoom(_ newValue: Double) -> Self {
        with(self, setter(\.minZoom, newValue))
    }

    /// The maximum zoom level for the layer. At zoom levels equal to or greater than the maxzoom, the layer will be hidden.
    @_documentation(visibility: public)
    public func maxZoom(_ newValue: Double) -> Self {
        with(self, setter(\.maxZoom, newValue))
    }

    /// Radius of a fill extrusion edge in meters. If not zero, rounds extrusion edges for a smoother appearance.
    /// Default value: 0. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillExtrusionEdgeRadius(_ constant: Double) -> Self {
        with(self, setter(\.fillExtrusionEdgeRadius, .constant(constant)))
    }

    /// Radius of a fill extrusion edge in meters. If not zero, rounds extrusion edges for a smoother appearance.
    /// Default value: 0. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillExtrusionEdgeRadius(_ expression: Expression) -> Self {
        with(self, setter(\.fillExtrusionEdgeRadius, .expression(expression)))
    }

    /// Provides a control to futher fine-tune the look of the ambient occlusion on the ground beneath the extruded buildings. Lower values give the effect a more solid look while higher values make it smoother.
    /// Default value: 0.69. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillExtrusionAmbientOcclusionGroundAttenuation(_ constant: Double) -> Self {
        with(self, setter(\.fillExtrusionAmbientOcclusionGroundAttenuation, .constant(constant)))
    }

    /// Transition property for `fillExtrusionAmbientOcclusionGroundAttenuation`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillExtrusionAmbientOcclusionGroundAttenuationTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillExtrusionAmbientOcclusionGroundAttenuationTransition, transition))
    }

    /// Provides a control to futher fine-tune the look of the ambient occlusion on the ground beneath the extruded buildings. Lower values give the effect a more solid look while higher values make it smoother.
    /// Default value: 0.69. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillExtrusionAmbientOcclusionGroundAttenuation(_ expression: Expression) -> Self {
        with(self, setter(\.fillExtrusionAmbientOcclusionGroundAttenuation, .expression(expression)))
    }

    /// The extent of the ambient occlusion effect on the ground beneath the extruded buildings in meters.
    /// Default value: 3. Minimum value: 0.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillExtrusionAmbientOcclusionGroundRadius(_ constant: Double) -> Self {
        with(self, setter(\.fillExtrusionAmbientOcclusionGroundRadius, .constant(constant)))
    }

    /// Transition property for `fillExtrusionAmbientOcclusionGroundRadius`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillExtrusionAmbientOcclusionGroundRadiusTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillExtrusionAmbientOcclusionGroundRadiusTransition, transition))
    }

    /// The extent of the ambient occlusion effect on the ground beneath the extruded buildings in meters.
    /// Default value: 3. Minimum value: 0.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillExtrusionAmbientOcclusionGroundRadius(_ expression: Expression) -> Self {
        with(self, setter(\.fillExtrusionAmbientOcclusionGroundRadius, .expression(expression)))
    }

    /// Controls the intensity of shading near ground and concave angles between walls. Default value 0.0 disables ambient occlusion and values around 0.3 provide the most plausible results for buildings.
    /// Default value: 0. Value range: [0, 1]
    @_documentation(visibility: public)
    public func fillExtrusionAmbientOcclusionIntensity(_ constant: Double) -> Self {
        with(self, setter(\.fillExtrusionAmbientOcclusionIntensity, .constant(constant)))
    }

    /// Transition property for `fillExtrusionAmbientOcclusionIntensity`
    @_documentation(visibility: public)
    public func fillExtrusionAmbientOcclusionIntensityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillExtrusionAmbientOcclusionIntensityTransition, transition))
    }

    /// Controls the intensity of shading near ground and concave angles between walls. Default value 0.0 disables ambient occlusion and values around 0.3 provide the most plausible results for buildings.
    /// Default value: 0. Value range: [0, 1]
    @_documentation(visibility: public)
    public func fillExtrusionAmbientOcclusionIntensity(_ expression: Expression) -> Self {
        with(self, setter(\.fillExtrusionAmbientOcclusionIntensity, .expression(expression)))
    }

    /// Shades area near ground and concave angles between walls where the radius defines only vertical impact. Default value 3.0 corresponds to height of one floor and brings the most plausible results for buildings. This property works only with legacy light. When 3D lights are enabled `fill-extrusion-ambient-occlusion-wall-radius` and `fill-extrusion-ambient-occlusion-ground-radius` are used instead.
    /// Default value: 3. Minimum value: 0.
    @_documentation(visibility: public)
    public func fillExtrusionAmbientOcclusionRadius(_ constant: Double) -> Self {
        with(self, setter(\.fillExtrusionAmbientOcclusionRadius, .constant(constant)))
    }

    /// Transition property for `fillExtrusionAmbientOcclusionRadius`
    @_documentation(visibility: public)
    public func fillExtrusionAmbientOcclusionRadiusTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillExtrusionAmbientOcclusionRadiusTransition, transition))
    }

    /// Shades area near ground and concave angles between walls where the radius defines only vertical impact. Default value 3.0 corresponds to height of one floor and brings the most plausible results for buildings. This property works only with legacy light. When 3D lights are enabled `fill-extrusion-ambient-occlusion-wall-radius` and `fill-extrusion-ambient-occlusion-ground-radius` are used instead.
    /// Default value: 3. Minimum value: 0.
    @_documentation(visibility: public)
    public func fillExtrusionAmbientOcclusionRadius(_ expression: Expression) -> Self {
        with(self, setter(\.fillExtrusionAmbientOcclusionRadius, .expression(expression)))
    }

    /// Shades area near ground and concave angles between walls where the radius defines only vertical impact. Default value 3.0 corresponds to height of one floor and brings the most plausible results for buildings.
    /// Default value: 3. Minimum value: 0.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillExtrusionAmbientOcclusionWallRadius(_ constant: Double) -> Self {
        with(self, setter(\.fillExtrusionAmbientOcclusionWallRadius, .constant(constant)))
    }

    /// Transition property for `fillExtrusionAmbientOcclusionWallRadius`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillExtrusionAmbientOcclusionWallRadiusTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillExtrusionAmbientOcclusionWallRadiusTransition, transition))
    }

    /// Shades area near ground and concave angles between walls where the radius defines only vertical impact. Default value 3.0 corresponds to height of one floor and brings the most plausible results for buildings.
    /// Default value: 3. Minimum value: 0.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillExtrusionAmbientOcclusionWallRadius(_ expression: Expression) -> Self {
        with(self, setter(\.fillExtrusionAmbientOcclusionWallRadius, .expression(expression)))
    }

    /// The height with which to extrude the base of this layer. Must be less than or equal to `fill-extrusion-height`.
    /// Default value: 0. Minimum value: 0.
    @_documentation(visibility: public)
    public func fillExtrusionBase(_ constant: Double) -> Self {
        with(self, setter(\.fillExtrusionBase, .constant(constant)))
    }

    /// Transition property for `fillExtrusionBase`
    @_documentation(visibility: public)
    public func fillExtrusionBaseTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillExtrusionBaseTransition, transition))
    }

    /// The height with which to extrude the base of this layer. Must be less than or equal to `fill-extrusion-height`.
    /// Default value: 0. Minimum value: 0.
    @_documentation(visibility: public)
    public func fillExtrusionBase(_ expression: Expression) -> Self {
        with(self, setter(\.fillExtrusionBase, .expression(expression)))
    }

    /// The base color of the extruded fill. The extrusion's surfaces will be shaded differently based on this color in combination with the root `light` settings. If this color is specified as `rgba` with an alpha component, the alpha component will be ignored; use `fill-extrusion-opacity` to set layer opacity.
    /// Default value: "#000000".
    @_documentation(visibility: public)
    public func fillExtrusionColor(_ constant: StyleColor) -> Self {
        with(self, setter(\.fillExtrusionColor, .constant(constant)))
    }

    /// The base color of the extruded fill. The extrusion's surfaces will be shaded differently based on this color in combination with the root `light` settings. If this color is specified as `rgba` with an alpha component, the alpha component will be ignored; use `fill-extrusion-opacity` to set layer opacity.
    /// Default value: "#000000".
    @_documentation(visibility: public)
    public func fillExtrusionColor(_ color: UIColor) -> Self {
        with(self, setter(\.fillExtrusionColor, .constant(StyleColor(color))))
    }

    /// Transition property for `fillExtrusionColor`
    @_documentation(visibility: public)
    public func fillExtrusionColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillExtrusionColorTransition, transition))
    }

    /// The base color of the extruded fill. The extrusion's surfaces will be shaded differently based on this color in combination with the root `light` settings. If this color is specified as `rgba` with an alpha component, the alpha component will be ignored; use `fill-extrusion-opacity` to set layer opacity.
    /// Default value: "#000000".
    @_documentation(visibility: public)
    public func fillExtrusionColor(_ expression: Expression) -> Self {
        with(self, setter(\.fillExtrusionColor, .expression(expression)))
    }

    /// This parameter defines the range for the fade-out effect before an automatic content cutoff on pitched map views. Fade out is implemented by scaling down and removing buildings in the fade range in a staggered fashion. Opacity is not changed. The fade range is expressed in relation to the height of the map view. A value of 1.0 indicates that the content is faded to the same extent as the map's height in pixels, while a value close to zero represents a sharp cutoff. When the value is set to 0.0, the cutoff is completely disabled. Note: The property has no effect on the map if terrain is enabled.
    /// Default value: 0. Value range: [0, 1]
    @_documentation(visibility: public)
    public func fillExtrusionCutoffFadeRange(_ constant: Double) -> Self {
        with(self, setter(\.fillExtrusionCutoffFadeRange, .constant(constant)))
    }

    /// This parameter defines the range for the fade-out effect before an automatic content cutoff on pitched map views. Fade out is implemented by scaling down and removing buildings in the fade range in a staggered fashion. Opacity is not changed. The fade range is expressed in relation to the height of the map view. A value of 1.0 indicates that the content is faded to the same extent as the map's height in pixels, while a value close to zero represents a sharp cutoff. When the value is set to 0.0, the cutoff is completely disabled. Note: The property has no effect on the map if terrain is enabled.
    /// Default value: 0. Value range: [0, 1]
    @_documentation(visibility: public)
    public func fillExtrusionCutoffFadeRange(_ expression: Expression) -> Self {
        with(self, setter(\.fillExtrusionCutoffFadeRange, .expression(expression)))
    }

    /// Controls the intensity of light emitted on the source features.
    /// Default value: 0. Minimum value: 0.
    @_documentation(visibility: public)
    public func fillExtrusionEmissiveStrength(_ constant: Double) -> Self {
        with(self, setter(\.fillExtrusionEmissiveStrength, .constant(constant)))
    }

    /// Transition property for `fillExtrusionEmissiveStrength`
    @_documentation(visibility: public)
    public func fillExtrusionEmissiveStrengthTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillExtrusionEmissiveStrengthTransition, transition))
    }

    /// Controls the intensity of light emitted on the source features.
    /// Default value: 0. Minimum value: 0.
    @_documentation(visibility: public)
    public func fillExtrusionEmissiveStrength(_ expression: Expression) -> Self {
        with(self, setter(\.fillExtrusionEmissiveStrength, .expression(expression)))
    }

    /// The color of the flood light effect on the walls of the extruded buildings.
    /// Default value: "#ffffff".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillExtrusionFloodLightColor(_ constant: StyleColor) -> Self {
        with(self, setter(\.fillExtrusionFloodLightColor, .constant(constant)))
    }

    /// The color of the flood light effect on the walls of the extruded buildings.
    /// Default value: "#ffffff".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillExtrusionFloodLightColor(_ color: UIColor) -> Self {
        with(self, setter(\.fillExtrusionFloodLightColor, .constant(StyleColor(color))))
    }

    /// Transition property for `fillExtrusionFloodLightColor`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillExtrusionFloodLightColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillExtrusionFloodLightColorTransition, transition))
    }

    /// The color of the flood light effect on the walls of the extruded buildings.
    /// Default value: "#ffffff".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillExtrusionFloodLightColor(_ expression: Expression) -> Self {
        with(self, setter(\.fillExtrusionFloodLightColor, .expression(expression)))
    }

    /// Provides a control to futher fine-tune the look of the flood light on the ground beneath the extruded buildings. Lower values give the effect a more solid look while higher values make it smoother.
    /// Default value: 0.69. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillExtrusionFloodLightGroundAttenuation(_ constant: Double) -> Self {
        with(self, setter(\.fillExtrusionFloodLightGroundAttenuation, .constant(constant)))
    }

    /// Transition property for `fillExtrusionFloodLightGroundAttenuation`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillExtrusionFloodLightGroundAttenuationTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillExtrusionFloodLightGroundAttenuationTransition, transition))
    }

    /// Provides a control to futher fine-tune the look of the flood light on the ground beneath the extruded buildings. Lower values give the effect a more solid look while higher values make it smoother.
    /// Default value: 0.69. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillExtrusionFloodLightGroundAttenuation(_ expression: Expression) -> Self {
        with(self, setter(\.fillExtrusionFloodLightGroundAttenuation, .expression(expression)))
    }

    /// The extent of the flood light effect on the ground beneath the extruded buildings in meters.
    /// Default value: 0.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillExtrusionFloodLightGroundRadius(_ constant: Double) -> Self {
        with(self, setter(\.fillExtrusionFloodLightGroundRadius, .constant(constant)))
    }

    /// Transition property for `fillExtrusionFloodLightGroundRadius`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillExtrusionFloodLightGroundRadiusTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillExtrusionFloodLightGroundRadiusTransition, transition))
    }

    /// The extent of the flood light effect on the ground beneath the extruded buildings in meters.
    /// Default value: 0.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillExtrusionFloodLightGroundRadius(_ expression: Expression) -> Self {
        with(self, setter(\.fillExtrusionFloodLightGroundRadius, .expression(expression)))
    }

    /// The intensity of the flood light color.
    /// Default value: 0. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillExtrusionFloodLightIntensity(_ constant: Double) -> Self {
        with(self, setter(\.fillExtrusionFloodLightIntensity, .constant(constant)))
    }

    /// Transition property for `fillExtrusionFloodLightIntensity`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillExtrusionFloodLightIntensityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillExtrusionFloodLightIntensityTransition, transition))
    }

    /// The intensity of the flood light color.
    /// Default value: 0. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillExtrusionFloodLightIntensity(_ expression: Expression) -> Self {
        with(self, setter(\.fillExtrusionFloodLightIntensity, .expression(expression)))
    }

    /// The extent of the flood light effect on the walls of the extruded buildings in meters.
    /// Default value: 0. Minimum value: 0.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillExtrusionFloodLightWallRadius(_ constant: Double) -> Self {
        with(self, setter(\.fillExtrusionFloodLightWallRadius, .constant(constant)))
    }

    /// Transition property for `fillExtrusionFloodLightWallRadius`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillExtrusionFloodLightWallRadiusTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillExtrusionFloodLightWallRadiusTransition, transition))
    }

    /// The extent of the flood light effect on the walls of the extruded buildings in meters.
    /// Default value: 0. Minimum value: 0.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillExtrusionFloodLightWallRadius(_ expression: Expression) -> Self {
        with(self, setter(\.fillExtrusionFloodLightWallRadius, .expression(expression)))
    }

    /// The height with which to extrude this layer.
    /// Default value: 0. Minimum value: 0.
    @_documentation(visibility: public)
    public func fillExtrusionHeight(_ constant: Double) -> Self {
        with(self, setter(\.fillExtrusionHeight, .constant(constant)))
    }

    /// Transition property for `fillExtrusionHeight`
    @_documentation(visibility: public)
    public func fillExtrusionHeightTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillExtrusionHeightTransition, transition))
    }

    /// The height with which to extrude this layer.
    /// Default value: 0. Minimum value: 0.
    @_documentation(visibility: public)
    public func fillExtrusionHeight(_ expression: Expression) -> Self {
        with(self, setter(\.fillExtrusionHeight, .expression(expression)))
    }

    /// The opacity of the entire fill extrusion layer. This is rendered on a per-layer, not per-feature, basis, and data-driven styling is not available.
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    public func fillExtrusionOpacity(_ constant: Double) -> Self {
        with(self, setter(\.fillExtrusionOpacity, .constant(constant)))
    }

    /// Transition property for `fillExtrusionOpacity`
    @_documentation(visibility: public)
    public func fillExtrusionOpacityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillExtrusionOpacityTransition, transition))
    }

    /// The opacity of the entire fill extrusion layer. This is rendered on a per-layer, not per-feature, basis, and data-driven styling is not available.
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    public func fillExtrusionOpacity(_ expression: Expression) -> Self {
        with(self, setter(\.fillExtrusionOpacity, .expression(expression)))
    }

    /// Name of image in sprite to use for drawing images on extruded fills. For seamless patterns, image width and height must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    @_documentation(visibility: public)
    public func fillExtrusionPattern(_ constant: String) -> Self {
        with(self, setter(\.fillExtrusionPattern, .constant(.name(constant))))
    }

    /// Name of image in sprite to use for drawing images on extruded fills. For seamless patterns, image width and height must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    @_documentation(visibility: public)
    public func fillExtrusionPattern(_ expression: Expression) -> Self {
        with(self, setter(\.fillExtrusionPattern, .expression(expression)))
    }

    /// Indicates whether top edges should be rounded when fill-extrusion-edge-radius has a value greater than 0. If false, rounded edges are only applied to the sides. Default is true.
    /// Default value: true.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillExtrusionRoundedRoof(_ constant: Bool) -> Self {
        with(self, setter(\.fillExtrusionRoundedRoof, .constant(constant)))
    }

    /// Indicates whether top edges should be rounded when fill-extrusion-edge-radius has a value greater than 0. If false, rounded edges are only applied to the sides. Default is true.
    /// Default value: true.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillExtrusionRoundedRoof(_ expression: Expression) -> Self {
        with(self, setter(\.fillExtrusionRoundedRoof, .expression(expression)))
    }

    /// The geometry's offset. Values are [x, y] where negatives indicate left and up (on the flat plane), respectively.
    /// Default value: [0,0].
    @_documentation(visibility: public)
    public func fillExtrusionTranslate(x: Double, y: Double) -> Self {
        with(self, setter(\.fillExtrusionTranslate, .constant([x, y])))
    }

    /// Transition property for `fillExtrusionTranslate`
    @_documentation(visibility: public)
    public func fillExtrusionTranslateTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillExtrusionTranslateTransition, transition))
    }

    /// The geometry's offset. Values are [x, y] where negatives indicate left and up (on the flat plane), respectively.
    /// Default value: [0,0].
    @_documentation(visibility: public)
    public func fillExtrusionTranslate(_ expression: Expression) -> Self {
        with(self, setter(\.fillExtrusionTranslate, .expression(expression)))
    }

    /// Controls the frame of reference for `fill-extrusion-translate`.
    /// Default value: "map".
    @_documentation(visibility: public)
    public func fillExtrusionTranslateAnchor(_ constant: FillExtrusionTranslateAnchor) -> Self {
        with(self, setter(\.fillExtrusionTranslateAnchor, .constant(constant)))
    }

    /// Controls the frame of reference for `fill-extrusion-translate`.
    /// Default value: "map".
    @_documentation(visibility: public)
    public func fillExtrusionTranslateAnchor(_ expression: Expression) -> Self {
        with(self, setter(\.fillExtrusionTranslateAnchor, .expression(expression)))
    }

    /// Whether to apply a vertical gradient to the sides of a fill-extrusion layer. If true, sides will be shaded slightly darker farther down.
    /// Default value: true.
    @_documentation(visibility: public)
    public func fillExtrusionVerticalGradient(_ constant: Bool) -> Self {
        with(self, setter(\.fillExtrusionVerticalGradient, .constant(constant)))
    }

    /// Whether to apply a vertical gradient to the sides of a fill-extrusion layer. If true, sides will be shaded slightly darker farther down.
    /// Default value: true.
    @_documentation(visibility: public)
    public func fillExtrusionVerticalGradient(_ expression: Expression) -> Self {
        with(self, setter(\.fillExtrusionVerticalGradient, .expression(expression)))
    }

    /// A global multiplier that can be used to scale base, height, AO, and flood light of the fill extrusions.
    /// Default value: 1. Minimum value: 0.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillExtrusionVerticalScale(_ constant: Double) -> Self {
        with(self, setter(\.fillExtrusionVerticalScale, .constant(constant)))
    }

    /// Transition property for `fillExtrusionVerticalScale`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillExtrusionVerticalScaleTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillExtrusionVerticalScaleTransition, transition))
    }

    /// A global multiplier that can be used to scale base, height, AO, and flood light of the fill extrusions.
    /// Default value: 1. Minimum value: 0.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillExtrusionVerticalScale(_ expression: Expression) -> Self {
        with(self, setter(\.fillExtrusionVerticalScale, .expression(expression)))
    }
}

@available(iOS 13.0, *)
@_spi(Experimental)
extension FillExtrusionLayer: MapStyleContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        node.mount(MountedLayer(layer: self))
    }
}

// End of generated file.
