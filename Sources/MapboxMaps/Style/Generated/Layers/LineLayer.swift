// This file is generated.
import UIKit

/// A stroked line.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#layers-line)
public struct LineLayer: Layer, Equatable {

    // MARK: - Conformance to `Layer` protocol
    /// Unique layer name
    public var id: String

    /// Rendering type of this layer.
    public let type: LayerType

    /// An expression specifying conditions on source features.
    /// Only features that match the filter are displayed.
    public var filter: Exp?

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

    /// The display of line endings.
    /// Default value: "butt".
    public var lineCap: Value<LineCap>?

    /// Defines the slope of an elevated line. A value of 0 creates a horizontal line. A value of 1 creates a vertical line. Other values are currently not supported. If undefined, the line follows the terrain slope. This is an experimental property with some known issues:
    ///  - Vertical lines don't support line caps
    ///  - `line-join: round` is not supported with this property
    @_documentation(visibility: public)
    @_spi(Experimental) public var lineCrossSlope: Value<Double>?

    /// Selects the base of line-elevation. Some modes might require precomputed elevation data in the tileset.
    /// Default value: "none".
    @_documentation(visibility: public)
    @_spi(Experimental) public var lineElevationReference: Value<LineElevationReference>?

    /// The display of lines when joining.
    /// Default value: "miter".
    public var lineJoin: Value<LineJoin>?

    /// Used to automatically convert miter joins to bevel joins for sharp angles.
    /// Default value: 2.
    public var lineMiterLimit: Value<Double>?

    /// Used to automatically convert round joins to miter joins for shallow angles.
    /// Default value: 1.05.
    public var lineRoundLimit: Value<Double>?

    /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
    public var lineSortKey: Value<Double>?

    /// Selects the unit of line-width. The same unit is automatically used for line-blur and line-offset. Note: This is an experimental property and might be removed in a future release.
    /// Default value: "pixels".
    @_documentation(visibility: public)
    @_spi(Experimental) public var lineWidthUnit: Value<LineWidthUnit>?

    /// Vertical offset from ground, in meters. Defaults to 0. This is an experimental property with some known issues:
    ///  - Not supported for globe projection at the moment
    ///  - Elevated line discontinuity is possible on tile borders with terrain enabled
    ///  - Rendering artifacts can happen near line joins and line caps depending on the line styling
    ///  - Rendering artifacts relating to `line-opacity` and `line-blur`
    ///  - Elevated line visibility is determined by layer order
    ///  - Z-fighting issues can happen with intersecting elevated lines
    ///  - Elevated lines don't cast shadows
    /// Default value: 0.
    @_documentation(visibility: public)
    @_spi(Experimental) public var lineZOffset: Value<Double>?

    /// Blur applied to the line, in pixels.
    /// Default value: 0. Minimum value: 0. The unit of lineBlur is in pixels.
    public var lineBlur: Value<Double>?

    /// Transition options for `lineBlur`.
    public var lineBlurTransition: StyleTransition?

    /// The color of the line border. If line-border-width is greater than zero and the alpha value of this color is 0 (default), the color for the border will be selected automatically based on the line color.
    /// Default value: "rgba(0, 0, 0, 0)".
    public var lineBorderColor: Value<StyleColor>?

    /// Transition options for `lineBorderColor`.
    public var lineBorderColorTransition: StyleTransition?
    /// This property defines whether to use colorTheme defined color or not.
    /// By default it will use color defined by the root theme in the style.
    /// NOTE: - Expressions set to this property currently don't work.
    @_spi(Experimental) public var lineBorderColorUseTheme: Value<ColorUseTheme>?

    /// The width of the line border. A value of zero means no border.
    /// Default value: 0. Minimum value: 0.
    public var lineBorderWidth: Value<Double>?

    /// Transition options for `lineBorderWidth`.
    public var lineBorderWidthTransition: StyleTransition?

    /// The color with which the line will be drawn.
    /// Default value: "#000000".
    public var lineColor: Value<StyleColor>?

    /// Transition options for `lineColor`.
    public var lineColorTransition: StyleTransition?
    /// This property defines whether to use colorTheme defined color or not.
    /// By default it will use color defined by the root theme in the style.
    /// NOTE: - Expressions set to this property currently don't work.
    @_spi(Experimental) public var lineColorUseTheme: Value<ColorUseTheme>?

    /// Specifies the lengths of the alternating dashes and gaps that form the dash pattern. The lengths are later scaled by the line width. To convert a dash length to pixels, multiply the length by the current line width. Note that GeoJSON sources with `lineMetrics: true` specified won't render dashed lines to the expected scale. Also note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    /// Minimum value: 0. The unit of lineDasharray is in line widths.
    public var lineDasharray: Value<[Double]>?

    /// Decrease line layer opacity based on occlusion from 3D objects. Value 0 disables occlusion, value 1 means fully occluded.
    /// Default value: 1. Value range: [0, 1]
    public var lineDepthOcclusionFactor: Value<Double>?

    /// Transition options for `lineDepthOcclusionFactor`.
    public var lineDepthOcclusionFactorTransition: StyleTransition?

    /// Controls the intensity of light emitted on the source features.
    /// Default value: 0. Minimum value: 0. The unit of lineEmissiveStrength is in intensity.
    public var lineEmissiveStrength: Value<Double>?

    /// Transition options for `lineEmissiveStrength`.
    public var lineEmissiveStrengthTransition: StyleTransition?

