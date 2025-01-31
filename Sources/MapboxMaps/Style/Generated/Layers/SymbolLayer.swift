// This file is generated.
import UIKit

/// An icon or a text label.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#layers-symbol)
public struct SymbolLayer: Layer, Equatable {

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

    /// If true, the icon will be visible even if it collides with other previously drawn symbols.
    /// Default value: false.
    public var iconAllowOverlap: Value<Bool>?

    /// Part of the icon placed closest to the anchor.
    /// Default value: "center".
    public var iconAnchor: Value<IconAnchor>?

    /// If true, other symbols can be visible even if they collide with the icon.
    /// Default value: false.
    public var iconIgnorePlacement: Value<Bool>?

    /// Name of image in sprite to use for drawing an image background.
    public var iconImage: Value<ResolvedImage>?

    /// If true, the icon may be flipped to prevent it from being rendered upside-down.
    /// Default value: false.
    public var iconKeepUpright: Value<Bool>?

    /// Offset distance of icon from its anchor. Positive values indicate right and down, while negative values indicate left and up. Each component is multiplied by the value of `icon-size` to obtain the final offset in pixels. When combined with `icon-rotate` the offset will be as if the rotated direction was up.
    /// Default value: [0,0].
    public var iconOffset: Value<[Double]>?

    /// If true, text will display without their corresponding icons when the icon collides with other symbols and the text does not.
    /// Default value: false.
    public var iconOptional: Value<Bool>?

    /// Size of the additional area around the icon bounding box used for detecting symbol collisions.
    /// Default value: 2. Minimum value: 0. The unit of iconPadding is in pixels.
    public var iconPadding: Value<Double>?

    /// Orientation of icon when map is pitched.
    /// Default value: "auto".
    public var iconPitchAlignment: Value<IconPitchAlignment>?

    /// Rotates the icon clockwise.
    /// Default value: 0. The unit of iconRotate is in degrees.
    public var iconRotate: Value<Double>?

    /// In combination with `symbol-placement`, determines the rotation behavior of icons.
    /// Default value: "auto".
    public var iconRotationAlignment: Value<IconRotationAlignment>?

    /// Scales the original size of the icon by the provided factor. The new pixel size of the image will be the original pixel size multiplied by `icon-size`. 1 is the original size; 3 triples the size of the image.
    /// Default value: 1. Minimum value: 0. The unit of iconSize is in factor of the original icon size.
    public var iconSize: Value<Double>?

    /// Defines the minimum and maximum scaling factors for icon related properties like `icon-size`, `icon-halo-width`, `icon-halo-blur`
    /// Default value: [0.8,2]. Value range: [0.1, 10]
    @_documentation(visibility: public)
    @_spi(Experimental) public var iconSizeScaleRange: Value<[Double]>?

    /// Scales the icon to fit around the associated text.
    /// Default value: "none".
    public var iconTextFit: Value<IconTextFit>?

    /// Size of the additional area added to dimensions determined by `icon-text-fit`, in clockwise order: top, right, bottom, left.
    /// Default value: [0,0,0,0]. The unit of iconTextFitPadding is in pixels.
    public var iconTextFitPadding: Value<[Double]>?

    /// If true, the symbols will not cross tile edges to avoid mutual collisions. Recommended in layers that don't have enough padding in the vector tile to prevent collisions, or if it is a point symbol layer placed after a line symbol layer. When using a client that supports global collision detection, like Mapbox GL JS version 0.42.0 or greater, enabling this property is not needed to prevent clipped labels at tile boundaries.
    /// Default value: false.
    public var symbolAvoidEdges: Value<Bool>?

    /// Selects the base of symbol-elevation.
    /// Default value: "ground".
    @_documentation(visibility: public)
    @_spi(Experimental) public var symbolElevationReference: Value<SymbolElevationReference>?

    /// Label placement relative to its geometry.
    /// Default value: "point".
    public var symbolPlacement: Value<SymbolPlacement>?

    /// Sorts features in ascending order based on this value. Features with lower sort keys are drawn and placed first. When `icon-allow-overlap` or `text-allow-overlap` is `false`, features with a lower sort key will have priority during placement. When `icon-allow-overlap` or `text-allow-overlap` is set to `true`, features with a higher sort key will overlap over features with a lower sort key.
    public var symbolSortKey: Value<Double>?

    /// Distance between two symbol anchors.
    /// Default value: 250. Minimum value: 1. The unit of symbolSpacing is in pixels.
    public var symbolSpacing: Value<Double>?

    /// Position symbol on buildings (both fill extrusions and models) rooftops. In order to have minimal impact on performance, this is supported only when `fill-extrusion-height` is not zoom-dependent and remains unchanged. For fading in buildings when zooming in, fill-extrusion-vertical-scale should be used and symbols would raise with building rooftops. Symbols are sorted by elevation, except in cases when `viewport-y` sorting or `symbol-sort-key` are applied.
    /// Default value: false.
    public var symbolZElevate: Value<Bool>?

    /// Determines whether overlapping symbols in the same layer are rendered in the order that they appear in the data source or by their y-position relative to the viewport. To control the order and prioritization of symbols otherwise, use `symbol-sort-key`.
    /// Default value: "auto".
    public var symbolZOrder: Value<SymbolZOrder>?

    /// If true, the text will be visible even if it collides with other previously drawn symbols.
    /// Default value: false.
    public var textAllowOverlap: Value<Bool>?

    /// Part of the text placed closest to the anchor.
    /// Default value: "center".
    public var textAnchor: Value<TextAnchor>?

    /// Value to use for a text label. If a plain `string` is provided, it will be treated as a `formatted` with default/inherited formatting options. SDF images are not supported in formatted text and will be ignored.
    /// Default value: "".
    public var textField: Value<String>?

    /// Font stack to use for displaying text.
    public var textFont: Value<[String]>?

    /// If true, other symbols can be visible even if they collide with the text.
    /// Default value: false.
    public var textIgnorePlacement: Value<Bool>?

    /// Text justification options.
    /// Default value: "center".
    public var textJustify: Value<TextJustify>?

    /// If true, the text may be flipped vertically to prevent it from being rendered upside-down.
    /// Default value: true.
    public var textKeepUpright: Value<Bool>?

    /// Text tracking amount.
    /// Default value: 0. The unit of textLetterSpacing is in ems.
    public var textLetterSpacing: Value<Double>?

    /// Text leading value for multi-line text.
    /// Default value: 1.2. The unit of textLineHeight is in ems.
    public var textLineHeight: Value<Double>?

    /// Maximum angle change between adjacent characters.
    /// Default value: 45. The unit of textMaxAngle is in degrees.
    public var textMaxAngle: Value<Double>?

    /// The maximum line width for text wrapping.
    /// Default value: 10. Minimum value: 0. The unit of textMaxWidth is in ems.
    public var textMaxWidth: Value<Double>?

    /// Offset distance of text from its anchor. Positive values indicate right and down, while negative values indicate left and up. If used with text-variable-anchor, input values will be taken as absolute values. Offsets along the x- and y-axis will be applied automatically based on the anchor position.
    /// Default value: [0,0]. The unit of textOffset is in ems.
    public var textOffset: Value<[Double]>?

    /// If true, icons will display without their corresponding text when the text collides with other symbols and the icon does not.
    /// Default value: false.
    public var textOptional: Value<Bool>?

    /// Size of the additional area around the text bounding box used for detecting symbol collisions.
    /// Default value: 2. Minimum value: 0. The unit of textPadding is in pixels.
    public var textPadding: Value<Double>?

    /// Orientation of text when map is pitched.
    /// Default value: "auto".
    public var textPitchAlignment: Value<TextPitchAlignment>?

    /// Radial offset of text, in the direction of the symbol's anchor. Useful in combination with `text-variable-anchor`, which defaults to using the two-dimensional `text-offset` if present.
    /// Default value: 0. The unit of textRadialOffset is in ems.
    public var textRadialOffset: Value<Double>?

    /// Rotates the text clockwise.
    /// Default value: 0. The unit of textRotate is in degrees.
    public var textRotate: Value<Double>?

    /// In combination with `symbol-placement`, determines the rotation behavior of the individual glyphs forming the text.
    /// Default value: "auto".
    public var textRotationAlignment: Value<TextRotationAlignment>?

    /// Font size.
    /// Default value: 16. Minimum value: 0. The unit of textSize is in pixels.
    public var textSize: Value<Double>?

    /// Defines the minimum and maximum scaling factors for text related properties like `text-size`, `text-max-width`, `text-halo-width`, `font-size`
    /// Default value: [0.8,2]. Value range: [0.1, 10]
    @_documentation(visibility: public)
    @_spi(Experimental) public var textSizeScaleRange: Value<[Double]>?

    /// Specifies how to capitalize text, similar to the CSS `text-transform` property.
    /// Default value: "none".
    public var textTransform: Value<TextTransform>?

    /// To increase the chance of placing high-priority labels on the map, you can provide an array of `text-anchor` locations: the renderer will attempt to place the label at each location, in order, before moving onto the next label. Use `text-justify: auto` to choose justification based on anchor position. To apply an offset, use the `text-radial-offset` or the two-dimensional `text-offset`.
    public var textVariableAnchor: Value<[TextAnchor]>?

