// This file is generated

/// Displays a group of ``PointAnnotation``s.
///
/// When multiple annotation grouped, they render by a single layer. This makes annotations more performant and
/// allows to modify group-specific parameters.  For example, you can create clustering with ``clusterOptions(_:)`` or define layer slot with ``slot(_:)``.
///
/// - Note: `PointAnnotationGroup` is a SwiftUI analog to ``PointAnnotationManager``.
///
/// The group can be created with dynamic data, or static data. When first method is used, you specify array of identified data and provide a closure that creates a ``PointAnnotation`` from that data, similar to ``ForEvery``:
///
/// ```swift
/// Map {
///   PointAnnotationGroup(favorites) { favorite in
///     PointAnnotation(coordinate: favorite.coordinate)
///       .image(named: "star")
///   }
///   .clusterOptions(ClusterOptions(...))
///   .slot(.top)
/// }
/// ```
///
/// When the number of annotations is static, you use static that groups one or more annotations:
///
/// ```swift
/// Map {
///     PointAnnotationGroup {
///         PointAnnotation(coordinate: startCoordinate)
///             .image(named: "start-icon")
///         PointAnnotation(coordinate: endCoordinate)
///             .image(named: "end-icon")
///     }
///     .slot(.top)
/// }
/// ```
import UIKit

public struct PointAnnotationGroup<Data: RandomAccessCollection, ID: Hashable> {
    let annotations: [(ID, PointAnnotation)]

    /// Creates a group that identifies data by given key path.
    ///
    /// - Parameters:
    ///     - data: Collection of data.
    ///     - id: Data identifier key path.
    ///     - content: A closure that creates annotation for a given data item.
    public init(_ data: Data, id: KeyPath<Data.Element, ID>, content: @escaping (Data.Element) -> PointAnnotation) {
        annotations = data.map { element in
            (element[keyPath: id], content(element))
        }
    }

    /// Creates a group from identifiable data.
    ///
    /// - Parameters:
    ///     - data: Collection of identifiable data.
    ///     - content: A closure that creates annotation for a given data item.
    public init(_ data: Data, content: @escaping (Data.Element) -> PointAnnotation) where Data.Element: Identifiable, Data.Element.ID == ID {
        self.init(data, id: \.id, content: content)
    }

    /// Creates static group.
    ///
    /// - Parameters:
    ///     - content: A builder closure that creates annotations.
    public init(@ArrayBuilder<PointAnnotation> content: @escaping () -> [PointAnnotation?])
        where Data == [(Int, PointAnnotation)], ID == Int {

        let annotations = content()
            .enumerated()
            .compactMap { $0.element == nil ? nil : ($0.offset, $0.element!) }
        self.init(annotations, id: \.0, content: \.1)
    }

