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

    /// Controls the intensity of ambient occlusion (AO) shading. Current AO implementation is a low-cost best-effort approach that shades area near ground and concave angles between walls. Default value 0.0 disables ambient occlusion and values around 0.3 provide the most plausible results for buildings.
    public var fillExtrusionAmbientOcclusionIntensity: Value<Double>?

    /// Transition options for `fillExtrusionAmbientOcclusionIntensity`.
    public var fillExtrusionAmbientOcclusionIntensityTransition: StyleTransition?

    /// The radius of ambient occlusion (AO) shading, in meters. Current AO implementation is a low-cost best-effort approach that shades area near ground and concave angles between walls where the radius defines only vertical impact. Default value 3.0 corresponds to hight of one floor and brings the most plausible results for buildings.
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
        try nilEncoder.encode(fillExtrusionAmbientOcclusionIntensity, forKey: .fillExtrusionAmbientOcclusionIntensity, to: &paintContainer)
        try nilEncoder.encode(fillExtrusionAmbientOcclusionIntensityTransition, forKey: .fillExtrusionAmbientOcclusionIntensityTransition, to: &paintContainer)
        try nilEncoder.encode(fillExtrusionAmbientOcclusionRadius, forKey: .fillExtrusionAmbientOcclusionRadius, to: &paintContainer)
        try nilEncoder.encode(fillExtrusionAmbientOcclusionRadiusTransition, forKey: .fillExtrusionAmbientOcclusionRadiusTransition, to: &paintContainer)
        try nilEncoder.encode(fillExtrusionBase, forKey: .fillExtrusionBase, to: &paintContainer)
        try nilEncoder.encode(fillExtrusionBaseTransition, forKey: .fillExtrusionBaseTransition, to: &paintContainer)
        try nilEncoder.encode(fillExtrusionColor, forKey: .fillExtrusionColor, to: &paintContainer)
        try nilEncoder.encode(fillExtrusionColorTransition, forKey: .fillExtrusionColorTransition, to: &paintContainer)
        try nilEncoder.encode(fillExtrusionHeight, forKey: .fillExtrusionHeight, to: &paintContainer)
        try nilEncoder.encode(fillExtrusionHeightTransition, forKey: .fillExtrusionHeightTransition, to: &paintContainer)
        try nilEncoder.encode(fillExtrusionOpacity, forKey: .fillExtrusionOpacity, to: &paintContainer)
        try nilEncoder.encode(fillExtrusionOpacityTransition, forKey: .fillExtrusionOpacityTransition, to: &paintContainer)
        try nilEncoder.encode(fillExtrusionPattern, forKey: .fillExtrusionPattern, to: &paintContainer)
        try nilEncoder.encode(fillExtrusionPatternTransition, forKey: .fillExtrusionPatternTransition, to: &paintContainer)
        try nilEncoder.encode(fillExtrusionTranslate, forKey: .fillExtrusionTranslate, to: &paintContainer)
        try nilEncoder.encode(fillExtrusionTranslateTransition, forKey: .fillExtrusionTranslateTransition, to: &paintContainer)
        try nilEncoder.encode(fillExtrusionTranslateAnchor, forKey: .fillExtrusionTranslateAnchor, to: &paintContainer)
        try nilEncoder.encode(fillExtrusionVerticalGradient, forKey: .fillExtrusionVerticalGradient, to: &paintContainer)

        var layoutContainer = container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)
        try nilEncoder.encode(visibility, forKey: .visibility, to: &layoutContainer)
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
            fillExtrusionPatternTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .fillExtrusionPatternTransition)
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
        case fillExtrusionPatternTransition = "fill-extrusion-pattern-transition"
        case fillExtrusionTranslate = "fill-extrusion-translate"
        case fillExtrusionTranslateTransition = "fill-extrusion-translate-transition"
        case fillExtrusionTranslateAnchor = "fill-extrusion-translate-anchor"
        case fillExtrusionVerticalGradient = "fill-extrusion-vertical-gradient"
    }
}

// End of generated file.
