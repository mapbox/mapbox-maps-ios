// This file is generated.
import Foundation

/// An extruded (3D) polygon.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#layers-fill-extrusion)
public struct FillExtrusionLayer: Layer {

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

    /// Controls the intensity of shading near ground and concave angles between walls. Default value 0.0 disables ambient occlusion and values around 0.3 provide the most plausible results for buildings.
    public var fillExtrusionAmbientOcclusionIntensity: Value<Double>?

    /// Transition options for `fillExtrusionAmbientOcclusionIntensity`.
    public var fillExtrusionAmbientOcclusionIntensityTransition: StyleTransition?

    /// Shades area near ground and concave angles between walls where the radius defines only vertical impact. Default value 3.0 corresponds to height of one floor and brings the most plausible results for buildings.
    public var fillExtrusionAmbientOcclusionRadius: Value<Double>?

    /// Transition options for `fillExtrusionAmbientOcclusionRadius`.
    public var fillExtrusionAmbientOcclusionRadiusTransition: StyleTransition?

    /// The height with which to extrude the base of this layer. Must be less than or equal to `fill-extrusion-height`.
    public var fillExtrusionBase: Value<Double>?

    /// Transition options for `fillExtrusionBase`.
    public var fillExtrusionBaseTransition: StyleTransition?

    /// The base color of the extruded fill. The extrusion's surfaces will be shaded differently based on this color in combination with the root `light` settings. If this color is specified as `rgba` with an alpha component, the alpha component will be ignored; use `fill-extrusion-opacity` to set layer opacity.
    public var fillExtrusionColor: Value<StyleColor>?

    /// Transition options for `fillExtrusionColor`.
    public var fillExtrusionColorTransition: StyleTransition?

    /// The height with which to extrude this layer.
    public var fillExtrusionHeight: Value<Double>?

    /// Transition options for `fillExtrusionHeight`.
    public var fillExtrusionHeightTransition: StyleTransition?

    /// The opacity of the entire fill extrusion layer. This is rendered on a per-layer, not per-feature, basis, and data-driven styling is not available.
    public var fillExtrusionOpacity: Value<Double>?

    /// Transition options for `fillExtrusionOpacity`.
    public var fillExtrusionOpacityTransition: StyleTransition?

    /// Name of image in sprite to use for drawing images on extruded fills. For seamless patterns, image width and height must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    public var fillExtrusionPattern: Value<ResolvedImage>?

    /// Transition options for `fillExtrusionPattern`.
    @available(*, deprecated, message: "This property is deprecated and will be removed in the future. Setting this will have no effect.")
    public var fillExtrusionPatternTransition: StyleTransition?

    /// The geometry's offset. Values are [x, y] where negatives indicate left and up (on the flat plane), respectively.
    public var fillExtrusionTranslate: Value<[Double]>?

    /// Transition options for `fillExtrusionTranslate`.
    public var fillExtrusionTranslateTransition: StyleTransition?

    /// Controls the frame of reference for `fill-extrusion-translate`.
    public var fillExtrusionTranslateAnchor: Value<FillExtrusionTranslateAnchor>?

    /// Whether to apply a vertical gradient to the sides of a fill-extrusion layer. If true, sides will be shaded slightly darker farther down.
    public var fillExtrusionVerticalGradient: Value<Bool>?

    public init(id: String) {
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
        try container.encodeIfPresent(minZoom, forKey: .minZoom)
        try container.encodeIfPresent(maxZoom, forKey: .maxZoom)

        var paintContainer = container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint)
        try paintContainer.encodeIfPresent(fillExtrusionAmbientOcclusionIntensity, forKey: .fillExtrusionAmbientOcclusionIntensity)
        try paintContainer.encodeIfPresent(fillExtrusionAmbientOcclusionIntensityTransition, forKey: .fillExtrusionAmbientOcclusionIntensityTransition)
        try paintContainer.encodeIfPresent(fillExtrusionAmbientOcclusionRadius, forKey: .fillExtrusionAmbientOcclusionRadius)
        try paintContainer.encodeIfPresent(fillExtrusionAmbientOcclusionRadiusTransition, forKey: .fillExtrusionAmbientOcclusionRadiusTransition)
        try paintContainer.encodeIfPresent(fillExtrusionBase, forKey: .fillExtrusionBase)
        try paintContainer.encodeIfPresent(fillExtrusionBaseTransition, forKey: .fillExtrusionBaseTransition)
        try paintContainer.encodeIfPresent(fillExtrusionColor, forKey: .fillExtrusionColor)
        try paintContainer.encodeIfPresent(fillExtrusionColorTransition, forKey: .fillExtrusionColorTransition)
        try paintContainer.encodeIfPresent(fillExtrusionHeight, forKey: .fillExtrusionHeight)
        try paintContainer.encodeIfPresent(fillExtrusionHeightTransition, forKey: .fillExtrusionHeightTransition)
        try paintContainer.encodeIfPresent(fillExtrusionOpacity, forKey: .fillExtrusionOpacity)
        try paintContainer.encodeIfPresent(fillExtrusionOpacityTransition, forKey: .fillExtrusionOpacityTransition)
        try paintContainer.encodeIfPresent(fillExtrusionPattern, forKey: .fillExtrusionPattern)
        try paintContainer.encodeIfPresent(fillExtrusionTranslate, forKey: .fillExtrusionTranslate)
        try paintContainer.encodeIfPresent(fillExtrusionTranslateTransition, forKey: .fillExtrusionTranslateTransition)
        try paintContainer.encodeIfPresent(fillExtrusionTranslateAnchor, forKey: .fillExtrusionTranslateAnchor)
        try paintContainer.encodeIfPresent(fillExtrusionVerticalGradient, forKey: .fillExtrusionVerticalGradient)

