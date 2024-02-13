// This file is generated.
import Foundation

/// A filled circle.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#layers-circle)
public struct CircleLayer: Layer {

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

    /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
    public var circleSortKey: Value<Double>?

    /// Amount to blur the circle. 1 blurs the circle such that only the centerpoint is full opacity.
    public var circleBlur: Value<Double>?

    /// Transition options for `circleBlur`.
    public var circleBlurTransition: StyleTransition?

    /// The fill color of the circle.
    public var circleColor: Value<StyleColor>?

    /// Transition options for `circleColor`.
    public var circleColorTransition: StyleTransition?

    /// Controls the intensity of light emitted on the source features.
    public var circleEmissiveStrength: Value<Double>?

    /// Transition options for `circleEmissiveStrength`.
    public var circleEmissiveStrengthTransition: StyleTransition?

    /// The opacity at which the circle will be drawn.
    public var circleOpacity: Value<Double>?

    /// Transition options for `circleOpacity`.
    public var circleOpacityTransition: StyleTransition?

    /// Orientation of circle when map is pitched.
    public var circlePitchAlignment: Value<CirclePitchAlignment>?

    /// Controls the scaling behavior of the circle when the map is pitched.
    public var circlePitchScale: Value<CirclePitchScale>?

    /// Circle radius.
    public var circleRadius: Value<Double>?

    /// Transition options for `circleRadius`.
    public var circleRadiusTransition: StyleTransition?

    /// The stroke color of the circle.
    public var circleStrokeColor: Value<StyleColor>?

    /// Transition options for `circleStrokeColor`.
    public var circleStrokeColorTransition: StyleTransition?

    /// The opacity of the circle's stroke.
    public var circleStrokeOpacity: Value<Double>?

    /// Transition options for `circleStrokeOpacity`.
    public var circleStrokeOpacityTransition: StyleTransition?

    /// The width of the circle's stroke. Strokes are placed outside of the `circle-radius`.
    public var circleStrokeWidth: Value<Double>?

    /// Transition options for `circleStrokeWidth`.
    public var circleStrokeWidthTransition: StyleTransition?

    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
    public var circleTranslate: Value<[Double]>?

    /// Transition options for `circleTranslate`.
    public var circleTranslateTransition: StyleTransition?

    /// Controls the frame of reference for `circle-translate`.
    public var circleTranslateAnchor: Value<CircleTranslateAnchor>?