    private func updateProperties(manager: PointAnnotationManager) {
        assign(manager, \.iconAllowOverlap, value: iconAllowOverlap)
        assign(manager, \.iconAnchor, value: iconAnchor)
        assign(manager, \.iconIgnorePlacement, value: iconIgnorePlacement)
        assign(manager, \.iconImage, value: iconImage)
        assign(manager, \.iconKeepUpright, value: iconKeepUpright)
        assign(manager, \.iconOffset, value: iconOffset)
        assign(manager, \.iconOptional, value: iconOptional)
        assign(manager, \.iconPadding, value: iconPadding)
        assign(manager, \.iconPitchAlignment, value: iconPitchAlignment)
        assign(manager, \.iconRotate, value: iconRotate)
        assign(manager, \.iconRotationAlignment, value: iconRotationAlignment)
        assign(manager, \.iconSize, value: iconSize)
        assign(manager, \.iconSizeScaleRange, value: iconSizeScaleRange)
        assign(manager, \.iconTextFit, value: iconTextFit)
        assign(manager, \.iconTextFitPadding, value: iconTextFitPadding)
        assign(manager, \.symbolAvoidEdges, value: symbolAvoidEdges)
        assign(manager, \.symbolElevationReference, value: symbolElevationReference)
        assign(manager, \.symbolPlacement, value: symbolPlacement)
        assign(manager, \.symbolSortKey, value: symbolSortKey)
        assign(manager, \.symbolSpacing, value: symbolSpacing)
        assign(manager, \.symbolZElevate, value: symbolZElevate)
        assign(manager, \.symbolZOrder, value: symbolZOrder)
        assign(manager, \.textAllowOverlap, value: textAllowOverlap)
        assign(manager, \.textAnchor, value: textAnchor)
        assign(manager, \.textField, value: textField)
        assign(manager, \.textFont, value: textFont)
        assign(manager, \.textIgnorePlacement, value: textIgnorePlacement)
        assign(manager, \.textJustify, value: textJustify)
        assign(manager, \.textKeepUpright, value: textKeepUpright)
        assign(manager, \.textLetterSpacing, value: textLetterSpacing)
        assign(manager, \.textLineHeight, value: textLineHeight)
        assign(manager, \.textMaxAngle, value: textMaxAngle)
        assign(manager, \.textMaxWidth, value: textMaxWidth)
        assign(manager, \.textOffset, value: textOffset)
        assign(manager, \.textOptional, value: textOptional)
        assign(manager, \.textPadding, value: textPadding)
        assign(manager, \.textPitchAlignment, value: textPitchAlignment)
        assign(manager, \.textRadialOffset, value: textRadialOffset)
        assign(manager, \.textRotate, value: textRotate)
        assign(manager, \.textRotationAlignment, value: textRotationAlignment)
        assign(manager, \.textSize, value: textSize)
        assign(manager, \.textSizeScaleRange, value: textSizeScaleRange)
        assign(manager, \.textTransform, value: textTransform)
        assign(manager, \.textVariableAnchor, value: textVariableAnchor)
        assign(manager, \.textWritingMode, value: textWritingMode)
        assign(manager, \.iconColor, value: iconColor)
        assign(manager, \.iconColorSaturation, value: iconColorSaturation)
        assign(manager, \.iconEmissiveStrength, value: iconEmissiveStrength)
        assign(manager, \.iconHaloBlur, value: iconHaloBlur)
        assign(manager, \.iconHaloColor, value: iconHaloColor)
        assign(manager, \.iconHaloWidth, value: iconHaloWidth)
        assign(manager, \.iconImageCrossFade, value: iconImageCrossFade)
        assign(manager, \.iconOcclusionOpacity, value: iconOcclusionOpacity)
        assign(manager, \.iconOpacity, value: iconOpacity)
        assign(manager, \.iconTranslate, value: iconTranslate)
        assign(manager, \.iconTranslateAnchor, value: iconTranslateAnchor)
        assign(manager, \.symbolZOffset, value: symbolZOffset)
        assign(manager, \.textColor, value: textColor)
        assign(manager, \.textEmissiveStrength, value: textEmissiveStrength)
        assign(manager, \.textHaloBlur, value: textHaloBlur)
        assign(manager, \.textHaloColor, value: textHaloColor)
        assign(manager, \.textHaloWidth, value: textHaloWidth)
        assign(manager, \.textOcclusionOpacity, value: textOcclusionOpacity)
        assign(manager, \.textOpacity, value: textOpacity)
        assign(manager, \.textTranslate, value: textTranslate)
        assign(manager, \.textTranslateAnchor, value: textTranslateAnchor)
        assign(manager, \.slot, value: slot)
        assign(manager, \.iconOcclusionOpacity, value: iconOcclusionOpacity)
        assign(manager, \.textOcclusionOpacity, value: textOcclusionOpacity)

        manager.onClusterTap = onClusterTap
        manager.onClusterLongPress = onClusterLongPress
        manager.tapRadius = tapRadius
        manager.longPressRadius = longPressRadius
    }

    // MARK: - Common layer properties

    private var iconAllowOverlap: Bool?
    /// If true, the icon will be visible even if it collides with other previously drawn symbols.
    /// Default value: false.
    public func iconAllowOverlap(_ newValue: Bool) -> Self {
        with(self, setter(\.iconAllowOverlap, newValue))
    }

