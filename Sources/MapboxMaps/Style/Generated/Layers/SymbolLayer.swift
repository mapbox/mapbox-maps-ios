// This file is generated.
import Foundation

/// An icon or a text label.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#layers-symbol)
public struct SymbolLayer: Layer {

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

    /// If true, the icon will be visible even if it collides with other previously drawn symbols.
    public var iconAllowOverlap: Value<Bool>?

    /// Part of the icon placed closest to the anchor.
    public var iconAnchor: Value<IconAnchor>?

    /// If true, other symbols can be visible even if they collide with the icon.
    public var iconIgnorePlacement: Value<Bool>?

    /// Name of image in sprite to use for drawing an image background.
    public var iconImage: Value<ResolvedImage>?

    /// If true, the icon may be flipped to prevent it from being rendered upside-down.
    public var iconKeepUpright: Value<Bool>?

    /// Offset distance of icon from its anchor. Positive values indicate right and down, while negative values indicate left and up. Each component is multiplied by the value of `icon-size` to obtain the final offset in pixels. When combined with `icon-rotate` the offset will be as if the rotated direction was up.
    public var iconOffset: Value<[Double]>?

    /// If true, text will display without their corresponding icons when the icon collides with other symbols and the text does not.
    public var iconOptional: Value<Bool>?

    /// Size of the additional area around the icon bounding box used for detecting symbol collisions.
    public var iconPadding: Value<Double>?

    /// Orientation of icon when map is pitched.
    public var iconPitchAlignment: Value<IconPitchAlignment>?

    /// Rotates the icon clockwise.
    public var iconRotate: Value<Double>?

    /// In combination with `symbol-placement`, determines the rotation behavior of icons.
    public var iconRotationAlignment: Value<IconRotationAlignment>?

    /// Scales the original size of the icon by the provided factor. The new pixel size of the image will be the original pixel size multiplied by `icon-size`. 1 is the original size; 3 triples the size of the image.
    public var iconSize: Value<Double>?

    /// Scales the icon to fit around the associated text.
    public var iconTextFit: Value<IconTextFit>?

    /// Size of the additional area added to dimensions determined by `icon-text-fit`, in clockwise order: top, right, bottom, left.
    public var iconTextFitPadding: Value<[Double]>?

    /// If true, the symbols will not cross tile edges to avoid mutual collisions. Recommended in layers that don't have enough padding in the vector tile to prevent collisions, or if it is a point symbol layer placed after a line symbol layer. When using a client that supports global collision detection, like Mapbox GL JS version 0.42.0 or greater, enabling this property is not needed to prevent clipped labels at tile boundaries.
    public var symbolAvoidEdges: Value<Bool>?

    /// Label placement relative to its geometry.
    public var symbolPlacement: Value<SymbolPlacement>?

    /// Sorts features in ascending order based on this value. Features with lower sort keys are drawn and placed first.  When `icon-allow-overlap` or `text-allow-overlap` is `false`, features with a lower sort key will have priority during placement. When `icon-allow-overlap` or `text-allow-overlap` is set to `true`, features with a higher sort key will overlap over features with a lower sort key.
    public var symbolSortKey: Value<Double>?

    /// Distance between two symbol anchors.
    public var symbolSpacing: Value<Double>?

    /// Determines whether overlapping symbols in the same layer are rendered in the order that they appear in the data source or by their y-position relative to the viewport. To control the order and prioritization of symbols otherwise, use `symbol-sort-key`.
    public var symbolZOrder: Value<SymbolZOrder>?

    /// If true, the text will be visible even if it collides with other previously drawn symbols.
    public var textAllowOverlap: Value<Bool>?

    /// Part of the text placed closest to the anchor.
    public var textAnchor: Value<TextAnchor>?

    /// Value to use for a text label. If a plain `string` is provided, it will be treated as a `formatted` with default/inherited formatting options. SDF images are not supported in formatted text and will be ignored.
    public var textField: Value<String>?

    /// Font stack to use for displaying text.
    public var textFont: Value<[String]>?

    /// If true, other symbols can be visible even if they collide with the text.
    public var textIgnorePlacement: Value<Bool>?

    /// Text justification options.
    public var textJustify: Value<TextJustify>?

    /// If true, the text may be flipped vertically to prevent it from being rendered upside-down.
    public var textKeepUpright: Value<Bool>?

    /// Text tracking amount.
    public var textLetterSpacing: Value<Double>?

    /// Text leading value for multi-line text.
    public var textLineHeight: Value<Double>?