    /// The property allows control over a symbol's orientation. Note that the property values act as a hint, so that a symbol whose language doesn’t support the provided orientation will be laid out in its natural orientation. Example: English point symbol will be rendered horizontally even if array value contains single 'vertical' enum value. For symbol with point placement, the order of elements in an array define priority order for the placement of an orientation variant. For symbol with line placement, the default text writing mode is either ['horizontal', 'vertical'] or ['vertical', 'horizontal'], the order doesn't affect the placement.
    public var textWritingMode: Value<[TextWritingMode]>?

    /// The color of the icon. This can only be used with [SDF icons](/help/troubleshooting/using-recolorable-images-in-mapbox-maps/).
    /// Default value: "#000000".
    public var iconColor: Value<StyleColor>?

    /// Transition options for `iconColor`.
    public var iconColorTransition: StyleTransition?
    /// This property defines whether to use colorTheme defined color or not.
    /// By default it will use color defined by the root theme in the style.
    /// NOTE: - Expressions set to this property currently don't work.
    @_spi(Experimental) public var iconColorUseTheme: Value<ColorUseTheme>?

    /// Increase or reduce the saturation of the symbol icon.
    /// Default value: 0. Value range: [-1, 1]
    public var iconColorSaturation: Value<Double>?

    /// Transition options for `iconColorSaturation`.
    public var iconColorSaturationTransition: StyleTransition?

    /// Controls the intensity of light emitted on the source features.
    /// Default value: 1. Minimum value: 0. The unit of iconEmissiveStrength is in intensity.
    public var iconEmissiveStrength: Value<Double>?

    /// Transition options for `iconEmissiveStrength`.
    public var iconEmissiveStrengthTransition: StyleTransition?

    /// Fade out the halo towards the outside.
    /// Default value: 0. Minimum value: 0. The unit of iconHaloBlur is in pixels.
    public var iconHaloBlur: Value<Double>?

    /// Transition options for `iconHaloBlur`.
    public var iconHaloBlurTransition: StyleTransition?

    /// The color of the icon's halo. Icon halos can only be used with [SDF icons](/help/troubleshooting/using-recolorable-images-in-mapbox-maps/).
    /// Default value: "rgba(0, 0, 0, 0)".
    public var iconHaloColor: Value<StyleColor>?

    /// Transition options for `iconHaloColor`.
    public var iconHaloColorTransition: StyleTransition?
    /// This property defines whether to use colorTheme defined color or not.
    /// By default it will use color defined by the root theme in the style.
    /// NOTE: - Expressions set to this property currently don't work.
    @_spi(Experimental) public var iconHaloColorUseTheme: Value<ColorUseTheme>?

    /// Distance of halo to the icon outline.
    /// Default value: 0. Minimum value: 0. The unit of iconHaloWidth is in pixels.
    public var iconHaloWidth: Value<Double>?

    /// Transition options for `iconHaloWidth`.
    public var iconHaloWidthTransition: StyleTransition?

    /// Controls the transition progress between the image variants of icon-image. Zero means the first variant is used, one is the second, and in between they are blended together.
    /// Default value: 0. Value range: [0, 1]
    public var iconImageCrossFade: Value<Double>?

    /// Transition options for `iconImageCrossFade`.
    public var iconImageCrossFadeTransition: StyleTransition?

    /// The opacity at which the icon will be drawn in case of being depth occluded. Absent value means full occlusion against terrain only.
    /// Default value: 0. Value range: [0, 1]
    public var iconOcclusionOpacity: Value<Double>?

    /// Transition options for `iconOcclusionOpacity`.
    public var iconOcclusionOpacityTransition: StyleTransition?

    /// The opacity at which the icon will be drawn.
    /// Default value: 1. Value range: [0, 1]
    public var iconOpacity: Value<Double>?

    /// Transition options for `iconOpacity`.
    public var iconOpacityTransition: StyleTransition?

    /// Distance that the icon's anchor is moved from its original placement. Positive values indicate right and down, while negative values indicate left and up.
    /// Default value: [0,0]. The unit of iconTranslate is in pixels.
    public var iconTranslate: Value<[Double]>?

    /// Transition options for `iconTranslate`.
    public var iconTranslateTransition: StyleTransition?

    /// Controls the frame of reference for `icon-translate`.
    /// Default value: "map".
    public var iconTranslateAnchor: Value<IconTranslateAnchor>?

    /// Specifies an uniform elevation from the ground, in meters.
    /// Default value: 0. Minimum value: 0.
    @_documentation(visibility: public)
    @_spi(Experimental) public var symbolZOffset: Value<Double>?

    /// Transition options for `symbolZOffset`.
    @_documentation(visibility: public)
    @_spi(Experimental) public var symbolZOffsetTransition: StyleTransition?

    /// The color with which the text will be drawn.
    /// Default value: "#000000".
    public var textColor: Value<StyleColor>?

    /// Transition options for `textColor`.
    public var textColorTransition: StyleTransition?
    /// This property defines whether to use colorTheme defined color or not.
    /// By default it will use color defined by the root theme in the style.
    /// NOTE: - Expressions set to this property currently don't work.
    @_spi(Experimental) public var textColorUseTheme: Value<ColorUseTheme>?

    /// Controls the intensity of light emitted on the source features.
    /// Default value: 1. Minimum value: 0. The unit of textEmissiveStrength is in intensity.
    public var textEmissiveStrength: Value<Double>?

    /// Transition options for `textEmissiveStrength`.
    public var textEmissiveStrengthTransition: StyleTransition?

    /// The halo's fadeout distance towards the outside.
    /// Default value: 0. Minimum value: 0. The unit of textHaloBlur is in pixels.
    public var textHaloBlur: Value<Double>?

    /// Transition options for `textHaloBlur`.
    public var textHaloBlurTransition: StyleTransition?

    /// The color of the text's halo, which helps it stand out from backgrounds.
    /// Default value: "rgba(0, 0, 0, 0)".
    public var textHaloColor: Value<StyleColor>?

    /// Transition options for `textHaloColor`.
    public var textHaloColorTransition: StyleTransition?
    /// This property defines whether to use colorTheme defined color or not.
    /// By default it will use color defined by the root theme in the style.
    /// NOTE: - Expressions set to this property currently don't work.
    @_spi(Experimental) public var textHaloColorUseTheme: Value<ColorUseTheme>?

    /// Distance of halo to the font outline. Max text halo width is 1/4 of the font-size.
    /// Default value: 0. Minimum value: 0. The unit of textHaloWidth is in pixels.
    public var textHaloWidth: Value<Double>?

    /// Transition options for `textHaloWidth`.
    public var textHaloWidthTransition: StyleTransition?

    /// The opacity at which the text will be drawn in case of being depth occluded. Absent value means full occlusion against terrain only.
    /// Default value: 0. Value range: [0, 1]
    public var textOcclusionOpacity: Value<Double>?

    /// Transition options for `textOcclusionOpacity`.
    public var textOcclusionOpacityTransition: StyleTransition?

    /// The opacity at which the text will be drawn.
    /// Default value: 1. Value range: [0, 1]
    public var textOpacity: Value<Double>?

    /// Transition options for `textOpacity`.
    public var textOpacityTransition: StyleTransition?

    /// Distance that the text's anchor is moved from its original placement. Positive values indicate right and down, while negative values indicate left and up.
    /// Default value: [0,0]. The unit of textTranslate is in pixels.
    public var textTranslate: Value<[Double]>?

    /// Transition options for `textTranslate`.
    public var textTranslateTransition: StyleTransition?

    /// Controls the frame of reference for `text-translate`.
    /// Default value: "map".
    public var textTranslateAnchor: Value<TextTranslateAnchor>?