    /// Draws a line casing outside of a line's actual path. Value indicates the width of the inner gap.
    /// Default value: 0. Minimum value: 0. The unit of lineGapWidth is in pixels.
    public var lineGapWidth: Value<Double>?

    /// Transition options for `lineGapWidth`.
    public var lineGapWidthTransition: StyleTransition?

    /// A gradient used to color a line feature at various distances along its length. Defined using a `step` or `interpolate` expression which outputs a color for each corresponding `line-progress` input value. `line-progress` is a percentage of the line feature's total length as measured on the webmercator projected coordinate plane (a `number` between `0` and `1`). Can only be used with GeoJSON sources that specify `"lineMetrics": true`.
    public var lineGradient: Value<StyleColor>?
    /// This property defines whether to use colorTheme defined color or not.
    /// By default it will use color defined by the root theme in the style.
    /// NOTE: - Expressions set to this property currently don't work.
    @_spi(Experimental) public var lineGradientUseTheme: Value<ColorUseTheme>?

    /// Opacity multiplier (multiplies line-opacity value) of the line part that is occluded by 3D objects. Value 0 hides occluded part, value 1 means the same opacity as non-occluded part. The property is not supported when `line-opacity` has data-driven styling.
    /// Default value: 0. Value range: [0, 1]
    public var lineOcclusionOpacity: Value<Double>?

    /// Transition options for `lineOcclusionOpacity`.
    public var lineOcclusionOpacityTransition: StyleTransition?

    /// The line's offset. For linear features, a positive value offsets the line to the right, relative to the direction of the line, and a negative value to the left. For polygon features, a positive value results in an inset, and a negative value results in an outset.
    /// Default value: 0. The unit of lineOffset is in pixels.
    public var lineOffset: Value<Double>?

    /// Transition options for `lineOffset`.
    public var lineOffsetTransition: StyleTransition?

    /// The opacity at which the line will be drawn.
    /// Default value: 1. Value range: [0, 1]
    public var lineOpacity: Value<Double>?

    /// Transition options for `lineOpacity`.
    public var lineOpacityTransition: StyleTransition?

    /// Name of image in sprite to use for drawing image lines. For seamless patterns, image width must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    public var linePattern: Value<ResolvedImage>?

    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
    /// Default value: [0,0]. The unit of lineTranslate is in pixels.
    public var lineTranslate: Value<[Double]>?

    /// Transition options for `lineTranslate`.
    public var lineTranslateTransition: StyleTransition?

    /// Controls the frame of reference for `line-translate`.
    /// Default value: "map".
    public var lineTranslateAnchor: Value<LineTranslateAnchor>?

    /// The color to be used for rendering the trimmed line section that is defined by the `line-trim-offset` property.
    /// Default value: "transparent".
    @_documentation(visibility: public)
    @_spi(Experimental) public var lineTrimColor: Value<StyleColor>?

    /// Transition options for `lineTrimColor`.
    @_documentation(visibility: public)
    @_spi(Experimental) public var lineTrimColorTransition: StyleTransition?
    /// This property defines whether to use colorTheme defined color or not.
    /// By default it will use color defined by the root theme in the style.
    /// NOTE: - Expressions set to this property currently don't work.
    @_spi(Experimental) public var lineTrimColorUseTheme: Value<ColorUseTheme>?

    /// The fade range for the trim-start and trim-end points is defined by the `line-trim-offset` property. The first element of the array represents the fade range from the trim-start point toward the end of the line, while the second element defines the fade range from the trim-end point toward the beginning of the line. The fade result is achieved by interpolating between `line-trim-color` and the color specified by the `line-color` or the `line-gradient` property.
    /// Default value: [0,0]. Minimum value: [0,0]. Maximum value: [1,1].
    @_documentation(visibility: public)
    @_spi(Experimental) public var lineTrimFadeRange: Value<[Double]>?

    /// The line part between [trim-start, trim-end] will be painted using `line-trim-color,` which is transparent by default to produce a route vanishing effect. The line trim-off offset is based on the whole line range [0.0, 1.0].
    /// Default value: [0,0]. Minimum value: [0,0]. Maximum value: [1,1].
    public var lineTrimOffset: Value<[Double]>?

    /// Stroke thickness.
    /// Default value: 1. Minimum value: 0. The unit of lineWidth is in pixels.
    public var lineWidth: Value<Double>?

    /// Transition options for `lineWidth`.
    public var lineWidthTransition: StyleTransition?