        var layoutContainer = container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)
        try layoutContainer.encodeIfPresent(visibility, forKey: .visibility)
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
            fillExtrusionAmbientOcclusionIntensity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .fillExtrusionAmbientOcclusionIntensity)
            fillExtrusionAmbientOcclusionIntensityTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .fillExtrusionAmbientOcclusionIntensityTransition)
            fillExtrusionAmbientOcclusionRadius = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .fillExtrusionAmbientOcclusionRadius)
            fillExtrusionAmbientOcclusionRadiusTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .fillExtrusionAmbientOcclusionRadiusTransition)
            fillExtrusionBase = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .fillExtrusionBase)
            fillExtrusionBaseTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .fillExtrusionBaseTransition)
            fillExtrusionColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .fillExtrusionColor)
            fillExtrusionColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .fillExtrusionColorTransition)
            fillExtrusionHeight = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .fillExtrusionHeight)
            fillExtrusionHeightTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .fillExtrusionHeightTransition)
            fillExtrusionOpacity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .fillExtrusionOpacity)
            fillExtrusionOpacityTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .fillExtrusionOpacityTransition)
            fillExtrusionPattern = try paintContainer.decodeIfPresent(Value<ResolvedImage>.self, forKey: .fillExtrusionPattern)
            fillExtrusionTranslate = try paintContainer.decodeIfPresent(Value<[Double]>.self, forKey: .fillExtrusionTranslate)
            fillExtrusionTranslateTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .fillExtrusionTranslateTransition)
            fillExtrusionTranslateAnchor = try paintContainer.decodeIfPresent(Value<FillExtrusionTranslateAnchor>.self, forKey: .fillExtrusionTranslateAnchor)
            fillExtrusionVerticalGradient = try paintContainer.decodeIfPresent(Value<Bool>.self, forKey: .fillExtrusionVerticalGradient)
        }

        if let layoutContainer = try? container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout) {
            visibility = try layoutContainer.decodeIfPresent(Value<Visibility>.self, forKey: .visibility)
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
        case visibility = "visibility"
    }

    enum PaintCodingKeys: String, CodingKey {
        case fillExtrusionAmbientOcclusionIntensity = "fill-extrusion-ambient-occlusion-intensity"
        case fillExtrusionAmbientOcclusionIntensityTransition = "fill-extrusion-ambient-occlusion-intensity-transition"
        case fillExtrusionAmbientOcclusionRadius = "fill-extrusion-ambient-occlusion-radius"
        case fillExtrusionAmbientOcclusionRadiusTransition = "fill-extrusion-ambient-occlusion-radius-transition"
        case fillExtrusionBase = "fill-extrusion-base"
        case fillExtrusionBaseTransition = "fill-extrusion-base-transition"
        case fillExtrusionColor = "fill-extrusion-color"
        case fillExtrusionColorTransition = "fill-extrusion-color-transition"
        case fillExtrusionHeight = "fill-extrusion-height"
        case fillExtrusionHeightTransition = "fill-extrusion-height-transition"
        case fillExtrusionOpacity = "fill-extrusion-opacity"
        case fillExtrusionOpacityTransition = "fill-extrusion-opacity-transition"
        case fillExtrusionPattern = "fill-extrusion-pattern"
        case fillExtrusionTranslate = "fill-extrusion-translate"
        case fillExtrusionTranslateTransition = "fill-extrusion-translate-transition"
        case fillExtrusionTranslateAnchor = "fill-extrusion-translate-anchor"
        case fillExtrusionVerticalGradient = "fill-extrusion-vertical-gradient"
    }
}

// End of generated file.