    public init(id: String, source: String) {
        self.source = source
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
        try container.encodeIfPresent(slot, forKey: .slot)
        try container.encodeIfPresent(minZoom, forKey: .minZoom)
        try container.encodeIfPresent(maxZoom, forKey: .maxZoom)

        var paintContainer = container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint)
        try paintContainer.encodeIfPresent(iconColor, forKey: .iconColor)
        try paintContainer.encodeIfPresent(iconColorTransition, forKey: .iconColorTransition)
        try paintContainer.encodeIfPresent(iconColorUseTheme, forKey: .iconColorUseTheme)
        try paintContainer.encodeIfPresent(iconColorSaturation, forKey: .iconColorSaturation)
        try paintContainer.encodeIfPresent(iconColorSaturationTransition, forKey: .iconColorSaturationTransition)
        try paintContainer.encodeIfPresent(iconEmissiveStrength, forKey: .iconEmissiveStrength)
        try paintContainer.encodeIfPresent(iconEmissiveStrengthTransition, forKey: .iconEmissiveStrengthTransition)
        try paintContainer.encodeIfPresent(iconHaloBlur, forKey: .iconHaloBlur)
        try paintContainer.encodeIfPresent(iconHaloBlurTransition, forKey: .iconHaloBlurTransition)
        try paintContainer.encodeIfPresent(iconHaloColor, forKey: .iconHaloColor)
        try paintContainer.encodeIfPresent(iconHaloColorTransition, forKey: .iconHaloColorTransition)
        try paintContainer.encodeIfPresent(iconHaloColorUseTheme, forKey: .iconHaloColorUseTheme)
        try paintContainer.encodeIfPresent(iconHaloWidth, forKey: .iconHaloWidth)
        try paintContainer.encodeIfPresent(iconHaloWidthTransition, forKey: .iconHaloWidthTransition)
        try paintContainer.encodeIfPresent(iconImageCrossFade, forKey: .iconImageCrossFade)
        try paintContainer.encodeIfPresent(iconImageCrossFadeTransition, forKey: .iconImageCrossFadeTransition)
        try paintContainer.encodeIfPresent(iconOcclusionOpacity, forKey: .iconOcclusionOpacity)
        try paintContainer.encodeIfPresent(iconOcclusionOpacityTransition, forKey: .iconOcclusionOpacityTransition)
        try paintContainer.encodeIfPresent(iconOpacity, forKey: .iconOpacity)
        try paintContainer.encodeIfPresent(iconOpacityTransition, forKey: .iconOpacityTransition)
        try paintContainer.encodeIfPresent(iconTranslate, forKey: .iconTranslate)
        try paintContainer.encodeIfPresent(iconTranslateTransition, forKey: .iconTranslateTransition)
        try paintContainer.encodeIfPresent(iconTranslateAnchor, forKey: .iconTranslateAnchor)
        try paintContainer.encodeIfPresent(symbolZOffset, forKey: .symbolZOffset)
        try paintContainer.encodeIfPresent(symbolZOffsetTransition, forKey: .symbolZOffsetTransition)
        try paintContainer.encodeIfPresent(textColor, forKey: .textColor)
        try paintContainer.encodeIfPresent(textColorTransition, forKey: .textColorTransition)
        try paintContainer.encodeIfPresent(textColorUseTheme, forKey: .textColorUseTheme)
        try paintContainer.encodeIfPresent(textEmissiveStrength, forKey: .textEmissiveStrength)
        try paintContainer.encodeIfPresent(textEmissiveStrengthTransition, forKey: .textEmissiveStrengthTransition)
        try paintContainer.encodeIfPresent(textHaloBlur, forKey: .textHaloBlur)
        try paintContainer.encodeIfPresent(textHaloBlurTransition, forKey: .textHaloBlurTransition)
        try paintContainer.encodeIfPresent(textHaloColor, forKey: .textHaloColor)
        try paintContainer.encodeIfPresent(textHaloColorTransition, forKey: .textHaloColorTransition)
        try paintContainer.encodeIfPresent(textHaloColorUseTheme, forKey: .textHaloColorUseTheme)
        try paintContainer.encodeIfPresent(textHaloWidth, forKey: .textHaloWidth)
        try paintContainer.encodeIfPresent(textHaloWidthTransition, forKey: .textHaloWidthTransition)
        try paintContainer.encodeIfPresent(textOcclusionOpacity, forKey: .textOcclusionOpacity)
        try paintContainer.encodeIfPresent(textOcclusionOpacityTransition, forKey: .textOcclusionOpacityTransition)
        try paintContainer.encodeIfPresent(textOpacity, forKey: .textOpacity)
        try paintContainer.encodeIfPresent(textOpacityTransition, forKey: .textOpacityTransition)
        try paintContainer.encodeIfPresent(textTranslate, forKey: .textTranslate)
        try paintContainer.encodeIfPresent(textTranslateTransition, forKey: .textTranslateTransition)
        try paintContainer.encodeIfPresent(textTranslateAnchor, forKey: .textTranslateAnchor)

        var layoutContainer = container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)
        try layoutContainer.encode(visibility, forKey: .visibility)
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
        try layoutContainer.encodeIfPresent(iconSizeScaleRange, forKey: .iconSizeScaleRange)
        try layoutContainer.encodeIfPresent(iconTextFit, forKey: .iconTextFit)
        try layoutContainer.encodeIfPresent(iconTextFitPadding, forKey: .iconTextFitPadding)
        try layoutContainer.encodeIfPresent(symbolAvoidEdges, forKey: .symbolAvoidEdges)
        try layoutContainer.encodeIfPresent(symbolElevationReference, forKey: .symbolElevationReference)
        try layoutContainer.encodeIfPresent(symbolPlacement, forKey: .symbolPlacement)
        try layoutContainer.encodeIfPresent(symbolSortKey, forKey: .symbolSortKey)
        try layoutContainer.encodeIfPresent(symbolSpacing, forKey: .symbolSpacing)
        try layoutContainer.encodeIfPresent(symbolZElevate, forKey: .symbolZElevate)
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
        try layoutContainer.encodeIfPresent(textSizeScaleRange, forKey: .textSizeScaleRange)
        try layoutContainer.encodeIfPresent(textTransform, forKey: .textTransform)
        try layoutContainer.encodeIfPresent(textVariableAnchor, forKey: .textVariableAnchor)
        try layoutContainer.encodeIfPresent(textWritingMode, forKey: .textWritingMode)
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
            iconColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .iconColor)
            iconColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .iconColorTransition)
            iconColorUseTheme = try paintContainer.decodeIfPresent(Value<ColorUseTheme>.self, forKey: .iconColorUseTheme)
            iconColorSaturation = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .iconColorSaturation)
            iconColorSaturationTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .iconColorSaturationTransition)
            iconEmissiveStrength = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .iconEmissiveStrength)
            iconEmissiveStrengthTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .iconEmissiveStrengthTransition)
            iconHaloBlur = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .iconHaloBlur)
            iconHaloBlurTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .iconHaloBlurTransition)
            iconHaloColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .iconHaloColor)
            iconHaloColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .iconHaloColorTransition)
            iconHaloColorUseTheme = try paintContainer.decodeIfPresent(Value<ColorUseTheme>.self, forKey: .iconHaloColorUseTheme)
            iconHaloWidth = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .iconHaloWidth)
            iconHaloWidthTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .iconHaloWidthTransition)
            iconImageCrossFade = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .iconImageCrossFade)
            iconImageCrossFadeTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .iconImageCrossFadeTransition)
            iconOcclusionOpacity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .iconOcclusionOpacity)
            iconOcclusionOpacityTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .iconOcclusionOpacityTransition)
            iconOpacity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .iconOpacity)
            iconOpacityTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .iconOpacityTransition)
            iconTranslate = try paintContainer.decodeIfPresent(Value<[Double]>.self, forKey: .iconTranslate)
            iconTranslateTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .iconTranslateTransition)
            iconTranslateAnchor = try paintContainer.decodeIfPresent(Value<IconTranslateAnchor>.self, forKey: .iconTranslateAnchor)
            symbolZOffset = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .symbolZOffset)
            symbolZOffsetTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .symbolZOffsetTransition)
            textColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .textColor)
            textColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .textColorTransition)
            textColorUseTheme = try paintContainer.decodeIfPresent(Value<ColorUseTheme>.self, forKey: .textColorUseTheme)
            textEmissiveStrength = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .textEmissiveStrength)
            textEmissiveStrengthTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .textEmissiveStrengthTransition)
            textHaloBlur = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .textHaloBlur)
            textHaloBlurTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .textHaloBlurTransition)
            textHaloColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .textHaloColor)
            textHaloColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .textHaloColorTransition)
            textHaloColorUseTheme = try paintContainer.decodeIfPresent(Value<ColorUseTheme>.self, forKey: .textHaloColorUseTheme)
            textHaloWidth = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .textHaloWidth)
            textHaloWidthTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .textHaloWidthTransition)
            textOcclusionOpacity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .textOcclusionOpacity)
            textOcclusionOpacityTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .textOcclusionOpacityTransition)
            textOpacity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .textOpacity)
            textOpacityTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .textOpacityTransition)
            textTranslate = try paintContainer.decodeIfPresent(Value<[Double]>.self, forKey: .textTranslate)
            textTranslateTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .textTranslateTransition)
            textTranslateAnchor = try paintContainer.decodeIfPresent(Value<TextTranslateAnchor>.self, forKey: .textTranslateAnchor)
        }

        var visibilityEncoded: Value<Visibility>?
        if let layoutContainer = try? container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout) {
            visibilityEncoded = try layoutContainer.decodeIfPresent(Value<Visibility>.self, forKey: .visibility)
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
            iconSizeScaleRange = try layoutContainer.decodeIfPresent(Value<[Double]>.self, forKey: .iconSizeScaleRange)
            iconTextFit = try layoutContainer.decodeIfPresent(Value<IconTextFit>.self, forKey: .iconTextFit)
            iconTextFitPadding = try layoutContainer.decodeIfPresent(Value<[Double]>.self, forKey: .iconTextFitPadding)
            symbolAvoidEdges = try layoutContainer.decodeIfPresent(Value<Bool>.self, forKey: .symbolAvoidEdges)
            symbolElevationReference = try layoutContainer.decodeIfPresent(Value<SymbolElevationReference>.self, forKey: .symbolElevationReference)
            symbolPlacement = try layoutContainer.decodeIfPresent(Value<SymbolPlacement>.self, forKey: .symbolPlacement)
            symbolSortKey = try layoutContainer.decodeIfPresent(Value<Double>.self, forKey: .symbolSortKey)
            symbolSpacing = try layoutContainer.decodeIfPresent(Value<Double>.self, forKey: .symbolSpacing)
            symbolZElevate = try layoutContainer.decodeIfPresent(Value<Bool>.self, forKey: .symbolZElevate)
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
            textSizeScaleRange = try layoutContainer.decodeIfPresent(Value<[Double]>.self, forKey: .textSizeScaleRange)
            textTransform = try layoutContainer.decodeIfPresent(Value<TextTransform>.self, forKey: .textTransform)
            textVariableAnchor = try layoutContainer.decodeIfPresent(Value<[TextAnchor]>.self, forKey: .textVariableAnchor)
            textWritingMode = try layoutContainer.decodeIfPresent(Value<[TextWritingMode]>.self, forKey: .textWritingMode)
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
        case iconSizeScaleRange = "icon-size-scale-range"
        case iconTextFit = "icon-text-fit"
        case iconTextFitPadding = "icon-text-fit-padding"
        case symbolAvoidEdges = "symbol-avoid-edges"
        case symbolElevationReference = "symbol-elevation-reference"
        case symbolPlacement = "symbol-placement"
        case symbolSortKey = "symbol-sort-key"
        case symbolSpacing = "symbol-spacing"
        case symbolZElevate = "symbol-z-elevate"
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
        case textSizeScaleRange = "text-size-scale-range"
        case textTransform = "text-transform"
        case textVariableAnchor = "text-variable-anchor"
        case textWritingMode = "text-writing-mode"
        case visibility = "visibility"
    }

    enum PaintCodingKeys: String, CodingKey {
        case iconColor = "icon-color"
        case iconColorTransition = "icon-color-transition"
        case iconColorUseTheme = "icon-color-use-theme"
        case iconColorSaturation = "icon-color-saturation"
        case iconColorSaturationTransition = "icon-color-saturation-transition"
        case iconEmissiveStrength = "icon-emissive-strength"
        case iconEmissiveStrengthTransition = "icon-emissive-strength-transition"
        case iconHaloBlur = "icon-halo-blur"
        case iconHaloBlurTransition = "icon-halo-blur-transition"
        case iconHaloColor = "icon-halo-color"
        case iconHaloColorTransition = "icon-halo-color-transition"
        case iconHaloColorUseTheme = "icon-halo-color-use-theme"
        case iconHaloWidth = "icon-halo-width"
        case iconHaloWidthTransition = "icon-halo-width-transition"
        case iconImageCrossFade = "icon-image-cross-fade"
        case iconImageCrossFadeTransition = "icon-image-cross-fade-transition"
        case iconOcclusionOpacity = "icon-occlusion-opacity"
        case iconOcclusionOpacityTransition = "icon-occlusion-opacity-transition"
        case iconOpacity = "icon-opacity"
        case iconOpacityTransition = "icon-opacity-transition"
        case iconTranslate = "icon-translate"
        case iconTranslateTransition = "icon-translate-transition"
        case iconTranslateAnchor = "icon-translate-anchor"
        case symbolZOffset = "symbol-z-offset"
        case symbolZOffsetTransition = "symbol-z-offset-transition"
        case textColor = "text-color"
        case textColorTransition = "text-color-transition"
        case textColorUseTheme = "text-color-use-theme"
        case textEmissiveStrength = "text-emissive-strength"
        case textEmissiveStrengthTransition = "text-emissive-strength-transition"
        case textHaloBlur = "text-halo-blur"
        case textHaloBlurTransition = "text-halo-blur-transition"
        case textHaloColor = "text-halo-color"
        case textHaloColorTransition = "text-halo-color-transition"
        case textHaloColorUseTheme = "text-halo-color-use-theme"
        case textHaloWidth = "text-halo-width"
        case textHaloWidthTransition = "text-halo-width-transition"
        case textOcclusionOpacity = "text-occlusion-opacity"
        case textOcclusionOpacityTransition = "text-occlusion-opacity-transition"
        case textOpacity = "text-opacity"
        case textOpacityTransition = "text-opacity-transition"
        case textTranslate = "text-translate"
        case textTranslateTransition = "text-translate-transition"
        case textTranslateAnchor = "text-translate-anchor"
    }
}