    /// Maximum angle change between adjacent characters.
    public var textMaxAngle: Value<Double>?

    /// The maximum line width for text wrapping.
    public var textMaxWidth: Value<Double>?

    /// Offset distance of text from its anchor. Positive values indicate right and down, while negative values indicate left and up. If used with text-variable-anchor, input values will be taken as absolute values. Offsets along the x- and y-axis will be applied automatically based on the anchor position.
    public var textOffset: Value<[Double]>?

    /// If true, icons will display without their corresponding text when the text collides with other symbols and the icon does not.
    public var textOptional: Value<Bool>?

    /// Size of the additional area around the text bounding box used for detecting symbol collisions.
    public var textPadding: Value<Double>?

    /// Orientation of text when map is pitched.
    public var textPitchAlignment: Value<TextPitchAlignment>?

    /// Radial offset of text, in the direction of the symbol's anchor. Useful in combination with `text-variable-anchor`, which defaults to using the two-dimensional `text-offset` if present.
    public var textRadialOffset: Value<Double>?

    /// Rotates the text clockwise.
    public var textRotate: Value<Double>?

    /// In combination with `symbol-placement`, determines the rotation behavior of the individual glyphs forming the text.
    public var textRotationAlignment: Value<TextRotationAlignment>?

    /// Font size.
    public var textSize: Value<Double>?

    /// Specifies how to capitalize text, similar to the CSS `text-transform` property.
    public var textTransform: Value<TextTransform>?

    /// To increase the chance of placing high-priority labels on the map, you can provide an array of `text-anchor` locations: the renderer will attempt to place the label at each location, in order, before moving onto the next label. Use `text-justify: auto` to choose justification based on anchor position. To apply an offset, use the `text-radial-offset` or the two-dimensional `text-offset`.
    public var textVariableAnchor: Value<[TextAnchor]>?

    /// The property allows control over a symbol's orientation. Note that the property values act as a hint, so that a symbol whose language doesn’t support the provided orientation will be laid out in its natural orientation. Example: English point symbol will be rendered horizontally even if array value contains single 'vertical' enum value. For symbol with point placement, the order of elements in an array define priority order for the placement of an orientation variant. For symbol with line placement, the default text writing mode is either ['horizontal', 'vertical'] or ['vertical', 'horizontal'], the order doesn't affect the placement.
    public var textWritingMode: Value<[TextWritingMode]>?

    /// The color of the icon. This can only be used with [SDF icons](/help/troubleshooting/using-recolorable-images-in-mapbox-maps/).
    public var iconColor: Value<StyleColor>?

    /// Transition options for `iconColor`.
    public var iconColorTransition: StyleTransition?

    /// Fade out the halo towards the outside.
    public var iconHaloBlur: Value<Double>?

    /// Transition options for `iconHaloBlur`.
    public var iconHaloBlurTransition: StyleTransition?

    /// The color of the icon's halo. Icon halos can only be used with [SDF icons](/help/troubleshooting/using-recolorable-images-in-mapbox-maps/).
    public var iconHaloColor: Value<StyleColor>?

    /// Transition options for `iconHaloColor`.
    public var iconHaloColorTransition: StyleTransition?

    /// Distance of halo to the icon outline.
    public var iconHaloWidth: Value<Double>?

    /// Transition options for `iconHaloWidth`.
    public var iconHaloWidthTransition: StyleTransition?

    /// The opacity at which the icon will be drawn.
    public var iconOpacity: Value<Double>?

    /// Transition options for `iconOpacity`.
    public var iconOpacityTransition: StyleTransition?

    /// Distance that the icon's anchor is moved from its original placement. Positive values indicate right and down, while negative values indicate left and up.
    public var iconTranslate: Value<[Double]>?

    /// Transition options for `iconTranslate`.
    public var iconTranslateTransition: StyleTransition?

    /// Controls the frame of reference for `icon-translate`.
    public var iconTranslateAnchor: Value<IconTranslateAnchor>?

    /// The color with which the text will be drawn.
    public var textColor: Value<StyleColor>?

    /// Transition options for `textColor`.
    public var textColorTransition: StyleTransition?

    /// The halo's fadeout distance towards the outside.
    public var textHaloBlur: Value<Double>?

    /// Transition options for `textHaloBlur`.
    public var textHaloBlurTransition: StyleTransition?

    /// The color of the text's halo, which helps it stand out from backgrounds.
    public var textHaloColor: Value<StyleColor>?

    /// Transition options for `textHaloColor`.
    public var textHaloColorTransition: StyleTransition?