    private var iconAnchor: IconAnchor?
    /// Part of the icon placed closest to the anchor.
    /// Default value: "center".
    public func iconAnchor(_ newValue: IconAnchor) -> Self {
        with(self, setter(\.iconAnchor, newValue))
    }

    private var iconIgnorePlacement: Bool?
    /// If true, other symbols can be visible even if they collide with the icon.
    /// Default value: false.
    public func iconIgnorePlacement(_ newValue: Bool) -> Self {
        with(self, setter(\.iconIgnorePlacement, newValue))
    }

    private var iconImage: String?
    /// Name of image in sprite to use for drawing an image background.
    public func iconImage(_ newValue: String) -> Self {
        with(self, setter(\.iconImage, newValue))
    }

    private var iconKeepUpright: Bool?
    /// If true, the icon may be flipped to prevent it from being rendered upside-down.
    /// Default value: false.
    public func iconKeepUpright(_ newValue: Bool) -> Self {
        with(self, setter(\.iconKeepUpright, newValue))
    }

    private var iconOffset: [Double]?
    /// Offset distance of icon from its anchor. Positive values indicate right and down, while negative values indicate left and up. Each component is multiplied by the value of `icon-size` to obtain the final offset in pixels. When combined with `icon-rotate` the offset will be as if the rotated direction was up.
    /// Default value: [0,0].
    public func iconOffset(x: Double, y: Double) -> Self {
        with(self, setter(\.iconOffset, [x, y]))
    }

    private var iconOptional: Bool?
    /// If true, text will display without their corresponding icons when the icon collides with other symbols and the text does not.
    /// Default value: false.
    public func iconOptional(_ newValue: Bool) -> Self {
        with(self, setter(\.iconOptional, newValue))
    }

    private var iconPadding: Double?
    /// Size of the additional area around the icon bounding box used for detecting symbol collisions.
    /// Default value: 2. Minimum value: 0. The unit of iconPadding is in pixels.
    public func iconPadding(_ newValue: Double) -> Self {
        with(self, setter(\.iconPadding, newValue))
    }

    private var iconPitchAlignment: IconPitchAlignment?
    /// Orientation of icon when map is pitched.
    /// Default value: "auto".
    public func iconPitchAlignment(_ newValue: IconPitchAlignment) -> Self {
        with(self, setter(\.iconPitchAlignment, newValue))
    }

    private var iconRotate: Double?
    /// Rotates the icon clockwise.
    /// Default value: 0. The unit of iconRotate is in degrees.
    public func iconRotate(_ newValue: Double) -> Self {
        with(self, setter(\.iconRotate, newValue))
    }

    private var iconRotationAlignment: IconRotationAlignment?
    /// In combination with `symbol-placement`, determines the rotation behavior of icons.
    /// Default value: "auto".
    public func iconRotationAlignment(_ newValue: IconRotationAlignment) -> Self {
        with(self, setter(\.iconRotationAlignment, newValue))
    }

    private var iconSize: Double?
    /// Scales the original size of the icon by the provided factor. The new pixel size of the image will be the original pixel size multiplied by `icon-size`. 1 is the original size; 3 triples the size of the image.
    /// Default value: 1. Minimum value: 0. The unit of iconSize is in factor of the original icon size.
    public func iconSize(_ newValue: Double) -> Self {
        with(self, setter(\.iconSize, newValue))
    }