extension SymbolLayer {
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

    /// If true, the icon will be visible even if it collides with other previously drawn symbols.
    /// Default value: false.
    public func iconAllowOverlap(_ constant: Bool) -> Self {
        with(self, setter(\.iconAllowOverlap, .constant(constant)))
    }

    /// If true, the icon will be visible even if it collides with other previously drawn symbols.
    /// Default value: false.
    public func iconAllowOverlap(_ expression: Exp) -> Self {
        with(self, setter(\.iconAllowOverlap, .expression(expression)))
    }

    /// Part of the icon placed closest to the anchor.
    /// Default value: "center".
    public func iconAnchor(_ constant: IconAnchor) -> Self {
        with(self, setter(\.iconAnchor, .constant(constant)))
    }

    /// Part of the icon placed closest to the anchor.
    /// Default value: "center".
    public func iconAnchor(_ expression: Exp) -> Self {
        with(self, setter(\.iconAnchor, .expression(expression)))
    }

    /// If true, other symbols can be visible even if they collide with the icon.
    /// Default value: false.
    public func iconIgnorePlacement(_ constant: Bool) -> Self {
        with(self, setter(\.iconIgnorePlacement, .constant(constant)))
    }

    /// If true, other symbols can be visible even if they collide with the icon.
    /// Default value: false.
    public func iconIgnorePlacement(_ expression: Exp) -> Self {
        with(self, setter(\.iconIgnorePlacement, .expression(expression)))
    }

    /// Name of image in sprite to use for drawing an image background.
    public func iconImage(_ constant: String) -> Self {
        with(self, setter(\.iconImage, .constant(.name(constant))))
    }

    /// Name of image in sprite to use for drawing an image background.
    public func iconImage(_ expression: Exp) -> Self {
        with(self, setter(\.iconImage, .expression(expression)))
    }

    /// If true, the icon may be flipped to prevent it from being rendered upside-down.
    /// Default value: false.
    public func iconKeepUpright(_ constant: Bool) -> Self {
        with(self, setter(\.iconKeepUpright, .constant(constant)))
    }

    /// If true, the icon may be flipped to prevent it from being rendered upside-down.
    /// Default value: false.
    public func iconKeepUpright(_ expression: Exp) -> Self {
        with(self, setter(\.iconKeepUpright, .expression(expression)))
    }

    /// Offset distance of icon from its anchor. Positive values indicate right and down, while negative values indicate left and up. Each component is multiplied by the value of `icon-size` to obtain the final offset in pixels. When combined with `icon-rotate` the offset will be as if the rotated direction was up.
    /// Default value: [0,0].
    public func iconOffset(x: Double, y: Double) -> Self {
        with(self, setter(\.iconOffset, .constant([x, y])))
    }

    /// Offset distance of icon from its anchor. Positive values indicate right and down, while negative values indicate left and up. Each component is multiplied by the value of `icon-size` to obtain the final offset in pixels. When combined with `icon-rotate` the offset will be as if the rotated direction was up.
    /// Default value: [0,0].
    public func iconOffset(_ expression: Exp) -> Self {
        with(self, setter(\.iconOffset, .expression(expression)))
    }

    /// If true, text will display without their corresponding icons when the icon collides with other symbols and the text does not.
    /// Default value: false.
    public func iconOptional(_ constant: Bool) -> Self {
        with(self, setter(\.iconOptional, .constant(constant)))
    }

    /// If true, text will display without their corresponding icons when the icon collides with other symbols and the text does not.
    /// Default value: false.
    public func iconOptional(_ expression: Exp) -> Self {
        with(self, setter(\.iconOptional, .expression(expression)))
    }

    /// Size of the additional area around the icon bounding box used for detecting symbol collisions.
    /// Default value: 2. Minimum value: 0. The unit of iconPadding is in pixels.
    public func iconPadding(_ constant: Double) -> Self {
        with(self, setter(\.iconPadding, .constant(constant)))
    }

    /// Size of the additional area around the icon bounding box used for detecting symbol collisions.
    /// Default value: 2. Minimum value: 0. The unit of iconPadding is in pixels.
    public func iconPadding(_ expression: Exp) -> Self {
        with(self, setter(\.iconPadding, .expression(expression)))
    }

    /// Orientation of icon when map is pitched.
    /// Default value: "auto".
    public func iconPitchAlignment(_ constant: IconPitchAlignment) -> Self {
        with(self, setter(\.iconPitchAlignment, .constant(constant)))
    }

    /// Orientation of icon when map is pitched.
    /// Default value: "auto".
    public func iconPitchAlignment(_ expression: Exp) -> Self {
        with(self, setter(\.iconPitchAlignment, .expression(expression)))
    }

    /// Rotates the icon clockwise.
    /// Default value: 0. The unit of iconRotate is in degrees.
    public func iconRotate(_ constant: Double) -> Self {
        with(self, setter(\.iconRotate, .constant(constant)))
    }

    /// Rotates the icon clockwise.
    /// Default value: 0. The unit of iconRotate is in degrees.
    public func iconRotate(_ expression: Exp) -> Self {
        with(self, setter(\.iconRotate, .expression(expression)))
    }

    /// In combination with `symbol-placement`, determines the rotation behavior of icons.
    /// Default value: "auto".
    public func iconRotationAlignment(_ constant: IconRotationAlignment) -> Self {
        with(self, setter(\.iconRotationAlignment, .constant(constant)))
    }

    /// In combination with `symbol-placement`, determines the rotation behavior of icons.
    /// Default value: "auto".
    public func iconRotationAlignment(_ expression: Exp) -> Self {
        with(self, setter(\.iconRotationAlignment, .expression(expression)))
    }

    /// Scales the original size of the icon by the provided factor. The new pixel size of the image will be the original pixel size multiplied by `icon-size`. 1 is the original size; 3 triples the size of the image.
    /// Default value: 1. Minimum value: 0. The unit of iconSize is in factor of the original icon size.
    public func iconSize(_ constant: Double) -> Self {
        with(self, setter(\.iconSize, .constant(constant)))
    }

