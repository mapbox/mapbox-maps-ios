// This file is generated.
import Foundation

/// A stroked line.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#layers-line)
public struct LineLayer: Layer {

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

    /// The display of line endings.
    public var lineCap: Value<LineCap>?

    /// The display of lines when joining.
    public var lineJoin: Value<LineJoin>?

    /// Used to automatically convert miter joins to bevel joins for sharp angles.
    public var lineMiterLimit: Value<Double>?

    /// Used to automatically convert round joins to miter joins for shallow angles.
    public var lineRoundLimit: Value<Double>?

    /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
    public var lineSortKey: Value<Double>?

    /// Blur applied to the line, in pixels.
    public var lineBlur: Value<Double>?

    /// Transition options for `lineBlur`.
    public var lineBlurTransition: StyleTransition?

    /// The color with which the line will be drawn.
    public var lineColor: Value<StyleColor>?

    /// Transition options for `lineColor`.
    public var lineColorTransition: StyleTransition?

    /// Specifies the lengths of the alternating dashes and gaps that form the dash pattern. The lengths are later scaled by the line width. To convert a dash length to pixels, multiply the length by the current line width. Note that GeoJSON sources with `lineMetrics: true` specified won't render dashed lines to the expected scale. Also note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    public var lineDasharray: Value<[Double]>?

    /// Transition options for `lineDasharray`.
    public var lineDasharrayTransition: StyleTransition?

    /// Draws a line casing outside of a line's actual path. Value indicates the width of the inner gap.
    public var lineGapWidth: Value<Double>?

    /// Transition options for `lineGapWidth`.
    public var lineGapWidthTransition: StyleTransition?

    /// Defines a gradient with which to color a line feature. Can only be used with GeoJSON sources that specify `"lineMetrics": true`.
    public var lineGradient: Value<StyleColor>?

    /// The line's offset. For linear features, a positive value offsets the line to the right, relative to the direction of the line, and a negative value to the left. For polygon features, a positive value results in an inset, and a negative value results in an outset.
    public var lineOffset: Value<Double>?

    /// Transition options for `lineOffset`.
    public var lineOffsetTransition: StyleTransition?

    /// The opacity at which the line will be drawn.
    public var lineOpacity: Value<Double>?

    /// Transition options for `lineOpacity`.
    public var lineOpacityTransition: StyleTransition?

    /// Name of image in sprite to use for drawing image lines. For seamless patterns, image width must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    public var linePattern: Value<ResolvedImage>?

    /// Transition options for `linePattern`.
    public var linePatternTransition: StyleTransition?

    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
    public var lineTranslate: Value<[Double]>?

    /// Transition options for `lineTranslate`.
    public var lineTranslateTransition: StyleTransition?

    /// Controls the frame of reference for `line-translate`.
    public var lineTranslateAnchor: Value<LineTranslateAnchor>?

    /// The line trim-off percentage range based on the whole line gradinet range [0.0, 1.0]. The line part between [trim-start, trim-end] will be marked as transparent to make a route vanishing effect. If either 'trim-start' or 'trim-end' offset is out of valid range, the default range will be set.
    public var lineTrimOffset: Value<[Double]>?

    /// Stroke thickness.
    public var lineWidth: Value<Double>?

    /// Transition options for `lineWidth`.
    public var lineWidthTransition: StyleTransition?