    public init(id: String, source: String) {
        self.source = source
        self.id = id
        self.type = LayerType.line
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
        try paintContainer.encodeIfPresent(lineBlur, forKey: .lineBlur)
        try paintContainer.encodeIfPresent(lineBlurTransition, forKey: .lineBlurTransition)
        try paintContainer.encodeIfPresent(lineBorderColor, forKey: .lineBorderColor)
        try paintContainer.encodeIfPresent(lineBorderColorTransition, forKey: .lineBorderColorTransition)
        try paintContainer.encodeIfPresent(lineBorderColorUseTheme, forKey: .lineBorderColorUseTheme)
        try paintContainer.encodeIfPresent(lineBorderWidth, forKey: .lineBorderWidth)
        try paintContainer.encodeIfPresent(lineBorderWidthTransition, forKey: .lineBorderWidthTransition)
        try paintContainer.encodeIfPresent(lineColor, forKey: .lineColor)
        try paintContainer.encodeIfPresent(lineColorTransition, forKey: .lineColorTransition)
        try paintContainer.encodeIfPresent(lineColorUseTheme, forKey: .lineColorUseTheme)
        try paintContainer.encodeIfPresent(lineDasharray, forKey: .lineDasharray)
        try paintContainer.encodeIfPresent(lineDepthOcclusionFactor, forKey: .lineDepthOcclusionFactor)
        try paintContainer.encodeIfPresent(lineDepthOcclusionFactorTransition, forKey: .lineDepthOcclusionFactorTransition)
        try paintContainer.encodeIfPresent(lineEmissiveStrength, forKey: .lineEmissiveStrength)
        try paintContainer.encodeIfPresent(lineEmissiveStrengthTransition, forKey: .lineEmissiveStrengthTransition)
        try paintContainer.encodeIfPresent(lineGapWidth, forKey: .lineGapWidth)
        try paintContainer.encodeIfPresent(lineGapWidthTransition, forKey: .lineGapWidthTransition)
        try paintContainer.encodeIfPresent(lineGradient, forKey: .lineGradient)
        try paintContainer.encodeIfPresent(lineGradientUseTheme, forKey: .lineGradientUseTheme)
        try paintContainer.encodeIfPresent(lineOcclusionOpacity, forKey: .lineOcclusionOpacity)
        try paintContainer.encodeIfPresent(lineOcclusionOpacityTransition, forKey: .lineOcclusionOpacityTransition)
        try paintContainer.encodeIfPresent(lineOffset, forKey: .lineOffset)
        try paintContainer.encodeIfPresent(lineOffsetTransition, forKey: .lineOffsetTransition)
        try paintContainer.encodeIfPresent(lineOpacity, forKey: .lineOpacity)
        try paintContainer.encodeIfPresent(lineOpacityTransition, forKey: .lineOpacityTransition)
        try paintContainer.encodeIfPresent(linePattern, forKey: .linePattern)
        try paintContainer.encodeIfPresent(lineTranslate, forKey: .lineTranslate)
        try paintContainer.encodeIfPresent(lineTranslateTransition, forKey: .lineTranslateTransition)
        try paintContainer.encodeIfPresent(lineTranslateAnchor, forKey: .lineTranslateAnchor)
        try paintContainer.encodeIfPresent(lineTrimColor, forKey: .lineTrimColor)
        try paintContainer.encodeIfPresent(lineTrimColorTransition, forKey: .lineTrimColorTransition)
        try paintContainer.encodeIfPresent(lineTrimColorUseTheme, forKey: .lineTrimColorUseTheme)
        try paintContainer.encodeIfPresent(lineTrimFadeRange, forKey: .lineTrimFadeRange)
        try paintContainer.encodeIfPresent(lineTrimOffset, forKey: .lineTrimOffset)
        try paintContainer.encodeIfPresent(lineWidth, forKey: .lineWidth)
        try paintContainer.encodeIfPresent(lineWidthTransition, forKey: .lineWidthTransition)

        var layoutContainer = container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)
        try layoutContainer.encode(visibility, forKey: .visibility)
        try layoutContainer.encodeIfPresent(lineCap, forKey: .lineCap)
        try layoutContainer.encodeIfPresent(lineCrossSlope, forKey: .lineCrossSlope)
        try layoutContainer.encodeIfPresent(lineElevationReference, forKey: .lineElevationReference)
        try layoutContainer.encodeIfPresent(lineJoin, forKey: .lineJoin)
        try layoutContainer.encodeIfPresent(lineMiterLimit, forKey: .lineMiterLimit)
        try layoutContainer.encodeIfPresent(lineRoundLimit, forKey: .lineRoundLimit)
        try layoutContainer.encodeIfPresent(lineSortKey, forKey: .lineSortKey)
        try layoutContainer.encodeIfPresent(lineWidthUnit, forKey: .lineWidthUnit)
        try layoutContainer.encodeIfPresent(lineZOffset, forKey: .lineZOffset)
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
            lineBlur = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .lineBlur)
            lineBlurTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .lineBlurTransition)
            lineBorderColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .lineBorderColor)
            lineBorderColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .lineBorderColorTransition)
            lineBorderColorUseTheme = try paintContainer.decodeIfPresent(Value<ColorUseTheme>.self, forKey: .lineBorderColorUseTheme)
            lineBorderWidth = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .lineBorderWidth)
            lineBorderWidthTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .lineBorderWidthTransition)
            lineColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .lineColor)
            lineColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .lineColorTransition)
            lineColorUseTheme = try paintContainer.decodeIfPresent(Value<ColorUseTheme>.self, forKey: .lineColorUseTheme)
            lineDasharray = try paintContainer.decodeIfPresent(Value<[Double]>.self, forKey: .lineDasharray)
            lineDepthOcclusionFactor = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .lineDepthOcclusionFactor)
            lineDepthOcclusionFactorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .lineDepthOcclusionFactorTransition)
            lineEmissiveStrength = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .lineEmissiveStrength)
            lineEmissiveStrengthTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .lineEmissiveStrengthTransition)
            lineGapWidth = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .lineGapWidth)
            lineGapWidthTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .lineGapWidthTransition)
            lineGradient = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .lineGradient)
            lineGradientUseTheme = try paintContainer.decodeIfPresent(Value<ColorUseTheme>.self, forKey: .lineGradientUseTheme)
            lineOcclusionOpacity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .lineOcclusionOpacity)
            lineOcclusionOpacityTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .lineOcclusionOpacityTransition)
            lineOffset = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .lineOffset)
            lineOffsetTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .lineOffsetTransition)
            lineOpacity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .lineOpacity)
            lineOpacityTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .lineOpacityTransition)
            linePattern = try paintContainer.decodeIfPresent(Value<ResolvedImage>.self, forKey: .linePattern)
            lineTranslate = try paintContainer.decodeIfPresent(Value<[Double]>.self, forKey: .lineTranslate)
            lineTranslateTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .lineTranslateTransition)
            lineTranslateAnchor = try paintContainer.decodeIfPresent(Value<LineTranslateAnchor>.self, forKey: .lineTranslateAnchor)
            lineTrimColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .lineTrimColor)
            lineTrimColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .lineTrimColorTransition)
            lineTrimColorUseTheme = try paintContainer.decodeIfPresent(Value<ColorUseTheme>.self, forKey: .lineTrimColorUseTheme)
            lineTrimFadeRange = try paintContainer.decodeIfPresent(Value<[Double]>.self, forKey: .lineTrimFadeRange)
            lineTrimOffset = try paintContainer.decodeIfPresent(Value<[Double]>.self, forKey: .lineTrimOffset)
            lineWidth = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .lineWidth)
            lineWidthTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .lineWidthTransition)
        }

        var visibilityEncoded: Value<Visibility>?
        if let layoutContainer = try? container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout) {
            visibilityEncoded = try layoutContainer.decodeIfPresent(Value<Visibility>.self, forKey: .visibility)
            lineCap = try layoutContainer.decodeIfPresent(Value<LineCap>.self, forKey: .lineCap)
            lineCrossSlope = try layoutContainer.decodeIfPresent(Value<Double>.self, forKey: .lineCrossSlope)
            lineElevationReference = try layoutContainer.decodeIfPresent(Value<LineElevationReference>.self, forKey: .lineElevationReference)
            lineJoin = try layoutContainer.decodeIfPresent(Value<LineJoin>.self, forKey: .lineJoin)
            lineMiterLimit = try layoutContainer.decodeIfPresent(Value<Double>.self, forKey: .lineMiterLimit)
            lineRoundLimit = try layoutContainer.decodeIfPresent(Value<Double>.self, forKey: .lineRoundLimit)
            lineSortKey = try layoutContainer.decodeIfPresent(Value<Double>.self, forKey: .lineSortKey)
            lineWidthUnit = try layoutContainer.decodeIfPresent(Value<LineWidthUnit>.self, forKey: .lineWidthUnit)
            lineZOffset = try layoutContainer.decodeIfPresent(Value<Double>.self, forKey: .lineZOffset)
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
        case lineCap = "line-cap"
        case lineCrossSlope = "line-cross-slope"
        case lineElevationReference = "line-elevation-reference"
        case lineJoin = "line-join"
        case lineMiterLimit = "line-miter-limit"
        case lineRoundLimit = "line-round-limit"
        case lineSortKey = "line-sort-key"
        case lineWidthUnit = "line-width-unit"
        case lineZOffset = "line-z-offset"
        case visibility = "visibility"
    }

    enum PaintCodingKeys: String, CodingKey {
        case lineBlur = "line-blur"
        case lineBlurTransition = "line-blur-transition"
        case lineBorderColor = "line-border-color"
        case lineBorderColorTransition = "line-border-color-transition"
        case lineBorderColorUseTheme = "line-border-color-use-theme"
        case lineBorderWidth = "line-border-width"
        case lineBorderWidthTransition = "line-border-width-transition"
        case lineColor = "line-color"
        case lineColorTransition = "line-color-transition"
        case lineColorUseTheme = "line-color-use-theme"
        case lineDasharray = "line-dasharray"
        case lineDepthOcclusionFactor = "line-depth-occlusion-factor"
        case lineDepthOcclusionFactorTransition = "line-depth-occlusion-factor-transition"
        case lineEmissiveStrength = "line-emissive-strength"
        case lineEmissiveStrengthTransition = "line-emissive-strength-transition"
        case lineGapWidth = "line-gap-width"
        case lineGapWidthTransition = "line-gap-width-transition"
        case lineGradient = "line-gradient"
        case lineGradientUseTheme = "line-gradient-use-theme"
        case lineOcclusionOpacity = "line-occlusion-opacity"
        case lineOcclusionOpacityTransition = "line-occlusion-opacity-transition"
        case lineOffset = "line-offset"
        case lineOffsetTransition = "line-offset-transition"
        case lineOpacity = "line-opacity"
        case lineOpacityTransition = "line-opacity-transition"
        case linePattern = "line-pattern"
        case lineTranslate = "line-translate"
        case lineTranslateTransition = "line-translate-transition"
        case lineTranslateAnchor = "line-translate-anchor"
        case lineTrimColor = "line-trim-color"
        case lineTrimColorTransition = "line-trim-color-transition"
        case lineTrimColorUseTheme = "line-trim-color-use-theme"
        case lineTrimFadeRange = "line-trim-fade-range"
        case lineTrimOffset = "line-trim-offset"
        case lineWidth = "line-width"
        case lineWidthTransition = "line-width-transition"
    }
}