    /// Distance of halo to the font outline. Max text halo width is 1/4 of the font-size.
    public var textHaloWidth: Value<Double>?

    /// Transition options for `textHaloWidth`.
    public var textHaloWidthTransition: StyleTransition?

    /// The opacity at which the text will be drawn.
    public var textOpacity: Value<Double>?

    /// Transition options for `textOpacity`.
    public var textOpacityTransition: StyleTransition?

    /// Distance that the text's anchor is moved from its original placement. Positive values indicate right and down, while negative values indicate left and up.
    public var textTranslate: Value<[Double]>?

    /// Transition options for `textTranslate`.
    public var textTranslateTransition: StyleTransition?

    /// Controls the frame of reference for `text-translate`.
    public var textTranslateAnchor: Value<TextTranslateAnchor>?

    public init(id: String) {
        self.id = id
        self.type = LayerType.symbol
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
        try paintContainer.encodeIfPresent(iconColor, forKey: .iconColor)
        try paintContainer.encodeIfPresent(iconColorTransition, forKey: .iconColorTransition)
        try paintContainer.encodeIfPresent(iconHaloBlur, forKey: .iconHaloBlur)
        try paintContainer.encodeIfPresent(iconHaloBlurTransition, forKey: .iconHaloBlurTransition)
        try paintContainer.encodeIfPresent(iconHaloColor, forKey: .iconHaloColor)
        try paintContainer.encodeIfPresent(iconHaloColorTransition, forKey: .iconHaloColorTransition)
        try paintContainer.encodeIfPresent(iconHaloWidth, forKey: .iconHaloWidth)
        try paintContainer.encodeIfPresent(iconHaloWidthTransition, forKey: .iconHaloWidthTransition)
        try paintContainer.encodeIfPresent(iconOpacity, forKey: .iconOpacity)
        try paintContainer.encodeIfPresent(iconOpacityTransition, forKey: .iconOpacityTransition)
        try paintContainer.encodeIfPresent(iconTranslate, forKey: .iconTranslate)
        try paintContainer.encodeIfPresent(iconTranslateTransition, forKey: .iconTranslateTransition)
        try paintContainer.encodeIfPresent(iconTranslateAnchor, forKey: .iconTranslateAnchor)
        try paintContainer.encodeIfPresent(textColor, forKey: .textColor)
        try paintContainer.encodeIfPresent(textColorTransition, forKey: .textColorTransition)
        try paintContainer.encodeIfPresent(textHaloBlur, forKey: .textHaloBlur)
        try paintContainer.encodeIfPresent(textHaloBlurTransition, forKey: .textHaloBlurTransition)
        try paintContainer.encodeIfPresent(textHaloColor, forKey: .textHaloColor)
        try paintContainer.encodeIfPresent(textHaloColorTransition, forKey: .textHaloColorTransition)
        try paintContainer.encodeIfPresent(textHaloWidth, forKey: .textHaloWidth)
        try paintContainer.encodeIfPresent(textHaloWidthTransition, forKey: .textHaloWidthTransition)
        try paintContainer.encodeIfPresent(textOpacity, forKey: .textOpacity)
        try paintContainer.encodeIfPresent(textOpacityTransition, forKey: .textOpacityTransition)
        try paintContainer.encodeIfPresent(textTranslate, forKey: .textTranslate)
        try paintContainer.encodeIfPresent(textTranslateTransition, forKey: .textTranslateTransition)
        try paintContainer.encodeIfPresent(textTranslateAnchor, forKey: .textTranslateAnchor)

        var layoutContainer = container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)
        try layoutContainer.encodeIfPresent(visibility, forKey: .visibility)
        try layoutContainer.encodeIfPresent(iconAllowOverlap, forKey: .iconAllowOverlap)
        try layoutContainer.encodeIfPresent(iconAnchor, forKey: .iconAnchor)
        try layoutContainer.encodeIfPresent(iconIgnorePlacement, forKey: .iconIgnorePlacement)
        try layoutContainer.encodeIfPresent(iconImage, forKey: .iconImage)
        try layoutContainer.encodeIfPresent(iconKeepUpright, forKey: .iconKeepUpright)
        try layoutContainer.encodeIfPresent(iconOffset, forKey: .iconOffset)
        try layoutContainer.encodeIfPresent(iconOptional, forKey: .iconOptional)
        try layoutContainer.encodeIfPresent(iconPadding, forKey: .iconPadding)
        try layoutContainer.encodeIfPresent(iconPitchAlignment, forKey: .iconPitchAlignment)
        try layoutContainer.encodeIfPresent(iconRotate, forKey: .iconRotate)
        try layoutContainer.encodeIfPresent(iconRotationAlignment, forKey: .iconRotationAlignment)
        try layoutContainer.encodeIfPresent(iconSize, forKey: .iconSize)
        try layoutContainer.encodeIfPresent(iconTextFit, forKey: .iconTextFit)
        try layoutContainer.encodeIfPresent(iconTextFitPadding, forKey: .iconTextFitPadding)
        try layoutContainer.encodeIfPresent(symbolAvoidEdges, forKey: .symbolAvoidEdges)
        try layoutContainer.encodeIfPresent(symbolPlacement, forKey: .symbolPlacement)
        try layoutContainer.encodeIfPresent(symbolSortKey, forKey: .symbolSortKey)
        try layoutContainer.encodeIfPresent(symbolSpacing, forKey: .symbolSpacing)
        try layoutContainer.encodeIfPresent(symbolZOrder, forKey: .symbolZOrder)
        try layoutContainer.encodeIfPresent(textAllowOverlap, forKey: .textAllowOverlap)
        try layoutContainer.encodeIfPresent(textAnchor, forKey: .textAnchor)
        try layoutContainer.encodeIfPresent(textField, forKey: .textField)
        try layoutContainer.encodeIfPresent(textFont, forKey: .textFont)
        try layoutContainer.encodeIfPresent(textIgnorePlacement, forKey: .textIgnorePlacement)
        try layoutContainer.encodeIfPresent(textJustify, forKey: .textJustify)
        try layoutContainer.encodeIfPresent(textKeepUpright, forKey: .textKeepUpright)
        try layoutContainer.encodeIfPresent(textLetterSpacing, forKey: .textLetterSpacing)
        try layoutContainer.encodeIfPresent(textLineHeight, forKey: .textLineHeight)
        try layoutContainer.encodeIfPresent(textMaxAngle, forKey: .textMaxAngle)
        try layoutContainer.encodeIfPresent(textMaxWidth, forKey: .textMaxWidth)
        try layoutContainer.encodeIfPresent(textOffset, forKey: .textOffset)
        try layoutContainer.encodeIfPresent(textOptional, forKey: .textOptional)
        try layoutContainer.encodeIfPresent(textPadding, forKey: .textPadding)
        try layoutContainer.encodeIfPresent(textPitchAlignment, forKey: .textPitchAlignment)
        try layoutContainer.encodeIfPresent(textRadialOffset, forKey: .textRadialOffset)
        try layoutContainer.encodeIfPresent(textRotate, forKey: .textRotate)
        try layoutContainer.encodeIfPresent(textRotationAlignment, forKey: .textRotationAlignment)
        try layoutContainer.encodeIfPresent(textSize, forKey: .textSize)
        try layoutContainer.encodeIfPresent(textTransform, forKey: .textTransform)
        try layoutContainer.encodeIfPresent(textVariableAnchor, forKey: .textVariableAnchor)
        try layoutContainer.encodeIfPresent(textWritingMode, forKey: .textWritingMode)
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
            iconColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .iconColor)
            iconColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .iconColorTransition)
            iconHaloBlur = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .iconHaloBlur)
            iconHaloBlurTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .iconHaloBlurTransition)
            iconHaloColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .iconHaloColor)
            iconHaloColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .iconHaloColorTransition)
            iconHaloWidth = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .iconHaloWidth)
            iconHaloWidthTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .iconHaloWidthTransition)
            iconOpacity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .iconOpacity)
            iconOpacityTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .iconOpacityTransition)
            iconTranslate = try paintContainer.decodeIfPresent(Value<[Double]>.self, forKey: .iconTranslate)
            iconTranslateTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .iconTranslateTransition)
            iconTranslateAnchor = try paintContainer.decodeIfPresent(Value<IconTranslateAnchor>.self, forKey: .iconTranslateAnchor)
            textColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .textColor)
            textColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .textColorTransition)
            textHaloBlur = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .textHaloBlur)
            textHaloBlurTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .textHaloBlurTransition)
            textHaloColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .textHaloColor)
            textHaloColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .textHaloColorTransition)
            textHaloWidth = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .textHaloWidth)
            textHaloWidthTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .textHaloWidthTransition)
            textOpacity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .textOpacity)
            textOpacityTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .textOpacityTransition)
            textTranslate = try paintContainer.decodeIfPresent(Value<[Double]>.self, forKey: .textTranslate)
            textTranslateTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .textTranslateTransition)
            textTranslateAnchor = try paintContainer.decodeIfPresent(Value<TextTranslateAnchor>.self, forKey: .textTranslateAnchor)
        }

        if let layoutContainer = try? container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout) {
            visibility = try layoutContainer.decodeIfPresent(Value<Visibility>.self, forKey: .visibility)
            iconAllowOverlap = try layoutContainer.decodeIfPresent(Value<Bool>.self, forKey: .iconAllowOverlap)
            iconAnchor = try layoutContainer.decodeIfPresent(Value<IconAnchor>.self, forKey: .iconAnchor)
            iconIgnorePlacement = try layoutContainer.decodeIfPresent(Value<Bool>.self, forKey: .iconIgnorePlacement)
            iconImage = try layoutContainer.decodeIfPresent(Value<ResolvedImage>.self, forKey: .iconImage)
            iconKeepUpright = try layoutContainer.decodeIfPresent(Value<Bool>.self, forKey: .iconKeepUpright)
            iconOffset = try layoutContainer.decodeIfPresent(Value<[Double]>.self, forKey: .iconOffset)
            iconOptional = try layoutContainer.decodeIfPresent(Value<Bool>.self, forKey: .iconOptional)
            iconPadding = try layoutContainer.decodeIfPresent(Value<Double>.self, forKey: .iconPadding)
            iconPitchAlignment = try layoutContainer.decodeIfPresent(Value<IconPitchAlignment>.self, forKey: .iconPitchAlignment)
            iconRotate = try layoutContainer.decodeIfPresent(Value<Double>.self, forKey: .iconRotate)
            iconRotationAlignment = try layoutContainer.decodeIfPresent(Value<IconRotationAlignment>.self, forKey: .iconRotationAlignment)
            iconSize = try layoutContainer.decodeIfPresent(Value<Double>.self, forKey: .iconSize)
            iconTextFit = try layoutContainer.decodeIfPresent(Value<IconTextFit>.self, forKey: .iconTextFit)
            iconTextFitPadding = try layoutContainer.decodeIfPresent(Value<[Double]>.self, forKey: .iconTextFitPadding)
            symbolAvoidEdges = try layoutContainer.decodeIfPresent(Value<Bool>.self, forKey: .symbolAvoidEdges)
            symbolPlacement = try layoutContainer.decodeIfPresent(Value<SymbolPlacement>.self, forKey: .symbolPlacement)
            symbolSortKey = try layoutContainer.decodeIfPresent(Value<Double>.self, forKey: .symbolSortKey)
            symbolSpacing = try layoutContainer.decodeIfPresent(Value<Double>.self, forKey: .symbolSpacing)
            symbolZOrder = try layoutContainer.decodeIfPresent(Value<SymbolZOrder>.self, forKey: .symbolZOrder)
            textAllowOverlap = try layoutContainer.decodeIfPresent(Value<Bool>.self, forKey: .textAllowOverlap)
            textAnchor = try layoutContainer.decodeIfPresent(Value<TextAnchor>.self, forKey: .textAnchor)
            textField = try layoutContainer.decodeIfPresent(Value<String>.self, forKey: .textField)
            textFont = try layoutContainer.decodeIfPresent(Value<[String]>.self, forKey: .textFont)
            textIgnorePlacement = try layoutContainer.decodeIfPresent(Value<Bool>.self, forKey: .textIgnorePlacement)
            textJustify = try layoutContainer.decodeIfPresent(Value<TextJustify>.self, forKey: .textJustify)
            textKeepUpright = try layoutContainer.decodeIfPresent(Value<Bool>.self, forKey: .textKeepUpright)
            textLetterSpacing = try layoutContainer.decodeIfPresent(Value<Double>.self, forKey: .textLetterSpacing)
            textLineHeight = try layoutContainer.decodeIfPresent(Value<Double>.self, forKey: .textLineHeight)
            textMaxAngle = try layoutContainer.decodeIfPresent(Value<Double>.self, forKey: .textMaxAngle)
            textMaxWidth = try layoutContainer.decodeIfPresent(Value<Double>.self, forKey: .textMaxWidth)
            textOffset = try layoutContainer.decodeIfPresent(Value<[Double]>.self, forKey: .textOffset)
            textOptional = try layoutContainer.decodeIfPresent(Value<Bool>.self, forKey: .textOptional)
            textPadding = try layoutContainer.decodeIfPresent(Value<Double>.self, forKey: .textPadding)
            textPitchAlignment = try layoutContainer.decodeIfPresent(Value<TextPitchAlignment>.self, forKey: .textPitchAlignment)
            textRadialOffset = try layoutContainer.decodeIfPresent(Value<Double>.self, forKey: .textRadialOffset)
            textRotate = try layoutContainer.decodeIfPresent(Value<Double>.self, forKey: .textRotate)
            textRotationAlignment = try layoutContainer.decodeIfPresent(Value<TextRotationAlignment>.self, forKey: .textRotationAlignment)
            textSize = try layoutContainer.decodeIfPresent(Value<Double>.self, forKey: .textSize)
            textTransform = try layoutContainer.decodeIfPresent(Value<TextTransform>.self, forKey: .textTransform)
            textVariableAnchor = try layoutContainer.decodeIfPresent(Value<[TextAnchor]>.self, forKey: .textVariableAnchor)
            textWritingMode = try layoutContainer.decodeIfPresent(Value<[TextWritingMode]>.self, forKey: .textWritingMode)
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
        case iconAllowOverlap = "icon-allow-overlap"
        case iconAnchor = "icon-anchor"
        case iconIgnorePlacement = "icon-ignore-placement"
        case iconImage = "icon-image"
        case iconKeepUpright = "icon-keep-upright"
        case iconOffset = "icon-offset"
        case iconOptional = "icon-optional"
        case iconPadding = "icon-padding"
        case iconPitchAlignment = "icon-pitch-alignment"
        case iconRotate = "icon-rotate"
        case iconRotationAlignment = "icon-rotation-alignment"
        case iconSize = "icon-size"
        case iconTextFit = "icon-text-fit"
        case iconTextFitPadding = "icon-text-fit-padding"
        case symbolAvoidEdges = "symbol-avoid-edges"
        case symbolPlacement = "symbol-placement"
        case symbolSortKey = "symbol-sort-key"
        case symbolSpacing = "symbol-spacing"
        case symbolZOrder = "symbol-z-order"
        case textAllowOverlap = "text-allow-overlap"
        case textAnchor = "text-anchor"
        case textField = "text-field"
        case textFont = "text-font"
        case textIgnorePlacement = "text-ignore-placement"
        case textJustify = "text-justify"
        case textKeepUpright = "text-keep-upright"
        case textLetterSpacing = "text-letter-spacing"
        case textLineHeight = "text-line-height"
        case textMaxAngle = "text-max-angle"
        case textMaxWidth = "text-max-width"
        case textOffset = "text-offset"
        case textOptional = "text-optional"
        case textPadding = "text-padding"
        case textPitchAlignment = "text-pitch-alignment"
        case textRadialOffset = "text-radial-offset"
        case textRotate = "text-rotate"
        case textRotationAlignment = "text-rotation-alignment"
        case textSize = "text-size"
        case textTransform = "text-transform"
        case textVariableAnchor = "text-variable-anchor"
        case textWritingMode = "text-writing-mode"
        case visibility = "visibility"
    }

    enum PaintCodingKeys: String, CodingKey {
        case iconColor = "icon-color"
        case iconColorTransition = "icon-color-transition"
        case iconHaloBlur = "icon-halo-blur"
        case iconHaloBlurTransition = "icon-halo-blur-transition"
        case iconHaloColor = "icon-halo-color"
        case iconHaloColorTransition = "icon-halo-color-transition"
        case iconHaloWidth = "icon-halo-width"
        case iconHaloWidthTransition = "icon-halo-width-transition"
        case iconOpacity = "icon-opacity"
        case iconOpacityTransition = "icon-opacity-transition"
        case iconTranslate = "icon-translate"
        case iconTranslateTransition = "icon-translate-transition"
        case iconTranslateAnchor = "icon-translate-anchor"
        case textColor = "text-color"
        case textColorTransition = "text-color-transition"
        case textHaloBlur = "text-halo-blur"
        case textHaloBlurTransition = "text-halo-blur-transition"
        case textHaloColor = "text-halo-color"
        case textHaloColorTransition = "text-halo-color-transition"
        case textHaloWidth = "text-halo-width"
        case textHaloWidthTransition = "text-halo-width-transition"
        case textOpacity = "text-opacity"
        case textOpacityTransition = "text-opacity-transition"
        case textTranslate = "text-translate"
        case textTranslateTransition = "text-translate-transition"
        case textTranslateAnchor = "text-translate-anchor"
    }
}

// End of generated file.