    private var iconSizeScaleRange: [Double]?
    /// Defines the minimum and maximum scaling factors for icon related properties like `icon-size`, `icon-halo-width`, `icon-halo-blur`
    /// Default value: [0.8,2]. Value range: [0.1, 10]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func iconSizeScaleRange(min: Double, max: Double) -> Self {
        with(self, setter(\.iconSizeScaleRange, [min, max]))
    }

    private var iconTextFit: IconTextFit?
    /// Scales the icon to fit around the associated text.
    /// Default value: "none".
    public func iconTextFit(_ newValue: IconTextFit) -> Self {
        with(self, setter(\.iconTextFit, newValue))
    }

    private var iconTextFitPadding: [Double]?
    /// Size of the additional area added to dimensions determined by `icon-text-fit`, in clockwise order: top, right, bottom, left.
    /// Default value: [0,0,0,0]. The unit of iconTextFitPadding is in pixels.
    public func iconTextFitPadding(_ padding: UIEdgeInsets) -> Self {
        with(self, setter(\.iconTextFitPadding, [padding.top, padding.right, padding.bottom, padding.left]))
    }

    private var symbolAvoidEdges: Bool?
    /// If true, the symbols will not cross tile edges to avoid mutual collisions. Recommended in layers that don't have enough padding in the vector tile to prevent collisions, or if it is a point symbol layer placed after a line symbol layer. When using a client that supports global collision detection, like Mapbox GL JS version 0.42.0 or greater, enabling this property is not needed to prevent clipped labels at tile boundaries.
    /// Default value: false.
    public func symbolAvoidEdges(_ newValue: Bool) -> Self {
        with(self, setter(\.symbolAvoidEdges, newValue))
    }

    private var symbolElevationReference: SymbolElevationReference?
    /// Selects the base of symbol-elevation.
    /// Default value: "ground".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func symbolElevationReference(_ newValue: SymbolElevationReference) -> Self {
        with(self, setter(\.symbolElevationReference, newValue))
    }

    private var symbolPlacement: SymbolPlacement?
    /// Label placement relative to its geometry.
    /// Default value: "point".
    public func symbolPlacement(_ newValue: SymbolPlacement) -> Self {
        with(self, setter(\.symbolPlacement, newValue))
    }

    private var symbolSortKey: Double?
    /// Sorts features in ascending order based on this value. Features with lower sort keys are drawn and placed first. When `icon-allow-overlap` or `text-allow-overlap` is `false`, features with a lower sort key will have priority during placement. When `icon-allow-overlap` or `text-allow-overlap` is set to `true`, features with a higher sort key will overlap over features with a lower sort key.
    public func symbolSortKey(_ newValue: Double) -> Self {
        with(self, setter(\.symbolSortKey, newValue))
    }

    private var symbolSpacing: Double?
    /// Distance between two symbol anchors.
    /// Default value: 250. Minimum value: 1. The unit of symbolSpacing is in pixels.
    public func symbolSpacing(_ newValue: Double) -> Self {
        with(self, setter(\.symbolSpacing, newValue))
    }

    private var symbolZElevate: Bool?
    /// Position symbol on buildings (both fill extrusions and models) rooftops. In order to have minimal impact on performance, this is supported only when `fill-extrusion-height` is not zoom-dependent and remains unchanged. For fading in buildings when zooming in, fill-extrusion-vertical-scale should be used and symbols would raise with building rooftops. Symbols are sorted by elevation, except in cases when `viewport-y` sorting or `symbol-sort-key` are applied.
    /// Default value: false.
    public func symbolZElevate(_ newValue: Bool) -> Self {
        with(self, setter(\.symbolZElevate, newValue))
    }

    private var symbolZOrder: SymbolZOrder?
    /// Determines whether overlapping symbols in the same layer are rendered in the order that they appear in the data source or by their y-position relative to the viewport. To control the order and prioritization of symbols otherwise, use `symbol-sort-key`.
    /// Default value: "auto".
    public func symbolZOrder(_ newValue: SymbolZOrder) -> Self {
        with(self, setter(\.symbolZOrder, newValue))
    }

    private var textAllowOverlap: Bool?
    /// If true, the text will be visible even if it collides with other previously drawn symbols.
    /// Default value: false.
    public func textAllowOverlap(_ newValue: Bool) -> Self {
        with(self, setter(\.textAllowOverlap, newValue))
    }

    private var textAnchor: TextAnchor?
    /// Part of the text placed closest to the anchor.
    /// Default value: "center".
    public func textAnchor(_ newValue: TextAnchor) -> Self {
        with(self, setter(\.textAnchor, newValue))
    }

    private var textField: String?
    /// Value to use for a text label. If a plain `string` is provided, it will be treated as a `formatted` with default/inherited formatting options. SDF images are not supported in formatted text and will be ignored.
    /// Default value: "".
    public func textField(_ newValue: String) -> Self {
        with(self, setter(\.textField, newValue))
    }

    private var textFont: [String]?
    /// Font stack to use for displaying text.
    public func textFont(_ newValue: [String]) -> Self {
        with(self, setter(\.textFont, newValue))
    }

    private var textIgnorePlacement: Bool?
    /// If true, other symbols can be visible even if they collide with the text.
    /// Default value: false.
    public func textIgnorePlacement(_ newValue: Bool) -> Self {
        with(self, setter(\.textIgnorePlacement, newValue))
    }

    private var textJustify: TextJustify?
    /// Text justification options.
    /// Default value: "center".
    public func textJustify(_ newValue: TextJustify) -> Self {
        with(self, setter(\.textJustify, newValue))
    }

    private var textKeepUpright: Bool?
    /// If true, the text may be flipped vertically to prevent it from being rendered upside-down.
    /// Default value: true.
    public func textKeepUpright(_ newValue: Bool) -> Self {
        with(self, setter(\.textKeepUpright, newValue))
    }

    private var textLetterSpacing: Double?
    /// Text tracking amount.
    /// Default value: 0. The unit of textLetterSpacing is in ems.
    public func textLetterSpacing(_ newValue: Double) -> Self {
        with(self, setter(\.textLetterSpacing, newValue))
    }

    private var textLineHeight: Double?
    /// Text leading value for multi-line text.
    /// Default value: 1.2. The unit of textLineHeight is in ems.
    public func textLineHeight(_ newValue: Double) -> Self {
        with(self, setter(\.textLineHeight, newValue))
    }

    private var textMaxAngle: Double?
    /// Maximum angle change between adjacent characters.
    /// Default value: 45. The unit of textMaxAngle is in degrees.
    public func textMaxAngle(_ newValue: Double) -> Self {
        with(self, setter(\.textMaxAngle, newValue))
    }

    private var textMaxWidth: Double?
    /// The maximum line width for text wrapping.
    /// Default value: 10. Minimum value: 0. The unit of textMaxWidth is in ems.
    public func textMaxWidth(_ newValue: Double) -> Self {
        with(self, setter(\.textMaxWidth, newValue))
    }

    private var textOffset: [Double]?
    /// Offset distance of text from its anchor. Positive values indicate right and down, while negative values indicate left and up. If used with text-variable-anchor, input values will be taken as absolute values. Offsets along the x- and y-axis will be applied automatically based on the anchor position.
    /// Default value: [0,0]. The unit of textOffset is in ems.
    public func textOffset(x: Double, y: Double) -> Self {
        with(self, setter(\.textOffset, [x, y]))
    }

    private var textOptional: Bool?
    /// If true, icons will display without their corresponding text when the text collides with other symbols and the icon does not.
    /// Default value: false.
    public func textOptional(_ newValue: Bool) -> Self {
        with(self, setter(\.textOptional, newValue))
    }

    private var textPadding: Double?
    /// Size of the additional area around the text bounding box used for detecting symbol collisions.
    /// Default value: 2. Minimum value: 0. The unit of textPadding is in pixels.
    public func textPadding(_ newValue: Double) -> Self {
        with(self, setter(\.textPadding, newValue))
    }

    private var textPitchAlignment: TextPitchAlignment?
    /// Orientation of text when map is pitched.
    /// Default value: "auto".
    public func textPitchAlignment(_ newValue: TextPitchAlignment) -> Self {
        with(self, setter(\.textPitchAlignment, newValue))
    }

    private var textRadialOffset: Double?
    /// Radial offset of text, in the direction of the symbol's anchor. Useful in combination with `text-variable-anchor`, which defaults to using the two-dimensional `text-offset` if present.
    /// Default value: 0. The unit of textRadialOffset is in ems.
    public func textRadialOffset(_ newValue: Double) -> Self {
        with(self, setter(\.textRadialOffset, newValue))
    }

    private var textRotate: Double?
    /// Rotates the text clockwise.
    /// Default value: 0. The unit of textRotate is in degrees.
    public func textRotate(_ newValue: Double) -> Self {
        with(self, setter(\.textRotate, newValue))
    }

    private var textRotationAlignment: TextRotationAlignment?
    /// In combination with `symbol-placement`, determines the rotation behavior of the individual glyphs forming the text.
    /// Default value: "auto".
    public func textRotationAlignment(_ newValue: TextRotationAlignment) -> Self {
        with(self, setter(\.textRotationAlignment, newValue))
    }

    private var textSize: Double?
    /// Font size.
    /// Default value: 16. Minimum value: 0. The unit of textSize is in pixels.
    public func textSize(_ newValue: Double) -> Self {
        with(self, setter(\.textSize, newValue))
    }

    private var textSizeScaleRange: [Double]?
    /// Defines the minimum and maximum scaling factors for text related properties like `text-size`, `text-max-width`, `text-halo-width`, `font-size`
    /// Default value: [0.8,2]. Value range: [0.1, 10]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func textSizeScaleRange(min: Double, max: Double) -> Self {
        with(self, setter(\.textSizeScaleRange, [min, max]))
    }

    private var textTransform: TextTransform?
    /// Specifies how to capitalize text, similar to the CSS `text-transform` property.
    /// Default value: "none".
    public func textTransform(_ newValue: TextTransform) -> Self {
        with(self, setter(\.textTransform, newValue))
    }

    private var textVariableAnchor: [TextAnchor]?
    /// To increase the chance of placing high-priority labels on the map, you can provide an array of `text-anchor` locations: the renderer will attempt to place the label at each location, in order, before moving onto the next label. Use `text-justify: auto` to choose justification based on anchor position. To apply an offset, use the `text-radial-offset` or the two-dimensional `text-offset`.
    public func textVariableAnchor(_ newValue: [TextAnchor]) -> Self {
        with(self, setter(\.textVariableAnchor, newValue))
    }

    private var textWritingMode: [TextWritingMode]?
    /// The property allows control over a symbol's orientation. Note that the property values act as a hint, so that a symbol whose language doesn’t support the provided orientation will be laid out in its natural orientation. Example: English point symbol will be rendered horizontally even if array value contains single 'vertical' enum value. For symbol with point placement, the order of elements in an array define priority order for the placement of an orientation variant. For symbol with line placement, the default text writing mode is either ['horizontal', 'vertical'] or ['vertical', 'horizontal'], the order doesn't affect the placement.
    public func textWritingMode(_ newValue: [TextWritingMode]) -> Self {
        with(self, setter(\.textWritingMode, newValue))
    }

    private var iconColor: StyleColor?
    /// The color of the icon. This can only be used with [SDF icons](/help/troubleshooting/using-recolorable-images-in-mapbox-maps/).
    /// Default value: "#000000".
    public func iconColor(_ color: UIColor) -> Self {
        with(self, setter(\.iconColor, StyleColor(color)))
    }

    private var iconColorSaturation: Double?
    /// Increase or reduce the saturation of the symbol icon.
    /// Default value: 0. Value range: [-1, 1]
    public func iconColorSaturation(_ newValue: Double) -> Self {
        with(self, setter(\.iconColorSaturation, newValue))
    }

    private var iconEmissiveStrength: Double?
    /// Controls the intensity of light emitted on the source features.
    /// Default value: 1. Minimum value: 0. The unit of iconEmissiveStrength is in intensity.
    public func iconEmissiveStrength(_ newValue: Double) -> Self {
        with(self, setter(\.iconEmissiveStrength, newValue))
    }

    private var iconHaloBlur: Double?
    /// Fade out the halo towards the outside.
    /// Default value: 0. Minimum value: 0. The unit of iconHaloBlur is in pixels.
    public func iconHaloBlur(_ newValue: Double) -> Self {
        with(self, setter(\.iconHaloBlur, newValue))
    }

    private var iconHaloColor: StyleColor?
    /// The color of the icon's halo. Icon halos can only be used with [SDF icons](/help/troubleshooting/using-recolorable-images-in-mapbox-maps/).
    /// Default value: "rgba(0, 0, 0, 0)".
    public func iconHaloColor(_ color: UIColor) -> Self {
        with(self, setter(\.iconHaloColor, StyleColor(color)))
    }

    private var iconHaloWidth: Double?
    /// Distance of halo to the icon outline.
    /// Default value: 0. Minimum value: 0. The unit of iconHaloWidth is in pixels.
    public func iconHaloWidth(_ newValue: Double) -> Self {
        with(self, setter(\.iconHaloWidth, newValue))
    }

    private var iconImageCrossFade: Double?
    /// Controls the transition progress between the image variants of icon-image. Zero means the first variant is used, one is the second, and in between they are blended together.
    /// Default value: 0. Value range: [0, 1]
    public func iconImageCrossFade(_ newValue: Double) -> Self {
        with(self, setter(\.iconImageCrossFade, newValue))
    }

    private var iconOcclusionOpacity: Double?
    /// The opacity at which the icon will be drawn in case of being depth occluded. Absent value means full occlusion against terrain only.
    /// Default value: 0. Value range: [0, 1]
    public func iconOcclusionOpacity(_ newValue: Double) -> Self {
        with(self, setter(\.iconOcclusionOpacity, newValue))
    }

    private var iconOpacity: Double?
    /// The opacity at which the icon will be drawn.
    /// Default value: 1. Value range: [0, 1]
    public func iconOpacity(_ newValue: Double) -> Self {
        with(self, setter(\.iconOpacity, newValue))
    }

    private var iconTranslate: [Double]?
    /// Distance that the icon's anchor is moved from its original placement. Positive values indicate right and down, while negative values indicate left and up.
    /// Default value: [0,0]. The unit of iconTranslate is in pixels.
    public func iconTranslate(x: Double, y: Double) -> Self {
        with(self, setter(\.iconTranslate, [x, y]))
    }

    private var iconTranslateAnchor: IconTranslateAnchor?
    /// Controls the frame of reference for `icon-translate`.
    /// Default value: "map".
    public func iconTranslateAnchor(_ newValue: IconTranslateAnchor) -> Self {
        with(self, setter(\.iconTranslateAnchor, newValue))
    }

    private var symbolZOffset: Double?
    /// Specifies an uniform elevation from the ground, in meters.
    /// Default value: 0. Minimum value: 0.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func symbolZOffset(_ newValue: Double) -> Self {
        with(self, setter(\.symbolZOffset, newValue))
    }

    private var textColor: StyleColor?
    /// The color with which the text will be drawn.
    /// Default value: "#000000".
    public func textColor(_ color: UIColor) -> Self {
        with(self, setter(\.textColor, StyleColor(color)))
    }

    private var textEmissiveStrength: Double?
    /// Controls the intensity of light emitted on the source features.
    /// Default value: 1. Minimum value: 0. The unit of textEmissiveStrength is in intensity.
    public func textEmissiveStrength(_ newValue: Double) -> Self {
        with(self, setter(\.textEmissiveStrength, newValue))
    }

    private var textHaloBlur: Double?
    /// The halo's fadeout distance towards the outside.
    /// Default value: 0. Minimum value: 0. The unit of textHaloBlur is in pixels.
    public func textHaloBlur(_ newValue: Double) -> Self {
        with(self, setter(\.textHaloBlur, newValue))
    }

    private var textHaloColor: StyleColor?
    /// The color of the text's halo, which helps it stand out from backgrounds.
    /// Default value: "rgba(0, 0, 0, 0)".
    public func textHaloColor(_ color: UIColor) -> Self {
        with(self, setter(\.textHaloColor, StyleColor(color)))
    }

    private var textHaloWidth: Double?
    /// Distance of halo to the font outline. Max text halo width is 1/4 of the font-size.
    /// Default value: 0. Minimum value: 0. The unit of textHaloWidth is in pixels.
    public func textHaloWidth(_ newValue: Double) -> Self {
        with(self, setter(\.textHaloWidth, newValue))
    }

    private var textOcclusionOpacity: Double?
    /// The opacity at which the text will be drawn in case of being depth occluded. Absent value means full occlusion against terrain only.
    /// Default value: 0. Value range: [0, 1]
    public func textOcclusionOpacity(_ newValue: Double) -> Self {
        with(self, setter(\.textOcclusionOpacity, newValue))
    }

    private var textOpacity: Double?
    /// The opacity at which the text will be drawn.
    /// Default value: 1. Value range: [0, 1]
    public func textOpacity(_ newValue: Double) -> Self {
        with(self, setter(\.textOpacity, newValue))
    }

    private var textTranslate: [Double]?
    /// Distance that the text's anchor is moved from its original placement. Positive values indicate right and down, while negative values indicate left and up.
    /// Default value: [0,0]. The unit of textTranslate is in pixels.
    public func textTranslate(x: Double, y: Double) -> Self {
        with(self, setter(\.textTranslate, [x, y]))
    }

    private var textTranslateAnchor: TextTranslateAnchor?
    /// Controls the frame of reference for `text-translate`.
    /// Default value: "map".
    public func textTranslateAnchor(_ newValue: TextTranslateAnchor) -> Self {
        with(self, setter(\.textTranslateAnchor, newValue))
    }

    private var slot: String?
    /// Slot for the underlying layer.
    ///
    /// Use this property to position the annotations relative to other map features if you use Mapbox Standard Style.
    /// See <doc:Migrate-to-v11##21-The-Mapbox-Standard-Style> for more info.
    @available(*, deprecated, message: "Use Slot type instead of string")
    public func slot(_ newValue: String) -> Self {
        with(self, setter(\.slot, newValue))
    }

    /// Slot for the underlying layer.
    ///
    /// Use this property to position the annotations relative to other map features if you use Mapbox Standard Style.
    /// See <doc:Migrate-to-v11##21-The-Mapbox-Standard-Style> for more info.
    public func slot(_ newValue: Slot?) -> Self {
        with(self, setter(\.slot, newValue?.rawValue))
    }

    private var clusterOptions: ClusterOptions?

    /// Defines point annotation clustering options.
    ///
    /// - NOTE: Clustering options aren't updatable. Only the first value passed to this function set will take effect.
    public func clusterOptions(_ newValue: ClusterOptions) -> Self {
        with(self, setter(\.clusterOptions, newValue))
    }

    private var onClusterTap: ((AnnotationClusterGestureContext) -> Void)?

    /// Adds a handler for tap gesture on annotations cluster.
    ///
    /// The handler should return `true` if the gesture is handled, or `false` to propagate it to the annotations or layers below.
    ///
    /// - Parameters:
    ///   - action: A handler for tap gesture on cluster.
    public func onClusterTapGesture(perform action: @escaping (AnnotationClusterGestureContext) -> Void) -> Self {
        with(self, setter(\.onClusterTap, action))
    }

    private var onClusterLongPress: ((AnnotationClusterGestureContext) -> Void)?

    /// Adds a handler for long press gesture on annotation cluster formed by annotations from the group.
    ///
    /// The handler should return `true` if the gesture is handled, or `false` to propagate it to the annotations or layers below.
    ///
    /// - Parameters:
    ///   - action: A handler for long press gesture on cluster.
    public func onClusterLongPressGesture(perform action: @escaping (AnnotationClusterGestureContext) -> Void) -> Self {
        with(self, setter(\.onClusterLongPress, action))
    }

    private var layerId: String?

    /// Specifies identifier for underlying implementation layer.
    ///
    /// Use the identifier to create view annotations bound the annotations from the group.
    /// For more information, see the ``MapViewAnnotation/init(layerId:featureId:content:)``.
    public func layerId(_ layerId: String) -> Self {
        with(self, setter(\.layerId, layerId))
    }

    var tapRadius: CGFloat?
    var longPressRadius: CGFloat?

    /// A custom tappable area radius. Default value is 0.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func tapRadius(_ radius: CGFloat? = nil) -> Self {
        with(self, setter(\.tapRadius, radius))
    }

    /// A custom tappable area radius. Default value is 0.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func longPressRadius(_ radius: CGFloat? = nil) -> Self {
        with(self, setter(\.longPressRadius, radius))
    }
}

extension PointAnnotationGroup: MapContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        let group = MountedAnnotationGroup(
            layerId: layerId ?? node.id.stringId,
            clusterOptions: clusterOptions,
            annotations: annotations,
            updateProperties: updateProperties
        )
        node.mount(group)
    }
}

// End of generated file.