extension LineLayer {
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

    /// The display of line endings.
    /// Default value: "butt".
    public func lineCap(_ constant: LineCap) -> Self {
        with(self, setter(\.lineCap, .constant(constant)))
    }

    /// The display of line endings.
    /// Default value: "butt".
    public func lineCap(_ expression: Exp) -> Self {
        with(self, setter(\.lineCap, .expression(expression)))
    }

    /// Defines the slope of an elevated line. A value of 0 creates a horizontal line. A value of 1 creates a vertical line. Other values are currently not supported. If undefined, the line follows the terrain slope. This is an experimental property with some known issues:
    ///  - Vertical lines don't support line caps
    ///  - `line-join: round` is not supported with this property
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func lineCrossSlope(_ constant: Double) -> Self {
        with(self, setter(\.lineCrossSlope, .constant(constant)))
    }

    /// Defines the slope of an elevated line. A value of 0 creates a horizontal line. A value of 1 creates a vertical line. Other values are currently not supported. If undefined, the line follows the terrain slope. This is an experimental property with some known issues:
    ///  - Vertical lines don't support line caps
    ///  - `line-join: round` is not supported with this property
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func lineCrossSlope(_ expression: Exp) -> Self {
        with(self, setter(\.lineCrossSlope, .expression(expression)))
    }