    /// Scales the original size of the icon by the provided factor. The new pixel size of the image will be the original pixel size multiplied by `icon-size`. 1 is the original size; 3 triples the size of the image.
    /// Default value: 1. Minimum value: 0. The unit of iconSize is in factor of the original icon size.
    public func iconSize(_ expression: Exp) -> Self {
        with(self, setter(\.iconSize, .expression(expression)))
    }

    /// Defines the minimum and maximum scaling factors for icon related properties like `icon-size`, `icon-halo-width`, `icon-halo-blur`
    /// Default value: [0.8,2]. Value range: [0.1, 10]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func iconSizeScaleRange(min: Double, max: Double) -> Self {
        with(self, setter(\.iconSizeScaleRange, .constant([min, max])))
    }

    /// Defines the minimum and maximum scaling factors for icon related properties like `icon-size`, `icon-halo-width`, `icon-halo-blur`
    /// Default value: [0.8,2]. Value range: [0.1, 10]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func iconSizeScaleRange(_ expression: Exp) -> Self {
        with(self, setter(\.iconSizeScaleRange, .expression(expression)))
    }

    /// Scales the icon to fit around the associated text.
    /// Default value: "none".
    public func iconTextFit(_ constant: IconTextFit) -> Self {
        with(self, setter(\.iconTextFit, .constant(constant)))
    }

    /// Scales the icon to fit around the associated text.
    /// Default value: "none".
    public func iconTextFit(_ expression: Exp) -> Self {
        with(self, setter(\.iconTextFit, .expression(expression)))
    }

    /// Size of the additional area added to dimensions determined by `icon-text-fit`, in clockwise order: top, right, bottom, left.
    /// Default value: [0,0,0,0]. The unit of iconTextFitPadding is in pixels.
    public func iconTextFitPadding(_ padding: UIEdgeInsets) -> Self {
        with(self, setter(\.iconTextFitPadding, .constant([padding.top, padding.right, padding.bottom, padding.left])))
    }

    /// Size of the additional area added to dimensions determined by `icon-text-fit`, in clockwise order: top, right, bottom, left.
    /// Default value: [0,0,0,0]. The unit of iconTextFitPadding is in pixels.
    public func iconTextFitPadding(_ expression: Exp) -> Self {
        with(self, setter(\.iconTextFitPadding, .expression(expression)))
    }

    /// If true, the symbols will not cross tile edges to avoid mutual collisions. Recommended in layers that don't have enough padding in the vector tile to prevent collisions, or if it is a point symbol layer placed after a line symbol layer. When using a client that supports global collision detection, like Mapbox GL JS version 0.42.0 or greater, enabling this property is not needed to prevent clipped labels at tile boundaries.
    /// Default value: false.
    public func symbolAvoidEdges(_ constant: Bool) -> Self {
        with(self, setter(\.symbolAvoidEdges, .constant(constant)))
    }

    /// If true, the symbols will not cross tile edges to avoid mutual collisions. Recommended in layers that don't have enough padding in the vector tile to prevent collisions, or if it is a point symbol layer placed after a line symbol layer. When using a client that supports global collision detection, like Mapbox GL JS version 0.42.0 or greater, enabling this property is not needed to prevent clipped labels at tile boundaries.
    /// Default value: false.
    public func symbolAvoidEdges(_ expression: Exp) -> Self {
        with(self, setter(\.symbolAvoidEdges, .expression(expression)))
    }

    /// Selects the base of symbol-elevation.
    /// Default value: "ground".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func symbolElevationReference(_ constant: SymbolElevationReference) -> Self {
        with(self, setter(\.symbolElevationReference, .constant(constant)))
    }

    /// Selects the base of symbol-elevation.
    /// Default value: "ground".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func symbolElevationReference(_ expression: Exp) -> Self {
        with(self, setter(\.symbolElevationReference, .expression(expression)))
    }

    /// Label placement relative to its geometry.
    /// Default value: "point".
    public func symbolPlacement(_ constant: SymbolPlacement) -> Self {
        with(self, setter(\.symbolPlacement, .constant(constant)))
    }

    /// Label placement relative to its geometry.
    /// Default value: "point".
    public func symbolPlacement(_ expression: Exp) -> Self {
        with(self, setter(\.symbolPlacement, .expression(expression)))
    }

    /// Sorts features in ascending order based on this value. Features with lower sort keys are drawn and placed first. When `icon-allow-overlap` or `text-allow-overlap` is `false`, features with a lower sort key will have priority during placement. When `icon-allow-overlap` or `text-allow-overlap` is set to `true`, features with a higher sort key will overlap over features with a lower sort key.
    public func symbolSortKey(_ constant: Double) -> Self {
        with(self, setter(\.symbolSortKey, .constant(constant)))
    }

    /// Sorts features in ascending order based on this value. Features with lower sort keys are drawn and placed first. When `icon-allow-overlap` or `text-allow-overlap` is `false`, features with a lower sort key will have priority during placement. When `icon-allow-overlap` or `text-allow-overlap` is set to `true`, features with a higher sort key will overlap over features with a lower sort key.
    public func symbolSortKey(_ expression: Exp) -> Self {
        with(self, setter(\.symbolSortKey, .expression(expression)))
    }

    /// Distance between two symbol anchors.
    /// Default value: 250. Minimum value: 1. The unit of symbolSpacing is in pixels.
    public func symbolSpacing(_ constant: Double) -> Self {
        with(self, setter(\.symbolSpacing, .constant(constant)))
    }

    /// Distance between two symbol anchors.
    /// Default value: 250. Minimum value: 1. The unit of symbolSpacing is in pixels.
    public func symbolSpacing(_ expression: Exp) -> Self {
        with(self, setter(\.symbolSpacing, .expression(expression)))
    }

    /// Position symbol on buildings (both fill extrusions and models) rooftops. In order to have minimal impact on performance, this is supported only when `fill-extrusion-height` is not zoom-dependent and remains unchanged. For fading in buildings when zooming in, fill-extrusion-vertical-scale should be used and symbols would raise with building rooftops. Symbols are sorted by elevation, except in cases when `viewport-y` sorting or `symbol-sort-key` are applied.
    /// Default value: false.
    public func symbolZElevate(_ constant: Bool) -> Self {
        with(self, setter(\.symbolZElevate, .constant(constant)))
    }

    /// Position symbol on buildings (both fill extrusions and models) rooftops. In order to have minimal impact on performance, this is supported only when `fill-extrusion-height` is not zoom-dependent and remains unchanged. For fading in buildings when zooming in, fill-extrusion-vertical-scale should be used and symbols would raise with building rooftops. Symbols are sorted by elevation, except in cases when `viewport-y` sorting or `symbol-sort-key` are applied.
    /// Default value: false.
    public func symbolZElevate(_ expression: Exp) -> Self {
        with(self, setter(\.symbolZElevate, .expression(expression)))
    }

    /// Determines whether overlapping symbols in the same layer are rendered in the order that they appear in the data source or by their y-position relative to the viewport. To control the order and prioritization of symbols otherwise, use `symbol-sort-key`.
    /// Default value: "auto".
    public func symbolZOrder(_ constant: SymbolZOrder) -> Self {
        with(self, setter(\.symbolZOrder, .constant(constant)))
    }

    /// Determines whether overlapping symbols in the same layer are rendered in the order that they appear in the data source or by their y-position relative to the viewport. To control the order and prioritization of symbols otherwise, use `symbol-sort-key`.
    /// Default value: "auto".
    public func symbolZOrder(_ expression: Exp) -> Self {
        with(self, setter(\.symbolZOrder, .expression(expression)))
    }

    /// If true, the text will be visible even if it collides with other previously drawn symbols.
    /// Default value: false.
    public func textAllowOverlap(_ constant: Bool) -> Self {
        with(self, setter(\.textAllowOverlap, .constant(constant)))
    }

    /// If true, the text will be visible even if it collides with other previously drawn symbols.
    /// Default value: false.
    public func textAllowOverlap(_ expression: Exp) -> Self {
        with(self, setter(\.textAllowOverlap, .expression(expression)))
    }

    /// Part of the text placed closest to the anchor.
    /// Default value: "center".
    public func textAnchor(_ constant: TextAnchor) -> Self {
        with(self, setter(\.textAnchor, .constant(constant)))
    }

    /// Part of the text placed closest to the anchor.
    /// Default value: "center".
    public func textAnchor(_ expression: Exp) -> Self {
        with(self, setter(\.textAnchor, .expression(expression)))
    }

    /// Value to use for a text label. If a plain `string` is provided, it will be treated as a `formatted` with default/inherited formatting options. SDF images are not supported in formatted text and will be ignored.
    /// Default value: "".
    public func textField(_ constant: String) -> Self {
        with(self, setter(\.textField, .constant(constant)))
    }

    /// Value to use for a text label. If a plain `string` is provided, it will be treated as a `formatted` with default/inherited formatting options. SDF images are not supported in formatted text and will be ignored.
    /// Default value: "".
    public func textField(_ expression: Exp) -> Self {
        with(self, setter(\.textField, .expression(expression)))
    }

    /// Font stack to use for displaying text.
    public func textFont(_ constant: [String]) -> Self {
        with(self, setter(\.textFont, .constant(constant)))
    }

    /// Font stack to use for displaying text.
    public func textFont(_ expression: Exp) -> Self {
        with(self, setter(\.textFont, .expression(expression)))
    }

    /// If true, other symbols can be visible even if they collide with the text.
    /// Default value: false.
    public func textIgnorePlacement(_ constant: Bool) -> Self {
        with(self, setter(\.textIgnorePlacement, .constant(constant)))
    }

    /// If true, other symbols can be visible even if they collide with the text.
    /// Default value: false.
    public func textIgnorePlacement(_ expression: Exp) -> Self {
        with(self, setter(\.textIgnorePlacement, .expression(expression)))
    }

    /// Text justification options.
    /// Default value: "center".
    public func textJustify(_ constant: TextJustify) -> Self {
        with(self, setter(\.textJustify, .constant(constant)))
    }

    /// Text justification options.
    /// Default value: "center".
    public func textJustify(_ expression: Exp) -> Self {
        with(self, setter(\.textJustify, .expression(expression)))
    }

    /// If true, the text may be flipped vertically to prevent it from being rendered upside-down.
    /// Default value: true.
    public func textKeepUpright(_ constant: Bool) -> Self {
        with(self, setter(\.textKeepUpright, .constant(constant)))
    }

    /// If true, the text may be flipped vertically to prevent it from being rendered upside-down.
    /// Default value: true.
    public func textKeepUpright(_ expression: Exp) -> Self {
        with(self, setter(\.textKeepUpright, .expression(expression)))
    }

    /// Text tracking amount.
    /// Default value: 0. The unit of textLetterSpacing is in ems.
    public func textLetterSpacing(_ constant: Double) -> Self {
        with(self, setter(\.textLetterSpacing, .constant(constant)))
    }

    /// Text tracking amount.
    /// Default value: 0. The unit of textLetterSpacing is in ems.
    public func textLetterSpacing(_ expression: Exp) -> Self {
        with(self, setter(\.textLetterSpacing, .expression(expression)))
    }

    /// Text leading value for multi-line text.
    /// Default value: 1.2. The unit of textLineHeight is in ems.
    public func textLineHeight(_ constant: Double) -> Self {
        with(self, setter(\.textLineHeight, .constant(constant)))
    }

    /// Text leading value for multi-line text.
    /// Default value: 1.2. The unit of textLineHeight is in ems.
    public func textLineHeight(_ expression: Exp) -> Self {
        with(self, setter(\.textLineHeight, .expression(expression)))
    }

    /// Maximum angle change between adjacent characters.
    /// Default value: 45. The unit of textMaxAngle is in degrees.
    public func textMaxAngle(_ constant: Double) -> Self {
        with(self, setter(\.textMaxAngle, .constant(constant)))
    }

    /// Maximum angle change between adjacent characters.
    /// Default value: 45. The unit of textMaxAngle is in degrees.
    public func textMaxAngle(_ expression: Exp) -> Self {
        with(self, setter(\.textMaxAngle, .expression(expression)))
    }

    /// The maximum line width for text wrapping.
    /// Default value: 10. Minimum value: 0. The unit of textMaxWidth is in ems.
    public func textMaxWidth(_ constant: Double) -> Self {
        with(self, setter(\.textMaxWidth, .constant(constant)))
    }

    /// The maximum line width for text wrapping.
    /// Default value: 10. Minimum value: 0. The unit of textMaxWidth is in ems.
    public func textMaxWidth(_ expression: Exp) -> Self {
        with(self, setter(\.textMaxWidth, .expression(expression)))
    }

    /// Offset distance of text from its anchor. Positive values indicate right and down, while negative values indicate left and up. If used with text-variable-anchor, input values will be taken as absolute values. Offsets along the x- and y-axis will be applied automatically based on the anchor position.
    /// Default value: [0,0]. The unit of textOffset is in ems.
    public func textOffset(x: Double, y: Double) -> Self {
        with(self, setter(\.textOffset, .constant([x, y])))
    }

    /// Offset distance of text from its anchor. Positive values indicate right and down, while negative values indicate left and up. If used with text-variable-anchor, input values will be taken as absolute values. Offsets along the x- and y-axis will be applied automatically based on the anchor position.
    /// Default value: [0,0]. The unit of textOffset is in ems.
    public func textOffset(_ expression: Exp) -> Self {
        with(self, setter(\.textOffset, .expression(expression)))
    }

    /// If true, icons will display without their corresponding text when the text collides with other symbols and the icon does not.
    /// Default value: false.
    public func textOptional(_ constant: Bool) -> Self {
        with(self, setter(\.textOptional, .constant(constant)))
    }

    /// If true, icons will display without their corresponding text when the text collides with other symbols and the icon does not.
    /// Default value: false.
    public func textOptional(_ expression: Exp) -> Self {
        with(self, setter(\.textOptional, .expression(expression)))
    }

    /// Size of the additional area around the text bounding box used for detecting symbol collisions.
    /// Default value: 2. Minimum value: 0. The unit of textPadding is in pixels.
    public func textPadding(_ constant: Double) -> Self {
        with(self, setter(\.textPadding, .constant(constant)))
    }

    /// Size of the additional area around the text bounding box used for detecting symbol collisions.
    /// Default value: 2. Minimum value: 0. The unit of textPadding is in pixels.
    public func textPadding(_ expression: Exp) -> Self {
        with(self, setter(\.textPadding, .expression(expression)))
    }

    /// Orientation of text when map is pitched.
    /// Default value: "auto".
    public func textPitchAlignment(_ constant: TextPitchAlignment) -> Self {
        with(self, setter(\.textPitchAlignment, .constant(constant)))
    }

    /// Orientation of text when map is pitched.
    /// Default value: "auto".
    public func textPitchAlignment(_ expression: Exp) -> Self {
        with(self, setter(\.textPitchAlignment, .expression(expression)))
    }

    /// Radial offset of text, in the direction of the symbol's anchor. Useful in combination with `text-variable-anchor`, which defaults to using the two-dimensional `text-offset` if present.
    /// Default value: 0. The unit of textRadialOffset is in ems.
    public func textRadialOffset(_ constant: Double) -> Self {
        with(self, setter(\.textRadialOffset, .constant(constant)))
    }

    /// Radial offset of text, in the direction of the symbol's anchor. Useful in combination with `text-variable-anchor`, which defaults to using the two-dimensional `text-offset` if present.
    /// Default value: 0. The unit of textRadialOffset is in ems.
    public func textRadialOffset(_ expression: Exp) -> Self {
        with(self, setter(\.textRadialOffset, .expression(expression)))
    }

    /// Rotates the text clockwise.
    /// Default value: 0. The unit of textRotate is in degrees.
    public func textRotate(_ constant: Double) -> Self {
        with(self, setter(\.textRotate, .constant(constant)))
    }

    /// Rotates the text clockwise.
    /// Default value: 0. The unit of textRotate is in degrees.
    public func textRotate(_ expression: Exp) -> Self {
        with(self, setter(\.textRotate, .expression(expression)))
    }

    /// In combination with `symbol-placement`, determines the rotation behavior of the individual glyphs forming the text.
    /// Default value: "auto".
    public func textRotationAlignment(_ constant: TextRotationAlignment) -> Self {
        with(self, setter(\.textRotationAlignment, .constant(constant)))
    }

    /// In combination with `symbol-placement`, determines the rotation behavior of the individual glyphs forming the text.
    /// Default value: "auto".
    public func textRotationAlignment(_ expression: Exp) -> Self {
        with(self, setter(\.textRotationAlignment, .expression(expression)))
    }

    /// Font size.
    /// Default value: 16. Minimum value: 0. The unit of textSize is in pixels.
    public func textSize(_ constant: Double) -> Self {
        with(self, setter(\.textSize, .constant(constant)))
    }

    /// Font size.
    /// Default value: 16. Minimum value: 0. The unit of textSize is in pixels.
    public func textSize(_ expression: Exp) -> Self {
        with(self, setter(\.textSize, .expression(expression)))
    }

    /// Defines the minimum and maximum scaling factors for text related properties like `text-size`, `text-max-width`, `text-halo-width`, `font-size`
    /// Default value: [0.8,2]. Value range: [0.1, 10]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func textSizeScaleRange(min: Double, max: Double) -> Self {
        with(self, setter(\.textSizeScaleRange, .constant([min, max])))
    }

    /// Defines the minimum and maximum scaling factors for text related properties like `text-size`, `text-max-width`, `text-halo-width`, `font-size`
    /// Default value: [0.8,2]. Value range: [0.1, 10]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func textSizeScaleRange(_ expression: Exp) -> Self {
        with(self, setter(\.textSizeScaleRange, .expression(expression)))
    }

    /// Specifies how to capitalize text, similar to the CSS `text-transform` property.
    /// Default value: "none".
    public func textTransform(_ constant: TextTransform) -> Self {
        with(self, setter(\.textTransform, .constant(constant)))
    }

    /// Specifies how to capitalize text, similar to the CSS `text-transform` property.
    /// Default value: "none".
    public func textTransform(_ expression: Exp) -> Self {
        with(self, setter(\.textTransform, .expression(expression)))
    }

    /// To increase the chance of placing high-priority labels on the map, you can provide an array of `text-anchor` locations: the renderer will attempt to place the label at each location, in order, before moving onto the next label. Use `text-justify: auto` to choose justification based on anchor position. To apply an offset, use the `text-radial-offset` or the two-dimensional `text-offset`.
    public func textVariableAnchor(_ constant: [TextAnchor]) -> Self {
        with(self, setter(\.textVariableAnchor, .constant(constant)))
    }

    /// To increase the chance of placing high-priority labels on the map, you can provide an array of `text-anchor` locations: the renderer will attempt to place the label at each location, in order, before moving onto the next label. Use `text-justify: auto` to choose justification based on anchor position. To apply an offset, use the `text-radial-offset` or the two-dimensional `text-offset`.
    public func textVariableAnchor(_ expression: Exp) -> Self {
        with(self, setter(\.textVariableAnchor, .expression(expression)))
    }

    /// The property allows control over a symbol's orientation. Note that the property values act as a hint, so that a symbol whose language doesn’t support the provided orientation will be laid out in its natural orientation. Example: English point symbol will be rendered horizontally even if array value contains single 'vertical' enum value. For symbol with point placement, the order of elements in an array define priority order for the placement of an orientation variant. For symbol with line placement, the default text writing mode is either ['horizontal', 'vertical'] or ['vertical', 'horizontal'], the order doesn't affect the placement.
    public func textWritingMode(_ constant: [TextWritingMode]) -> Self {
        with(self, setter(\.textWritingMode, .constant(constant)))
    }

    /// The property allows control over a symbol's orientation. Note that the property values act as a hint, so that a symbol whose language doesn’t support the provided orientation will be laid out in its natural orientation. Example: English point symbol will be rendered horizontally even if array value contains single 'vertical' enum value. For symbol with point placement, the order of elements in an array define priority order for the placement of an orientation variant. For symbol with line placement, the default text writing mode is either ['horizontal', 'vertical'] or ['vertical', 'horizontal'], the order doesn't affect the placement.
    public func textWritingMode(_ expression: Exp) -> Self {
        with(self, setter(\.textWritingMode, .expression(expression)))
    }

    /// The color of the icon. This can only be used with [SDF icons](/help/troubleshooting/using-recolorable-images-in-mapbox-maps/).
    /// Default value: "#000000".
    public func iconColor(_ constant: StyleColor) -> Self {
        with(self, setter(\.iconColor, .constant(constant)))
    }

    /// The color of the icon. This can only be used with [SDF icons](/help/troubleshooting/using-recolorable-images-in-mapbox-maps/).
    /// Default value: "#000000".
    public func iconColor(_ color: UIColor) -> Self {
        with(self, setter(\.iconColor, .constant(StyleColor(color))))
    }

    /// Transition property for `iconColor`
    public func iconColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.iconColorTransition, transition))
    }

    /// The color of the icon. This can only be used with [SDF icons](/help/troubleshooting/using-recolorable-images-in-mapbox-maps/).
    /// Default value: "#000000".
    public func iconColor(_ expression: Exp) -> Self {
        with(self, setter(\.iconColor, .expression(expression)))
    }

    /// This property defines whether the `iconColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func iconColorUseTheme(_ useTheme: ColorUseTheme) -> Self {
        with(self, setter(\.iconColorUseTheme, .constant(useTheme)))
    }

    /// This property defines whether the `iconColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func iconColorUseTheme(_ expression: Exp) -> Self {
        with(self, setter(\.iconColorUseTheme, .expression(expression)))
    }

    /// Increase or reduce the saturation of the symbol icon.
    /// Default value: 0. Value range: [-1, 1]
    public func iconColorSaturation(_ constant: Double) -> Self {
        with(self, setter(\.iconColorSaturation, .constant(constant)))
    }

    /// Transition property for `iconColorSaturation`
    public func iconColorSaturationTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.iconColorSaturationTransition, transition))
    }

    /// Increase or reduce the saturation of the symbol icon.
    /// Default value: 0. Value range: [-1, 1]
    public func iconColorSaturation(_ expression: Exp) -> Self {
        with(self, setter(\.iconColorSaturation, .expression(expression)))
    }

    /// Controls the intensity of light emitted on the source features.
    /// Default value: 1. Minimum value: 0. The unit of iconEmissiveStrength is in intensity.
    public func iconEmissiveStrength(_ constant: Double) -> Self {
        with(self, setter(\.iconEmissiveStrength, .constant(constant)))
    }

    /// Transition property for `iconEmissiveStrength`
    public func iconEmissiveStrengthTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.iconEmissiveStrengthTransition, transition))
    }

    /// Controls the intensity of light emitted on the source features.
    /// Default value: 1. Minimum value: 0. The unit of iconEmissiveStrength is in intensity.
    public func iconEmissiveStrength(_ expression: Exp) -> Self {
        with(self, setter(\.iconEmissiveStrength, .expression(expression)))
    }

    /// Fade out the halo towards the outside.
    /// Default value: 0. Minimum value: 0. The unit of iconHaloBlur is in pixels.
    public func iconHaloBlur(_ constant: Double) -> Self {
        with(self, setter(\.iconHaloBlur, .constant(constant)))
    }

    /// Transition property for `iconHaloBlur`
    public func iconHaloBlurTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.iconHaloBlurTransition, transition))
    }

    /// Fade out the halo towards the outside.
    /// Default value: 0. Minimum value: 0. The unit of iconHaloBlur is in pixels.
    public func iconHaloBlur(_ expression: Exp) -> Self {
        with(self, setter(\.iconHaloBlur, .expression(expression)))
    }

    /// The color of the icon's halo. Icon halos can only be used with [SDF icons](/help/troubleshooting/using-recolorable-images-in-mapbox-maps/).
    /// Default value: "rgba(0, 0, 0, 0)".
    public func iconHaloColor(_ constant: StyleColor) -> Self {
        with(self, setter(\.iconHaloColor, .constant(constant)))
    }

    /// The color of the icon's halo. Icon halos can only be used with [SDF icons](/help/troubleshooting/using-recolorable-images-in-mapbox-maps/).
    /// Default value: "rgba(0, 0, 0, 0)".
    public func iconHaloColor(_ color: UIColor) -> Self {
        with(self, setter(\.iconHaloColor, .constant(StyleColor(color))))
    }

    /// Transition property for `iconHaloColor`
    public func iconHaloColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.iconHaloColorTransition, transition))
    }

    /// The color of the icon's halo. Icon halos can only be used with [SDF icons](/help/troubleshooting/using-recolorable-images-in-mapbox-maps/).
    /// Default value: "rgba(0, 0, 0, 0)".
    public func iconHaloColor(_ expression: Exp) -> Self {
        with(self, setter(\.iconHaloColor, .expression(expression)))
    }

    /// This property defines whether the `iconHaloColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func iconHaloColorUseTheme(_ useTheme: ColorUseTheme) -> Self {
        with(self, setter(\.iconHaloColorUseTheme, .constant(useTheme)))
    }

    /// This property defines whether the `iconHaloColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func iconHaloColorUseTheme(_ expression: Exp) -> Self {
        with(self, setter(\.iconHaloColorUseTheme, .expression(expression)))
    }

    /// Distance of halo to the icon outline.
    /// Default value: 0. Minimum value: 0. The unit of iconHaloWidth is in pixels.
    public func iconHaloWidth(_ constant: Double) -> Self {
        with(self, setter(\.iconHaloWidth, .constant(constant)))
    }

    /// Transition property for `iconHaloWidth`
    public func iconHaloWidthTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.iconHaloWidthTransition, transition))
    }

    /// Distance of halo to the icon outline.
    /// Default value: 0. Minimum value: 0. The unit of iconHaloWidth is in pixels.
    public func iconHaloWidth(_ expression: Exp) -> Self {
        with(self, setter(\.iconHaloWidth, .expression(expression)))
    }

    /// Controls the transition progress between the image variants of icon-image. Zero means the first variant is used, one is the second, and in between they are blended together.
    /// Default value: 0. Value range: [0, 1]
    public func iconImageCrossFade(_ constant: Double) -> Self {
        with(self, setter(\.iconImageCrossFade, .constant(constant)))
    }

    /// Transition property for `iconImageCrossFade`
    public func iconImageCrossFadeTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.iconImageCrossFadeTransition, transition))
    }

    /// Controls the transition progress between the image variants of icon-image. Zero means the first variant is used, one is the second, and in between they are blended together.
    /// Default value: 0. Value range: [0, 1]
    public func iconImageCrossFade(_ expression: Exp) -> Self {
        with(self, setter(\.iconImageCrossFade, .expression(expression)))
    }

    /// The opacity at which the icon will be drawn in case of being depth occluded. Absent value means full occlusion against terrain only.
    /// Default value: 0. Value range: [0, 1]
    public func iconOcclusionOpacity(_ constant: Double) -> Self {
        with(self, setter(\.iconOcclusionOpacity, .constant(constant)))
    }

    /// Transition property for `iconOcclusionOpacity`
    public func iconOcclusionOpacityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.iconOcclusionOpacityTransition, transition))
    }

    /// The opacity at which the icon will be drawn in case of being depth occluded. Absent value means full occlusion against terrain only.
    /// Default value: 0. Value range: [0, 1]
    public func iconOcclusionOpacity(_ expression: Exp) -> Self {
        with(self, setter(\.iconOcclusionOpacity, .expression(expression)))
    }

    /// The opacity at which the icon will be drawn.
    /// Default value: 1. Value range: [0, 1]
    public func iconOpacity(_ constant: Double) -> Self {
        with(self, setter(\.iconOpacity, .constant(constant)))
    }

    /// Transition property for `iconOpacity`
    public func iconOpacityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.iconOpacityTransition, transition))
    }

    /// The opacity at which the icon will be drawn.
    /// Default value: 1. Value range: [0, 1]
    public func iconOpacity(_ expression: Exp) -> Self {
        with(self, setter(\.iconOpacity, .expression(expression)))
    }

    /// Distance that the icon's anchor is moved from its original placement. Positive values indicate right and down, while negative values indicate left and up.
    /// Default value: [0,0]. The unit of iconTranslate is in pixels.
    public func iconTranslate(x: Double, y: Double) -> Self {
        with(self, setter(\.iconTranslate, .constant([x, y])))
    }

    /// Transition property for `iconTranslate`
    public func iconTranslateTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.iconTranslateTransition, transition))
    }

    /// Distance that the icon's anchor is moved from its original placement. Positive values indicate right and down, while negative values indicate left and up.
    /// Default value: [0,0]. The unit of iconTranslate is in pixels.
    public func iconTranslate(_ expression: Exp) -> Self {
        with(self, setter(\.iconTranslate, .expression(expression)))
    }

    /// Controls the frame of reference for `icon-translate`.
    /// Default value: "map".
    public func iconTranslateAnchor(_ constant: IconTranslateAnchor) -> Self {
        with(self, setter(\.iconTranslateAnchor, .constant(constant)))
    }

    /// Controls the frame of reference for `icon-translate`.
    /// Default value: "map".
    public func iconTranslateAnchor(_ expression: Exp) -> Self {
        with(self, setter(\.iconTranslateAnchor, .expression(expression)))
    }

    /// Specifies an uniform elevation from the ground, in meters.
    /// Default value: 0. Minimum value: 0.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func symbolZOffset(_ constant: Double) -> Self {
        with(self, setter(\.symbolZOffset, .constant(constant)))
    }

    /// Transition property for `symbolZOffset`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func symbolZOffsetTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.symbolZOffsetTransition, transition))
    }

    /// Specifies an uniform elevation from the ground, in meters.
    /// Default value: 0. Minimum value: 0.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func symbolZOffset(_ expression: Exp) -> Self {
        with(self, setter(\.symbolZOffset, .expression(expression)))
    }

    /// The color with which the text will be drawn.
    /// Default value: "#000000".
    public func textColor(_ constant: StyleColor) -> Self {
        with(self, setter(\.textColor, .constant(constant)))
    }

    /// The color with which the text will be drawn.
    /// Default value: "#000000".
    public func textColor(_ color: UIColor) -> Self {
        with(self, setter(\.textColor, .constant(StyleColor(color))))
    }

    /// Transition property for `textColor`
    public func textColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.textColorTransition, transition))
    }

    /// The color with which the text will be drawn.
    /// Default value: "#000000".
    public func textColor(_ expression: Exp) -> Self {
        with(self, setter(\.textColor, .expression(expression)))
    }

    /// This property defines whether the `textColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func textColorUseTheme(_ useTheme: ColorUseTheme) -> Self {
        with(self, setter(\.textColorUseTheme, .constant(useTheme)))
    }

    /// This property defines whether the `textColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func textColorUseTheme(_ expression: Exp) -> Self {
        with(self, setter(\.textColorUseTheme, .expression(expression)))
    }

    /// Controls the intensity of light emitted on the source features.
    /// Default value: 1. Minimum value: 0. The unit of textEmissiveStrength is in intensity.
    public func textEmissiveStrength(_ constant: Double) -> Self {
        with(self, setter(\.textEmissiveStrength, .constant(constant)))
    }

    /// Transition property for `textEmissiveStrength`
    public func textEmissiveStrengthTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.textEmissiveStrengthTransition, transition))
    }

    /// Controls the intensity of light emitted on the source features.
    /// Default value: 1. Minimum value: 0. The unit of textEmissiveStrength is in intensity.
    public func textEmissiveStrength(_ expression: Exp) -> Self {
        with(self, setter(\.textEmissiveStrength, .expression(expression)))
    }

    /// The halo's fadeout distance towards the outside.
    /// Default value: 0. Minimum value: 0. The unit of textHaloBlur is in pixels.
    public func textHaloBlur(_ constant: Double) -> Self {
        with(self, setter(\.textHaloBlur, .constant(constant)))
    }

    /// Transition property for `textHaloBlur`
    public func textHaloBlurTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.textHaloBlurTransition, transition))
    }

    /// The halo's fadeout distance towards the outside.
    /// Default value: 0. Minimum value: 0. The unit of textHaloBlur is in pixels.
    public func textHaloBlur(_ expression: Exp) -> Self {
        with(self, setter(\.textHaloBlur, .expression(expression)))
    }

    /// The color of the text's halo, which helps it stand out from backgrounds.
    /// Default value: "rgba(0, 0, 0, 0)".
    public func textHaloColor(_ constant: StyleColor) -> Self {
        with(self, setter(\.textHaloColor, .constant(constant)))
    }

    /// The color of the text's halo, which helps it stand out from backgrounds.
    /// Default value: "rgba(0, 0, 0, 0)".
    public func textHaloColor(_ color: UIColor) -> Self {
        with(self, setter(\.textHaloColor, .constant(StyleColor(color))))
    }

    /// Transition property for `textHaloColor`
    public func textHaloColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.textHaloColorTransition, transition))
    }

    /// The color of the text's halo, which helps it stand out from backgrounds.
    /// Default value: "rgba(0, 0, 0, 0)".
    public func textHaloColor(_ expression: Exp) -> Self {
        with(self, setter(\.textHaloColor, .expression(expression)))
    }

    /// This property defines whether the `textHaloColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func textHaloColorUseTheme(_ useTheme: ColorUseTheme) -> Self {
        with(self, setter(\.textHaloColorUseTheme, .constant(useTheme)))
    }

    /// This property defines whether the `textHaloColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func textHaloColorUseTheme(_ expression: Exp) -> Self {
        with(self, setter(\.textHaloColorUseTheme, .expression(expression)))
    }

    /// Distance of halo to the font outline. Max text halo width is 1/4 of the font-size.
    /// Default value: 0. Minimum value: 0. The unit of textHaloWidth is in pixels.
    public func textHaloWidth(_ constant: Double) -> Self {
        with(self, setter(\.textHaloWidth, .constant(constant)))
    }

    /// Transition property for `textHaloWidth`
    public func textHaloWidthTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.textHaloWidthTransition, transition))
    }

    /// Distance of halo to the font outline. Max text halo width is 1/4 of the font-size.
    /// Default value: 0. Minimum value: 0. The unit of textHaloWidth is in pixels.
    public func textHaloWidth(_ expression: Exp) -> Self {
        with(self, setter(\.textHaloWidth, .expression(expression)))
    }

    /// The opacity at which the text will be drawn in case of being depth occluded. Absent value means full occlusion against terrain only.
    /// Default value: 0. Value range: [0, 1]
    public func textOcclusionOpacity(_ constant: Double) -> Self {
        with(self, setter(\.textOcclusionOpacity, .constant(constant)))
    }

    /// Transition property for `textOcclusionOpacity`
    public func textOcclusionOpacityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.textOcclusionOpacityTransition, transition))
    }

    /// The opacity at which the text will be drawn in case of being depth occluded. Absent value means full occlusion against terrain only.
    /// Default value: 0. Value range: [0, 1]
    public func textOcclusionOpacity(_ expression: Exp) -> Self {
        with(self, setter(\.textOcclusionOpacity, .expression(expression)))
    }

    /// The opacity at which the text will be drawn.
    /// Default value: 1. Value range: [0, 1]
    public func textOpacity(_ constant: Double) -> Self {
        with(self, setter(\.textOpacity, .constant(constant)))
    }

    /// Transition property for `textOpacity`
    public func textOpacityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.textOpacityTransition, transition))
    }

    /// The opacity at which the text will be drawn.
    /// Default value: 1. Value range: [0, 1]
    public func textOpacity(_ expression: Exp) -> Self {
        with(self, setter(\.textOpacity, .expression(expression)))
    }

    /// Distance that the text's anchor is moved from its original placement. Positive values indicate right and down, while negative values indicate left and up.
    /// Default value: [0,0]. The unit of textTranslate is in pixels.
    public func textTranslate(x: Double, y: Double) -> Self {
        with(self, setter(\.textTranslate, .constant([x, y])))
    }

    /// Transition property for `textTranslate`
    public func textTranslateTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.textTranslateTransition, transition))
    }

    /// Distance that the text's anchor is moved from its original placement. Positive values indicate right and down, while negative values indicate left and up.
    /// Default value: [0,0]. The unit of textTranslate is in pixels.
    public func textTranslate(_ expression: Exp) -> Self {
        with(self, setter(\.textTranslate, .expression(expression)))
    }

    /// Controls the frame of reference for `text-translate`.
    /// Default value: "map".
    public func textTranslateAnchor(_ constant: TextTranslateAnchor) -> Self {
        with(self, setter(\.textTranslateAnchor, .constant(constant)))
    }

    /// Controls the frame of reference for `text-translate`.
    /// Default value: "map".
    public func textTranslateAnchor(_ expression: Exp) -> Self {
        with(self, setter(\.textTranslateAnchor, .expression(expression)))
    }
}

extension SymbolLayer: MapStyleContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        node.mount(MountedLayer(layer: self))
    }
}

// End of generated file.