    public init(id: String, source: String) {
        self.source = source
        self.id = id
        self.type = LayerType.circle
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
        try paintContainer.encodeIfPresent(circleBlur, forKey: .circleBlur)
        try paintContainer.encodeIfPresent(circleBlurTransition, forKey: .circleBlurTransition)
        try paintContainer.encodeIfPresent(circleColor, forKey: .circleColor)
        try paintContainer.encodeIfPresent(circleColorTransition, forKey: .circleColorTransition)
        try paintContainer.encodeIfPresent(circleEmissiveStrength, forKey: .circleEmissiveStrength)
        try paintContainer.encodeIfPresent(circleEmissiveStrengthTransition, forKey: .circleEmissiveStrengthTransition)
        try paintContainer.encodeIfPresent(circleOpacity, forKey: .circleOpacity)
        try paintContainer.encodeIfPresent(circleOpacityTransition, forKey: .circleOpacityTransition)
        try paintContainer.encodeIfPresent(circlePitchAlignment, forKey: .circlePitchAlignment)
        try paintContainer.encodeIfPresent(circlePitchScale, forKey: .circlePitchScale)
        try paintContainer.encodeIfPresent(circleRadius, forKey: .circleRadius)
        try paintContainer.encodeIfPresent(circleRadiusTransition, forKey: .circleRadiusTransition)
        try paintContainer.encodeIfPresent(circleStrokeColor, forKey: .circleStrokeColor)
        try paintContainer.encodeIfPresent(circleStrokeColorTransition, forKey: .circleStrokeColorTransition)
        try paintContainer.encodeIfPresent(circleStrokeOpacity, forKey: .circleStrokeOpacity)
        try paintContainer.encodeIfPresent(circleStrokeOpacityTransition, forKey: .circleStrokeOpacityTransition)
        try paintContainer.encodeIfPresent(circleStrokeWidth, forKey: .circleStrokeWidth)
        try paintContainer.encodeIfPresent(circleStrokeWidthTransition, forKey: .circleStrokeWidthTransition)
        try paintContainer.encodeIfPresent(circleTranslate, forKey: .circleTranslate)
        try paintContainer.encodeIfPresent(circleTranslateTransition, forKey: .circleTranslateTransition)
        try paintContainer.encodeIfPresent(circleTranslateAnchor, forKey: .circleTranslateAnchor)

        var layoutContainer = container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)
        try layoutContainer.encode(visibility, forKey: .visibility)
        try layoutContainer.encodeIfPresent(circleSortKey, forKey: .circleSortKey)
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
            circleBlur = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .circleBlur)
            circleBlurTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .circleBlurTransition)
            circleColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .circleColor)
            circleColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .circleColorTransition)
            circleEmissiveStrength = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .circleEmissiveStrength)
            circleEmissiveStrengthTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .circleEmissiveStrengthTransition)
            circleOpacity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .circleOpacity)
            circleOpacityTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .circleOpacityTransition)
            circlePitchAlignment = try paintContainer.decodeIfPresent(Value<CirclePitchAlignment>.self, forKey: .circlePitchAlignment)
            circlePitchScale = try paintContainer.decodeIfPresent(Value<CirclePitchScale>.self, forKey: .circlePitchScale)
            circleRadius = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .circleRadius)
            circleRadiusTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .circleRadiusTransition)
            circleStrokeColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .circleStrokeColor)
            circleStrokeColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .circleStrokeColorTransition)
            circleStrokeOpacity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .circleStrokeOpacity)
            circleStrokeOpacityTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .circleStrokeOpacityTransition)
            circleStrokeWidth = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .circleStrokeWidth)
            circleStrokeWidthTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .circleStrokeWidthTransition)
            circleTranslate = try paintContainer.decodeIfPresent(Value<[Double]>.self, forKey: .circleTranslate)
            circleTranslateTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .circleTranslateTransition)
            circleTranslateAnchor = try paintContainer.decodeIfPresent(Value<CircleTranslateAnchor>.self, forKey: .circleTranslateAnchor)
        }

        var visibilityEncoded: Value<Visibility>?
        if let layoutContainer = try? container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout) {
            visibilityEncoded = try layoutContainer.decodeIfPresent(Value<Visibility>.self, forKey: .visibility)
            circleSortKey = try layoutContainer.decodeIfPresent(Value<Double>.self, forKey: .circleSortKey)
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
        case circleSortKey = "circle-sort-key"
        case visibility = "visibility"
    }

    enum PaintCodingKeys: String, CodingKey {
        case circleBlur = "circle-blur"
        case circleBlurTransition = "circle-blur-transition"
        case circleColor = "circle-color"
        case circleColorTransition = "circle-color-transition"
        case circleEmissiveStrength = "circle-emissive-strength"
        case circleEmissiveStrengthTransition = "circle-emissive-strength-transition"
        case circleOpacity = "circle-opacity"
        case circleOpacityTransition = "circle-opacity-transition"
        case circlePitchAlignment = "circle-pitch-alignment"
        case circlePitchScale = "circle-pitch-scale"
        case circleRadius = "circle-radius"
        case circleRadiusTransition = "circle-radius-transition"
        case circleStrokeColor = "circle-stroke-color"
        case circleStrokeColorTransition = "circle-stroke-color-transition"
        case circleStrokeOpacity = "circle-stroke-opacity"
        case circleStrokeOpacityTransition = "circle-stroke-opacity-transition"
        case circleStrokeWidth = "circle-stroke-width"
        case circleStrokeWidthTransition = "circle-stroke-width-transition"
        case circleTranslate = "circle-translate"
        case circleTranslateTransition = "circle-translate-transition"
        case circleTranslateAnchor = "circle-translate-anchor"
    }
}

// End of generated file.