    /// Selects the base of line-elevation. Some modes might require precomputed elevation data in the tileset.
    /// Default value: "none".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func lineElevationReference(_ constant: LineElevationReference) -> Self {
        with(self, setter(\.lineElevationReference, .constant(constant)))
    }

    /// Selects the base of line-elevation. Some modes might require precomputed elevation data in the tileset.
    /// Default value: "none".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func lineElevationReference(_ expression: Exp) -> Self {
        with(self, setter(\.lineElevationReference, .expression(expression)))
    }

    /// The display of lines when joining.
    /// Default value: "miter".
    public func lineJoin(_ constant: LineJoin) -> Self {
        with(self, setter(\.lineJoin, .constant(constant)))
    }

    /// The display of lines when joining.
    /// Default value: "miter".
    public func lineJoin(_ expression: Exp) -> Self {
        with(self, setter(\.lineJoin, .expression(expression)))
    }

    /// Used to automatically convert miter joins to bevel joins for sharp angles.
    /// Default value: 2.
    public func lineMiterLimit(_ constant: Double) -> Self {
        with(self, setter(\.lineMiterLimit, .constant(constant)))
    }

    /// Used to automatically convert miter joins to bevel joins for sharp angles.
    /// Default value: 2.
    public func lineMiterLimit(_ expression: Exp) -> Self {
        with(self, setter(\.lineMiterLimit, .expression(expression)))
    }

    /// Used to automatically convert round joins to miter joins for shallow angles.
    /// Default value: 1.05.
    public func lineRoundLimit(_ constant: Double) -> Self {
        with(self, setter(\.lineRoundLimit, .constant(constant)))
    }

    /// Used to automatically convert round joins to miter joins for shallow angles.
    /// Default value: 1.05.
    public func lineRoundLimit(_ expression: Exp) -> Self {
        with(self, setter(\.lineRoundLimit, .expression(expression)))
    }

    /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
    public func lineSortKey(_ constant: Double) -> Self {
        with(self, setter(\.lineSortKey, .constant(constant)))
    }

    /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
    public func lineSortKey(_ expression: Exp) -> Self {
        with(self, setter(\.lineSortKey, .expression(expression)))
    }

    /// Selects the unit of line-width. The same unit is automatically used for line-blur and line-offset. Note: This is an experimental property and might be removed in a future release.
    /// Default value: "pixels".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func lineWidthUnit(_ constant: LineWidthUnit) -> Self {
        with(self, setter(\.lineWidthUnit, .constant(constant)))
    }

    /// Selects the unit of line-width. The same unit is automatically used for line-blur and line-offset. Note: This is an experimental property and might be removed in a future release.
    /// Default value: "pixels".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func lineWidthUnit(_ expression: Exp) -> Self {
        with(self, setter(\.lineWidthUnit, .expression(expression)))
    }

    /// Vertical offset from ground, in meters. Defaults to 0. This is an experimental property with some known issues:
    ///  - Not supported for globe projection at the moment
    ///  - Elevated line discontinuity is possible on tile borders with terrain enabled
    ///  - Rendering artifacts can happen near line joins and line caps depending on the line styling
    ///  - Rendering artifacts relating to `line-opacity` and `line-blur`
    ///  - Elevated line visibility is determined by layer order
    ///  - Z-fighting issues can happen with intersecting elevated lines
    ///  - Elevated lines don't cast shadows
    /// Default value: 0.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func lineZOffset(_ constant: Double) -> Self {
        with(self, setter(\.lineZOffset, .constant(constant)))
    }

    /// Vertical offset from ground, in meters. Defaults to 0. This is an experimental property with some known issues:
    ///  - Not supported for globe projection at the moment
    ///  - Elevated line discontinuity is possible on tile borders with terrain enabled
    ///  - Rendering artifacts can happen near line joins and line caps depending on the line styling
    ///  - Rendering artifacts relating to `line-opacity` and `line-blur`
    ///  - Elevated line visibility is determined by layer order
    ///  - Z-fighting issues can happen with intersecting elevated lines
    ///  - Elevated lines don't cast shadows
    /// Default value: 0.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func lineZOffset(_ expression: Exp) -> Self {
        with(self, setter(\.lineZOffset, .expression(expression)))
    }

    /// Blur applied to the line, in pixels.
    /// Default value: 0. Minimum value: 0. The unit of lineBlur is in pixels.
    public func lineBlur(_ constant: Double) -> Self {
        with(self, setter(\.lineBlur, .constant(constant)))
    }

    /// Transition property for `lineBlur`
    public func lineBlurTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.lineBlurTransition, transition))
    }

    /// Blur applied to the line, in pixels.
    /// Default value: 0. Minimum value: 0. The unit of lineBlur is in pixels.
    public func lineBlur(_ expression: Exp) -> Self {
        with(self, setter(\.lineBlur, .expression(expression)))
    }

    /// The color of the line border. If line-border-width is greater than zero and the alpha value of this color is 0 (default), the color for the border will be selected automatically based on the line color.
    /// Default value: "rgba(0, 0, 0, 0)".
    public func lineBorderColor(_ constant: StyleColor) -> Self {
        with(self, setter(\.lineBorderColor, .constant(constant)))
    }

    /// The color of the line border. If line-border-width is greater than zero and the alpha value of this color is 0 (default), the color for the border will be selected automatically based on the line color.
    /// Default value: "rgba(0, 0, 0, 0)".
    public func lineBorderColor(_ color: UIColor) -> Self {
        with(self, setter(\.lineBorderColor, .constant(StyleColor(color))))
    }

    /// Transition property for `lineBorderColor`
    public func lineBorderColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.lineBorderColorTransition, transition))
    }

    /// The color of the line border. If line-border-width is greater than zero and the alpha value of this color is 0 (default), the color for the border will be selected automatically based on the line color.
    /// Default value: "rgba(0, 0, 0, 0)".
    public func lineBorderColor(_ expression: Exp) -> Self {
        with(self, setter(\.lineBorderColor, .expression(expression)))
    }

    /// This property defines whether the `lineBorderColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func lineBorderColorUseTheme(_ useTheme: ColorUseTheme) -> Self {
        with(self, setter(\.lineBorderColorUseTheme, .constant(useTheme)))
    }

    /// This property defines whether the `lineBorderColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func lineBorderColorUseTheme(_ expression: Exp) -> Self {
        with(self, setter(\.lineBorderColorUseTheme, .expression(expression)))
    }

    /// The width of the line border. A value of zero means no border.
    /// Default value: 0. Minimum value: 0.
    public func lineBorderWidth(_ constant: Double) -> Self {
        with(self, setter(\.lineBorderWidth, .constant(constant)))
    }

    /// Transition property for `lineBorderWidth`
    public func lineBorderWidthTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.lineBorderWidthTransition, transition))
    }

    /// The width of the line border. A value of zero means no border.
    /// Default value: 0. Minimum value: 0.
    public func lineBorderWidth(_ expression: Exp) -> Self {
        with(self, setter(\.lineBorderWidth, .expression(expression)))
    }

    /// The color with which the line will be drawn.
    /// Default value: "#000000".
    public func lineColor(_ constant: StyleColor) -> Self {
        with(self, setter(\.lineColor, .constant(constant)))
    }

    /// The color with which the line will be drawn.
    /// Default value: "#000000".
    public func lineColor(_ color: UIColor) -> Self {
        with(self, setter(\.lineColor, .constant(StyleColor(color))))
    }

    /// Transition property for `lineColor`
    public func lineColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.lineColorTransition, transition))
    }

    /// The color with which the line will be drawn.
    /// Default value: "#000000".
    public func lineColor(_ expression: Exp) -> Self {
        with(self, setter(\.lineColor, .expression(expression)))
    }

    /// This property defines whether the `lineColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func lineColorUseTheme(_ useTheme: ColorUseTheme) -> Self {
        with(self, setter(\.lineColorUseTheme, .constant(useTheme)))
    }

    /// This property defines whether the `lineColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func lineColorUseTheme(_ expression: Exp) -> Self {
        with(self, setter(\.lineColorUseTheme, .expression(expression)))
    }

    /// Specifies the lengths of the alternating dashes and gaps that form the dash pattern. The lengths are later scaled by the line width. To convert a dash length to pixels, multiply the length by the current line width. Note that GeoJSON sources with `lineMetrics: true` specified won't render dashed lines to the expected scale. Also note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    /// Minimum value: 0. The unit of lineDasharray is in line widths.
    public func lineDashArray(_ constant: [Double]) -> Self {
        with(self, setter(\.lineDasharray, .constant(constant)))
    }

    /// Specifies the lengths of the alternating dashes and gaps that form the dash pattern. The lengths are later scaled by the line width. To convert a dash length to pixels, multiply the length by the current line width. Note that GeoJSON sources with `lineMetrics: true` specified won't render dashed lines to the expected scale. Also note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    /// Minimum value: 0. The unit of lineDasharray is in line widths.
    public func lineDashArray(_ expression: Exp) -> Self {
        with(self, setter(\.lineDasharray, .expression(expression)))
    }

    /// Decrease line layer opacity based on occlusion from 3D objects. Value 0 disables occlusion, value 1 means fully occluded.
    /// Default value: 1. Value range: [0, 1]
    public func lineDepthOcclusionFactor(_ constant: Double) -> Self {
        with(self, setter(\.lineDepthOcclusionFactor, .constant(constant)))
    }

    /// Transition property for `lineDepthOcclusionFactor`
    public func lineDepthOcclusionFactorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.lineDepthOcclusionFactorTransition, transition))
    }

    /// Decrease line layer opacity based on occlusion from 3D objects. Value 0 disables occlusion, value 1 means fully occluded.
    /// Default value: 1. Value range: [0, 1]
    public func lineDepthOcclusionFactor(_ expression: Exp) -> Self {
        with(self, setter(\.lineDepthOcclusionFactor, .expression(expression)))
    }

    /// Controls the intensity of light emitted on the source features.
    /// Default value: 0. Minimum value: 0. The unit of lineEmissiveStrength is in intensity.
    public func lineEmissiveStrength(_ constant: Double) -> Self {
        with(self, setter(\.lineEmissiveStrength, .constant(constant)))
    }

    /// Transition property for `lineEmissiveStrength`
    public func lineEmissiveStrengthTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.lineEmissiveStrengthTransition, transition))
    }

    /// Controls the intensity of light emitted on the source features.
    /// Default value: 0. Minimum value: 0. The unit of lineEmissiveStrength is in intensity.
    public func lineEmissiveStrength(_ expression: Exp) -> Self {
        with(self, setter(\.lineEmissiveStrength, .expression(expression)))
    }

    /// Draws a line casing outside of a line's actual path. Value indicates the width of the inner gap.
    /// Default value: 0. Minimum value: 0. The unit of lineGapWidth is in pixels.
    public func lineGapWidth(_ constant: Double) -> Self {
        with(self, setter(\.lineGapWidth, .constant(constant)))
    }

    /// Transition property for `lineGapWidth`
    public func lineGapWidthTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.lineGapWidthTransition, transition))
    }

    /// Draws a line casing outside of a line's actual path. Value indicates the width of the inner gap.
    /// Default value: 0. Minimum value: 0. The unit of lineGapWidth is in pixels.
    public func lineGapWidth(_ expression: Exp) -> Self {
        with(self, setter(\.lineGapWidth, .expression(expression)))
    }

    /// A gradient used to color a line feature at various distances along its length. Defined using a `step` or `interpolate` expression which outputs a color for each corresponding `line-progress` input value. `line-progress` is a percentage of the line feature's total length as measured on the webmercator projected coordinate plane (a `number` between `0` and `1`). Can only be used with GeoJSON sources that specify `"lineMetrics": true`.
    public func lineGradient(_ constant: StyleColor) -> Self {
        with(self, setter(\.lineGradient, .constant(constant)))
    }

    /// A gradient used to color a line feature at various distances along its length. Defined using a `step` or `interpolate` expression which outputs a color for each corresponding `line-progress` input value. `line-progress` is a percentage of the line feature's total length as measured on the webmercator projected coordinate plane (a `number` between `0` and `1`). Can only be used with GeoJSON sources that specify `"lineMetrics": true`.
    public func lineGradient(_ color: UIColor) -> Self {
        with(self, setter(\.lineGradient, .constant(StyleColor(color))))
    }

    /// A gradient used to color a line feature at various distances along its length. Defined using a `step` or `interpolate` expression which outputs a color for each corresponding `line-progress` input value. `line-progress` is a percentage of the line feature's total length as measured on the webmercator projected coordinate plane (a `number` between `0` and `1`). Can only be used with GeoJSON sources that specify `"lineMetrics": true`.
    public func lineGradient(_ expression: Exp) -> Self {
        with(self, setter(\.lineGradient, .expression(expression)))
    }

    /// This property defines whether the `lineGradient` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func lineGradientUseTheme(_ useTheme: ColorUseTheme) -> Self {
        with(self, setter(\.lineGradientUseTheme, .constant(useTheme)))
    }

    /// This property defines whether the `lineGradient` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func lineGradientUseTheme(_ expression: Exp) -> Self {
        with(self, setter(\.lineGradientUseTheme, .expression(expression)))
    }

    /// Opacity multiplier (multiplies line-opacity value) of the line part that is occluded by 3D objects. Value 0 hides occluded part, value 1 means the same opacity as non-occluded part. The property is not supported when `line-opacity` has data-driven styling.
    /// Default value: 0. Value range: [0, 1]
    public func lineOcclusionOpacity(_ constant: Double) -> Self {
        with(self, setter(\.lineOcclusionOpacity, .constant(constant)))
    }

    /// Transition property for `lineOcclusionOpacity`
    public func lineOcclusionOpacityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.lineOcclusionOpacityTransition, transition))
    }

    /// Opacity multiplier (multiplies line-opacity value) of the line part that is occluded by 3D objects. Value 0 hides occluded part, value 1 means the same opacity as non-occluded part. The property is not supported when `line-opacity` has data-driven styling.
    /// Default value: 0. Value range: [0, 1]
    public func lineOcclusionOpacity(_ expression: Exp) -> Self {
        with(self, setter(\.lineOcclusionOpacity, .expression(expression)))
    }

    /// The line's offset. For linear features, a positive value offsets the line to the right, relative to the direction of the line, and a negative value to the left. For polygon features, a positive value results in an inset, and a negative value results in an outset.
    /// Default value: 0. The unit of lineOffset is in pixels.
    public func lineOffset(_ constant: Double) -> Self {
        with(self, setter(\.lineOffset, .constant(constant)))
    }

    /// Transition property for `lineOffset`
    public func lineOffsetTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.lineOffsetTransition, transition))
    }

    /// The line's offset. For linear features, a positive value offsets the line to the right, relative to the direction of the line, and a negative value to the left. For polygon features, a positive value results in an inset, and a negative value results in an outset.
    /// Default value: 0. The unit of lineOffset is in pixels.
    public func lineOffset(_ expression: Exp) -> Self {
        with(self, setter(\.lineOffset, .expression(expression)))
    }

    /// The opacity at which the line will be drawn.
    /// Default value: 1. Value range: [0, 1]
    public func lineOpacity(_ constant: Double) -> Self {
        with(self, setter(\.lineOpacity, .constant(constant)))
    }

    /// Transition property for `lineOpacity`
    public func lineOpacityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.lineOpacityTransition, transition))
    }

    /// The opacity at which the line will be drawn.
    /// Default value: 1. Value range: [0, 1]
    public func lineOpacity(_ expression: Exp) -> Self {
        with(self, setter(\.lineOpacity, .expression(expression)))
    }

    /// Name of image in sprite to use for drawing image lines. For seamless patterns, image width must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    public func linePattern(_ constant: String) -> Self {
        with(self, setter(\.linePattern, .constant(.name(constant))))
    }

    /// Name of image in sprite to use for drawing image lines. For seamless patterns, image width must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    public func linePattern(_ expression: Exp) -> Self {
        with(self, setter(\.linePattern, .expression(expression)))
    }

    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
    /// Default value: [0,0]. The unit of lineTranslate is in pixels.
    public func lineTranslate(x: Double, y: Double) -> Self {
        with(self, setter(\.lineTranslate, .constant([x, y])))
    }

    /// Transition property for `lineTranslate`
    public func lineTranslateTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.lineTranslateTransition, transition))
    }

    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
    /// Default value: [0,0]. The unit of lineTranslate is in pixels.
    public func lineTranslate(_ expression: Exp) -> Self {
        with(self, setter(\.lineTranslate, .expression(expression)))
    }

    /// Controls the frame of reference for `line-translate`.
    /// Default value: "map".
    public func lineTranslateAnchor(_ constant: LineTranslateAnchor) -> Self {
        with(self, setter(\.lineTranslateAnchor, .constant(constant)))
    }

    /// Controls the frame of reference for `line-translate`.
    /// Default value: "map".
    public func lineTranslateAnchor(_ expression: Exp) -> Self {
        with(self, setter(\.lineTranslateAnchor, .expression(expression)))
    }

    /// The color to be used for rendering the trimmed line section that is defined by the `line-trim-offset` property.
    /// Default value: "transparent".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func lineTrimColor(_ constant: StyleColor) -> Self {
        with(self, setter(\.lineTrimColor, .constant(constant)))
    }

    /// The color to be used for rendering the trimmed line section that is defined by the `line-trim-offset` property.
    /// Default value: "transparent".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func lineTrimColor(_ color: UIColor) -> Self {
        with(self, setter(\.lineTrimColor, .constant(StyleColor(color))))
    }

    /// Transition property for `lineTrimColor`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func lineTrimColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.lineTrimColorTransition, transition))
    }

    /// The color to be used for rendering the trimmed line section that is defined by the `line-trim-offset` property.
    /// Default value: "transparent".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func lineTrimColor(_ expression: Exp) -> Self {
        with(self, setter(\.lineTrimColor, .expression(expression)))
    }

    /// This property defines whether the `lineTrimColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func lineTrimColorUseTheme(_ useTheme: ColorUseTheme) -> Self {
        with(self, setter(\.lineTrimColorUseTheme, .constant(useTheme)))
    }

    /// This property defines whether the `lineTrimColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func lineTrimColorUseTheme(_ expression: Exp) -> Self {
        with(self, setter(\.lineTrimColorUseTheme, .expression(expression)))
    }

    /// The fade range for the trim-start and trim-end points is defined by the `line-trim-offset` property. The first element of the array represents the fade range from the trim-start point toward the end of the line, while the second element defines the fade range from the trim-end point toward the beginning of the line. The fade result is achieved by interpolating between `line-trim-color` and the color specified by the `line-color` or the `line-gradient` property.
    /// Default value: [0,0]. Minimum value: [0,0]. Maximum value: [1,1].
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func lineTrimFadeRange(start: Double, end: Double) -> Self {
        with(self, setter(\.lineTrimFadeRange, .constant([start, end])))
    }

    /// The fade range for the trim-start and trim-end points is defined by the `line-trim-offset` property. The first element of the array represents the fade range from the trim-start point toward the end of the line, while the second element defines the fade range from the trim-end point toward the beginning of the line. The fade result is achieved by interpolating between `line-trim-color` and the color specified by the `line-color` or the `line-gradient` property.
    /// Default value: [0,0]. Minimum value: [0,0]. Maximum value: [1,1].
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func lineTrimFadeRange(_ expression: Exp) -> Self {
        with(self, setter(\.lineTrimFadeRange, .expression(expression)))
    }

    /// The line part between [trim-start, trim-end] will be painted using `line-trim-color,` which is transparent by default to produce a route vanishing effect. The line trim-off offset is based on the whole line range [0.0, 1.0].
    /// Default value: [0,0]. Minimum value: [0,0]. Maximum value: [1,1].
    public func lineTrimOffset(start: Double, end: Double) -> Self {
        with(self, setter(\.lineTrimOffset, .constant([start, end])))
    }

    /// The line part between [trim-start, trim-end] will be painted using `line-trim-color,` which is transparent by default to produce a route vanishing effect. The line trim-off offset is based on the whole line range [0.0, 1.0].
    /// Default value: [0,0]. Minimum value: [0,0]. Maximum value: [1,1].
    public func lineTrimOffset(_ expression: Exp) -> Self {
        with(self, setter(\.lineTrimOffset, .expression(expression)))
    }

    /// Stroke thickness.
    /// Default value: 1. Minimum value: 0. The unit of lineWidth is in pixels.
    public func lineWidth(_ constant: Double) -> Self {
        with(self, setter(\.lineWidth, .constant(constant)))
    }

    /// Transition property for `lineWidth`
    public func lineWidthTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.lineWidthTransition, transition))
    }

    /// Stroke thickness.
    /// Default value: 1. Minimum value: 0. The unit of lineWidth is in pixels.
    public func lineWidth(_ expression: Exp) -> Self {
        with(self, setter(\.lineWidth, .expression(expression)))
    }
}

extension LineLayer: MapStyleContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        node.mount(MountedLayer(layer: self))
    }
}

// End of generated file.
