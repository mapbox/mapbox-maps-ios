// This file is generated.
import Foundation

/// A filled circle.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#layers-circle)
public struct CircleLayer: Layer {

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

    public init(id: String) {
        self.id = id
        self.type = LayerType.circle
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
        try nilEncoder.encode(circleBlur, forKey: .circleBlur, to: &paintContainer)
        try nilEncoder.encode(circleBlurTransition, forKey: .circleBlurTransition, to: &paintContainer)
        try nilEncoder.encode(circleColor, forKey: .circleColor, to: &paintContainer)
        try nilEncoder.encode(circleColorTransition, forKey: .circleColorTransition, to: &paintContainer)
        try nilEncoder.encode(circleOpacity, forKey: .circleOpacity, to: &paintContainer)
        try nilEncoder.encode(circleOpacityTransition, forKey: .circleOpacityTransition, to: &paintContainer)
        try nilEncoder.encode(circlePitchAlignment, forKey: .circlePitchAlignment, to: &paintContainer)
        try nilEncoder.encode(circlePitchScale, forKey: .circlePitchScale, to: &paintContainer)
        try nilEncoder.encode(circleRadius, forKey: .circleRadius, to: &paintContainer)
        try nilEncoder.encode(circleRadiusTransition, forKey: .circleRadiusTransition, to: &paintContainer)
        try nilEncoder.encode(circleStrokeColor, forKey: .circleStrokeColor, to: &paintContainer)
        try nilEncoder.encode(circleStrokeColorTransition, forKey: .circleStrokeColorTransition, to: &paintContainer)
        try nilEncoder.encode(circleStrokeOpacity, forKey: .circleStrokeOpacity, to: &paintContainer)
        try nilEncoder.encode(circleStrokeOpacityTransition, forKey: .circleStrokeOpacityTransition, to: &paintContainer)
        try nilEncoder.encode(circleStrokeWidth, forKey: .circleStrokeWidth, to: &paintContainer)
        try nilEncoder.encode(circleStrokeWidthTransition, forKey: .circleStrokeWidthTransition, to: &paintContainer)
        try nilEncoder.encode(circleTranslate, forKey: .circleTranslate, to: &paintContainer)
        try nilEncoder.encode(circleTranslateTransition, forKey: .circleTranslateTransition, to: &paintContainer)
        try nilEncoder.encode(circleTranslateAnchor, forKey: .circleTranslateAnchor, to: &paintContainer)

        var layoutContainer = container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)
        try nilEncoder.encode(visibility, forKey: .visibility, to: &layoutContainer)
        try nilEncoder.encode(circleSortKey, forKey: .circleSortKey, to: &layoutContainer)
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
            circleBlur = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .circleBlur)
            circleBlurTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .circleBlurTransition)
            circleColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .circleColor)
            circleColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .circleColorTransition)
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

        if let layoutContainer = try? container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout) {
            visibility = try layoutContainer.decodeIfPresent(Value<Visibility>.self, forKey: .visibility)
            circleSortKey = try layoutContainer.decodeIfPresent(Value<Double>.self, forKey: .circleSortKey)
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
        case circleSortKey = "circle-sort-key"
        case visibility = "visibility"
    }

    enum PaintCodingKeys: String, CodingKey {
        case circleBlur = "circle-blur"
        case circleBlurTransition = "circle-blur-transition"
        case circleColor = "circle-color"
        case circleColorTransition = "circle-color-transition"
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