    public init(id: String) {
        self.id = id
        self.type = LayerType.line
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
        try nilEncoder.encode(lineBlur, forKey: .lineBlur, to: &paintContainer)
        try nilEncoder.encode(lineBlurTransition, forKey: .lineBlurTransition, to: &paintContainer)
        try nilEncoder.encode(lineColor, forKey: .lineColor, to: &paintContainer)
        try nilEncoder.encode(lineColorTransition, forKey: .lineColorTransition, to: &paintContainer)
        try nilEncoder.encode(lineDasharray, forKey: .lineDasharray, to: &paintContainer)
        try nilEncoder.encode(lineDasharrayTransition, forKey: .lineDasharrayTransition, to: &paintContainer)
        try nilEncoder.encode(lineGapWidth, forKey: .lineGapWidth, to: &paintContainer)
        try nilEncoder.encode(lineGapWidthTransition, forKey: .lineGapWidthTransition, to: &paintContainer)
        try nilEncoder.encode(lineGradient, forKey: .lineGradient, to: &paintContainer)
        try nilEncoder.encode(lineOffset, forKey: .lineOffset, to: &paintContainer)
        try nilEncoder.encode(lineOffsetTransition, forKey: .lineOffsetTransition, to: &paintContainer)
        try nilEncoder.encode(lineOpacity, forKey: .lineOpacity, to: &paintContainer)
        try nilEncoder.encode(lineOpacityTransition, forKey: .lineOpacityTransition, to: &paintContainer)
        try nilEncoder.encode(linePattern, forKey: .linePattern, to: &paintContainer)
        try nilEncoder.encode(linePatternTransition, forKey: .linePatternTransition, to: &paintContainer)
        try nilEncoder.encode(lineTranslate, forKey: .lineTranslate, to: &paintContainer)
        try nilEncoder.encode(lineTranslateTransition, forKey: .lineTranslateTransition, to: &paintContainer)
        try nilEncoder.encode(lineTranslateAnchor, forKey: .lineTranslateAnchor, to: &paintContainer)
        try nilEncoder.encode(lineTrimOffset, forKey: .lineTrimOffset, to: &paintContainer)
        try nilEncoder.encode(lineWidth, forKey: .lineWidth, to: &paintContainer)
        try nilEncoder.encode(lineWidthTransition, forKey: .lineWidthTransition, to: &paintContainer)

        var layoutContainer = container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)
        try nilEncoder.encode(visibility, forKey: .visibility, to: &layoutContainer)
        try nilEncoder.encode(lineCap, forKey: .lineCap, to: &layoutContainer)
        try nilEncoder.encode(lineJoin, forKey: .lineJoin, to: &layoutContainer)
        try nilEncoder.encode(lineMiterLimit, forKey: .lineMiterLimit, to: &layoutContainer)
        try nilEncoder.encode(lineRoundLimit, forKey: .lineRoundLimit, to: &layoutContainer)
        try nilEncoder.encode(lineSortKey, forKey: .lineSortKey, to: &layoutContainer)
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
            lineBlur = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .lineBlur)
            lineBlurTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .lineBlurTransition)
            lineColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .lineColor)
            lineColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .lineColorTransition)
            lineDasharray = try paintContainer.decodeIfPresent(Value<[Double]>.self, forKey: .lineDasharray)
            lineDasharrayTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .lineDasharrayTransition)
            lineGapWidth = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .lineGapWidth)
            lineGapWidthTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .lineGapWidthTransition)
            lineGradient = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .lineGradient)
            lineOffset = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .lineOffset)
            lineOffsetTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .lineOffsetTransition)
            lineOpacity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .lineOpacity)
            lineOpacityTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .lineOpacityTransition)
            linePattern = try paintContainer.decodeIfPresent(Value<ResolvedImage>.self, forKey: .linePattern)
            linePatternTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .linePatternTransition)
            lineTranslate = try paintContainer.decodeIfPresent(Value<[Double]>.self, forKey: .lineTranslate)
            lineTranslateTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .lineTranslateTransition)
            lineTranslateAnchor = try paintContainer.decodeIfPresent(Value<LineTranslateAnchor>.self, forKey: .lineTranslateAnchor)
            lineTrimOffset = try paintContainer.decodeIfPresent(Value<[Double]>.self, forKey: .lineTrimOffset)
            lineWidth = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .lineWidth)
            lineWidthTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .lineWidthTransition)
        }

        if let layoutContainer = try? container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout) {
            visibility = try layoutContainer.decodeIfPresent(Value<Visibility>.self, forKey: .visibility)
            lineCap = try layoutContainer.decodeIfPresent(Value<LineCap>.self, forKey: .lineCap)
            lineJoin = try layoutContainer.decodeIfPresent(Value<LineJoin>.self, forKey: .lineJoin)
            lineMiterLimit = try layoutContainer.decodeIfPresent(Value<Double>.self, forKey: .lineMiterLimit)
            lineRoundLimit = try layoutContainer.decodeIfPresent(Value<Double>.self, forKey: .lineRoundLimit)
            lineSortKey = try layoutContainer.decodeIfPresent(Value<Double>.self, forKey: .lineSortKey)
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
        case lineCap = "line-cap"
        case lineJoin = "line-join"
        case lineMiterLimit = "line-miter-limit"
        case lineRoundLimit = "line-round-limit"
        case lineSortKey = "line-sort-key"
        case visibility = "visibility"
    }

    enum PaintCodingKeys: String, CodingKey {
        case lineBlur = "line-blur"
        case lineBlurTransition = "line-blur-transition"
        case lineColor = "line-color"
        case lineColorTransition = "line-color-transition"
        case lineDasharray = "line-dasharray"
        case lineDasharrayTransition = "line-dasharray-transition"
        case lineGapWidth = "line-gap-width"
        case lineGapWidthTransition = "line-gap-width-transition"
        case lineGradient = "line-gradient"
        case lineOffset = "line-offset"
        case lineOffsetTransition = "line-offset-transition"
        case lineOpacity = "line-opacity"
        case lineOpacityTransition = "line-opacity-transition"
        case linePattern = "line-pattern"
        case linePatternTransition = "line-pattern-transition"
        case lineTranslate = "line-translate"
        case lineTranslateTransition = "line-translate-transition"
        case lineTranslateAnchor = "line-translate-anchor"
        case lineTrimOffset = "line-trim-offset"
        case lineWidth = "line-width"
        case lineWidthTransition = "line-width-transition"
    }
}

// End of generated file.
