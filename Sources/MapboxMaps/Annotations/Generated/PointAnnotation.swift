// This file is generated.
import UIKit

public struct PointAnnotation: Annotation, Equatable, AnnotationInternal {
    /// Identifier for this annotation
    internal(set) public var id: String

    /// The geometry backing this annotation
    public var geometry: Geometry { point.geometry }

    /// The Point backing this annotation
    public var point: Point

    /// Toggles the annotation's selection state.
    /// If the annotation is deselected, it becomes selected.
    /// If the annotation is selected, it becomes deselected.
    public var isSelected: Bool = false

    /// Property to determine whether annotation can be manually moved around map
    public var isDraggable: Bool = false

    /// Handles tap gesture on this annotation.
    ///
    /// Should return `true` if the gesture is handled, or `false` to propagate it to the annotations or layers below.
    public var tapHandler: ((InteractionContext) -> Bool)? {
        get { gestureHandlers.value.tap }
        set { gestureHandlers.value.tap = newValue }
    }

    /// Handles long press gesture on this annotation.
    ///
    /// Should return `true` if the gesture is handled, or `false` to propagate it to the annotations or layers below.
    public var longPressHandler: ((InteractionContext) -> Bool)? {
        get { gestureHandlers.value.longPress }
        set { gestureHandlers.value.longPress = newValue }
    }

    /// The handler is invoked when the user begins to drag the annotation.
    ///
    /// The annotation should have `isDraggable` set to `true` to make id draggable.
    ///
    /// - Note: In SwiftUI, draggable annotations are not supported.
    ///
    /// The handler receives the `annotation` and the `context` parameters of the gesture:
    /// - Use the `annotation` inout property to update properties of the annotation.
    /// - The `context` contains position of the gesture.
    /// Return `true` to allow dragging to begin, or `false` to prevent it and propagate the gesture to the map's other annotations or layers.
    public var dragBeginHandler: ((inout PointAnnotation, InteractionContext) -> Bool)? {
        get { gestureHandlers.value.dragBegin }
        set { gestureHandlers.value.dragBegin = newValue }
    }

    /// The handler is invoked when annotation is being dragged.
    ///
    /// The handler receives the `annotation` and the `context` parameters of the gesture:
    /// - Use the `annotation` inout property to update properties of the annotation.
    /// - The `context` contains position of the gesture.
    public var dragChangeHandler: ((inout PointAnnotation, InteractionContext) -> Void)? {
        get { gestureHandlers.value.dragChange }
        set { gestureHandlers.value.dragChange = newValue }
    }

    /// The handler receives the `annotation` and the `context` parameters of the gesture:
    /// - Use the `annotation` inout property to update properties of the annotation.
    /// - The `context` contains position of the gesture.
    public var dragEndHandler: ((inout PointAnnotation, InteractionContext) -> Void)? {
        get { gestureHandlers.value.dragEnd }
        set { gestureHandlers.value.dragEnd = newValue }
    }

    /// JSON convertible properties associated with the annotation, used to enrich Feature GeoJSON `properties["custom_data"]` field.
    public var customData = JSONObject()

    /// Properties associated with the annotation.
    ///
    /// - Note: This property doesn't participate in `Equatable` comparisions and will strip non-JSON values when encoding to Feature GeoJSON.
    @available(*, deprecated, message: "Use customData instead.")
    public var userInfo: [String: Any]? {
        get { _userInfo.value }
        set { _userInfo.value = newValue }
    }

    private var _userInfo: AlwaysEqual<[String: Any]?> = nil
    private var gestureHandlers = AlwaysEqual(value: AnnotationGestureHandlers<PointAnnotation>())

    var layerProperties: [String: Any] {
        var properties: [String: Any] = [:]
        properties["icon-anchor"] = iconAnchor?.rawValue
        properties["icon-image"] = iconImage
        properties["icon-offset"] = iconOffset
        properties["icon-rotate"] = iconRotate
        properties["icon-size"] = iconSize
        properties["icon-text-fit"] = iconTextFit?.rawValue
        properties["icon-text-fit-padding"] = iconTextFitPadding
        properties["symbol-sort-key"] = symbolSortKey
        properties["text-anchor"] = textAnchor?.rawValue
        properties["text-field"] = textField
        properties["text-justify"] = textJustify?.rawValue
        properties["text-letter-spacing"] = textLetterSpacing
        properties["text-line-height"] = textLineHeight
        properties["text-max-width"] = textMaxWidth
        properties["text-offset"] = textOffset
        properties["text-radial-offset"] = textRadialOffset
        properties["text-rotate"] = textRotate
        properties["text-size"] = textSize
        properties["text-transform"] = textTransform?.rawValue
        properties["icon-color"] = iconColor?.rawValue
        properties["icon-color-use-theme"] = iconColorUseTheme?.rawValue
        properties["icon-color-transition"] = iconColorTransition?.asDictionary
        properties["icon-emissive-strength"] = iconEmissiveStrength
        properties["icon-emissive-strength-transition"] = iconEmissiveStrengthTransition?.asDictionary
        properties["icon-halo-blur"] = iconHaloBlur
        properties["icon-halo-blur-transition"] = iconHaloBlurTransition?.asDictionary
        properties["icon-halo-color"] = iconHaloColor?.rawValue
        properties["icon-halo-color-use-theme"] = iconHaloColorUseTheme?.rawValue
        properties["icon-halo-color-transition"] = iconHaloColorTransition?.asDictionary
        properties["icon-halo-width"] = iconHaloWidth
        properties["icon-halo-width-transition"] = iconHaloWidthTransition?.asDictionary
        properties["icon-occlusion-opacity"] = iconOcclusionOpacity
        properties["icon-occlusion-opacity-transition"] = iconOcclusionOpacityTransition?.asDictionary
        properties["icon-opacity"] = iconOpacity
        properties["icon-opacity-transition"] = iconOpacityTransition?.asDictionary
        properties["symbol-z-offset"] = symbolZOffset
        properties["symbol-z-offset-transition"] = symbolZOffsetTransition?.asDictionary
        properties["text-color"] = textColor?.rawValue
        properties["text-color-use-theme"] = textColorUseTheme?.rawValue
        properties["text-color-transition"] = textColorTransition?.asDictionary
        properties["text-emissive-strength"] = textEmissiveStrength
        properties["text-emissive-strength-transition"] = textEmissiveStrengthTransition?.asDictionary
        properties["text-halo-blur"] = textHaloBlur
        properties["text-halo-blur-transition"] = textHaloBlurTransition?.asDictionary
        properties["text-halo-color"] = textHaloColor?.rawValue
        properties["text-halo-color-use-theme"] = textHaloColorUseTheme?.rawValue
        properties["text-halo-color-transition"] = textHaloColorTransition?.asDictionary
        properties["text-halo-width"] = textHaloWidth
        properties["text-halo-width-transition"] = textHaloWidthTransition?.asDictionary
        properties["text-occlusion-opacity"] = textOcclusionOpacity
        properties["text-occlusion-opacity-transition"] = textOcclusionOpacityTransition?.asDictionary
        properties["text-opacity"] = textOpacity
        properties["text-opacity-transition"] = textOpacityTransition?.asDictionary
        return properties
    }

    var feature: Feature {
        var feature = Feature(geometry: geometry)
        feature.identifier = .string(id)
        var properties = JSONObject()
        properties["layerProperties"] = JSONValue(rawValue: layerProperties)
        properties["custom_data"] = .object(customData)
        if let userInfoValue = _userInfo.value.flatMap(JSONValue.init) {
            properties["userInfo"] = userInfoValue
        }
        feature.properties = properties
        return feature
    }

    mutating func drag(translation: CGPoint, in map: MapboxMapProtocol) {
        point = GeometryType.projection(of: point, for: translation, in: map)
    }

    /// Create a point annotation with a `Point` and an optional identifier.
    public init(id: String = UUID().uuidString, point: Point, isSelected: Bool = false, isDraggable: Bool = false) {
        self.id = id
        self.point = point
        self.isSelected = isSelected
        self.isDraggable = isDraggable
    }

    /// Create a point annotation with a coordinate and an optional identifier
    /// - Parameters:
    ///   - id: Optional identifier for this annotation
    ///   - coordinate: Coordinate where this annotation should be rendered
    ///   - isDraggable: Determines whether annotation can be manually moved around map
    ///   - isSelected: Passes the annotation's selection state
    public init(id: String = UUID().uuidString, coordinate: CLLocationCoordinate2D, isSelected: Bool = false, isDraggable: Bool = false) {
        let point = Point(coordinate)
        self.init(id: id, point: point, isSelected: isSelected, isDraggable: isDraggable)
    }

    /// Transition property for `iconImageCrossFade`
    @available(*, deprecated, message: "Use PointAnnotationManager.iconImageCrossFadeTransition instead")
    public var iconImageCrossFadeTransition: StyleTransition? { get { return nil } set { } }

    /// Controls the transition progress between the image variants of icon-image. Zero means the first variant is used, one is the second, and in between they are blended together.
    /// Default value: 0. Value range: [0, 1]
    @available(*, deprecated, message: "Use PointAnnotationManager.iconImageCrossFade instead")
    public var iconImageCrossFade: Double? { get { return nil } set { } }

    // MARK: - Style Properties -

    /// Part of the icon placed closest to the anchor.
    /// Default value: "center".
    public var iconAnchor: IconAnchor?

    /// Name of image in sprite to use for drawing an image background.
    public var iconImage: String?

    /// Offset distance of icon from its anchor. Positive values indicate right and down, while negative values indicate left and up. Each component is multiplied by the value of `icon-size` to obtain the final offset in pixels. When combined with `icon-rotate` the offset will be as if the rotated direction was up.
    /// Default value: [0,0].
    public var iconOffset: [Double]?

    /// Rotates the icon clockwise.
    /// Default value: 0. The unit of iconRotate is in degrees.
    public var iconRotate: Double?

    /// Scales the original size of the icon by the provided factor. The new pixel size of the image will be the original pixel size multiplied by `icon-size`. 1 is the original size; 3 triples the size of the image.
    /// Default value: 1. Minimum value: 0. The unit of iconSize is in factor of the original icon size.
    public var iconSize: Double?

    /// Scales the icon to fit around the associated text.
    /// Default value: "none".
    public var iconTextFit: IconTextFit?

    /// Size of the additional area added to dimensions determined by `icon-text-fit`, in clockwise order: top, right, bottom, left.
    /// Default value: [0,0,0,0]. The unit of iconTextFitPadding is in pixels.
    public var iconTextFitPadding: [Double]?

    /// Sorts features in ascending order based on this value. Features with lower sort keys are drawn and placed first. When `icon-allow-overlap` or `text-allow-overlap` is `false`, features with a lower sort key will have priority during placement. When `icon-allow-overlap` or `text-allow-overlap` is set to `true`, features with a higher sort key will overlap over features with a lower sort key.
    public var symbolSortKey: Double?

    /// Part of the text placed closest to the anchor.
    /// Default value: "center".
    public var textAnchor: TextAnchor?

    /// Value to use for a text label. If a plain `string` is provided, it will be treated as a `formatted` with default/inherited formatting options. SDF images are not supported in formatted text and will be ignored.
    /// Default value: "".
    public var textField: String?

    /// Text justification options.
    /// Default value: "center".
    public var textJustify: TextJustify?

    /// Text tracking amount.
    /// Default value: 0. The unit of textLetterSpacing is in ems.
    public var textLetterSpacing: Double?

    /// Text leading value for multi-line text.
    /// Default value: 1.2. The unit of textLineHeight is in ems.
    public var textLineHeight: Double?

    /// The maximum line width for text wrapping.
    /// Default value: 10. Minimum value: 0. The unit of textMaxWidth is in ems.
    public var textMaxWidth: Double?

    /// Offset distance of text from its anchor. Positive values indicate right and down, while negative values indicate left and up. If used with text-variable-anchor, input values will be taken as absolute values. Offsets along the x- and y-axis will be applied automatically based on the anchor position.
    /// Default value: [0,0]. The unit of textOffset is in ems.
    public var textOffset: [Double]?

    /// Radial offset of text, in the direction of the symbol's anchor. Useful in combination with `text-variable-anchor`, which defaults to using the two-dimensional `text-offset` if present.
    /// Default value: 0. The unit of textRadialOffset is in ems.
    public var textRadialOffset: Double?

    /// Rotates the text clockwise.
    /// Default value: 0. The unit of textRotate is in degrees.
    public var textRotate: Double?

    /// Font size.
    /// Default value: 16. Minimum value: 0. The unit of textSize is in pixels.
    public var textSize: Double?

    /// Specifies how to capitalize text, similar to the CSS `text-transform` property.
    /// Default value: "none".
    public var textTransform: TextTransform?

    /// This property defines whether the `iconColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var iconColorUseTheme: ColorUseTheme?

    /// Transition property for `iconColor`
    public var iconColorTransition: StyleTransition?

    /// The color of the icon. This can only be used with [SDF icons](/help/troubleshooting/using-recolorable-images-in-mapbox-maps/).
    /// Default value: "#000000".
    public var iconColor: StyleColor?

    /// Transition property for `iconEmissiveStrength`
    public var iconEmissiveStrengthTransition: StyleTransition?

    /// Controls the intensity of light emitted on the source features.
    /// Default value: 1. Minimum value: 0. The unit of iconEmissiveStrength is in intensity.
    public var iconEmissiveStrength: Double?

    /// Transition property for `iconHaloBlur`
    public var iconHaloBlurTransition: StyleTransition?

    /// Fade out the halo towards the outside.
    /// Default value: 0. Minimum value: 0. The unit of iconHaloBlur is in pixels.
    public var iconHaloBlur: Double?

    /// This property defines whether the `iconHaloColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var iconHaloColorUseTheme: ColorUseTheme?

    /// Transition property for `iconHaloColor`
    public var iconHaloColorTransition: StyleTransition?

    /// The color of the icon's halo. Icon halos can only be used with [SDF icons](/help/troubleshooting/using-recolorable-images-in-mapbox-maps/).
    /// Default value: "rgba(0, 0, 0, 0)".
    public var iconHaloColor: StyleColor?

    /// Transition property for `iconHaloWidth`
    public var iconHaloWidthTransition: StyleTransition?

    /// Distance of halo to the icon outline.
    /// Default value: 0. Minimum value: 0. The unit of iconHaloWidth is in pixels.
    public var iconHaloWidth: Double?

    /// Transition property for `iconOcclusionOpacity`
    public var iconOcclusionOpacityTransition: StyleTransition?

    /// The opacity at which the icon will be drawn in case of being depth occluded. Absent value means full occlusion against terrain only.
    /// Default value: 0. Value range: [0, 1]
    public var iconOcclusionOpacity: Double?

    /// Transition property for `iconOpacity`
    public var iconOpacityTransition: StyleTransition?

    /// The opacity at which the icon will be drawn.
    /// Default value: 1. Value range: [0, 1]
    public var iconOpacity: Double?

    /// Transition property for `symbolZOffset`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var symbolZOffsetTransition: StyleTransition?

    /// Specifies an uniform elevation from the ground, in meters.
    /// Default value: 0. Minimum value: 0.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var symbolZOffset: Double?

    /// This property defines whether the `textColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var textColorUseTheme: ColorUseTheme?

    /// Transition property for `textColor`
    public var textColorTransition: StyleTransition?

    /// The color with which the text will be drawn.
    /// Default value: "#000000".
    public var textColor: StyleColor?

    /// Transition property for `textEmissiveStrength`
    public var textEmissiveStrengthTransition: StyleTransition?

    /// Controls the intensity of light emitted on the source features.
    /// Default value: 1. Minimum value: 0. The unit of textEmissiveStrength is in intensity.
    public var textEmissiveStrength: Double?

    /// Transition property for `textHaloBlur`
    public var textHaloBlurTransition: StyleTransition?

    /// The halo's fadeout distance towards the outside.
    /// Default value: 0. Minimum value: 0. The unit of textHaloBlur is in pixels.
    public var textHaloBlur: Double?

    /// This property defines whether the `textHaloColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var textHaloColorUseTheme: ColorUseTheme?

    /// Transition property for `textHaloColor`
    public var textHaloColorTransition: StyleTransition?

    /// The color of the text's halo, which helps it stand out from backgrounds.
    /// Default value: "rgba(0, 0, 0, 0)".
    public var textHaloColor: StyleColor?

    /// Transition property for `textHaloWidth`
    public var textHaloWidthTransition: StyleTransition?

    /// Distance of halo to the font outline. Max text halo width is 1/4 of the font-size.
    /// Default value: 0. Minimum value: 0. The unit of textHaloWidth is in pixels.
    public var textHaloWidth: Double?

    /// Transition property for `textOcclusionOpacity`
    public var textOcclusionOpacityTransition: StyleTransition?

    /// The opacity at which the text will be drawn in case of being depth occluded. Absent value means full occlusion against terrain only.
    /// Default value: 0. Value range: [0, 1]
    public var textOcclusionOpacity: Double?

    /// Transition property for `textOpacity`
    public var textOpacityTransition: StyleTransition?

    /// The opacity at which the text will be drawn.
    /// Default value: 1. Value range: [0, 1]
    public var textOpacity: Double?

    // MARK: - Image Convenience -

    public var image: Image? {
        didSet {
            self.iconImage = image?.name
        }
    }
}

extension PointAnnotation {

    /// Adds a handler for tap gesture on current annotation.
    ///
    /// The handler should return `true` if the gesture is handled, or `false` to propagate it to the annotations or layers below.
    ///
    /// - Parameters:
    ///   - handler: A handler for tap gesture.
    public func onTapGesture(handler: @escaping (InteractionContext) -> Bool) -> Self {
        with(self, setter(\.tapHandler, handler))
    }

    /// Adds a handler for tap gesture on current annotation.
    ///
    /// - Parameters:
    ///   - handler: A handler for tap gesture.
    public func onTapGesture(handler: @escaping () -> Void) -> Self {
        onTapGesture { _ in
            handler()
            return true
        }
    }

    /// Adds a handler for long press gesture on current annotation.
    ///
    /// The handler should return `true` if the gesture is handled, or `false` to propagate it to the annotations or layers below.
    ///
    /// - Parameters:
    ///   - handler: A handler for long press gesture.
    public func onLongPressGesture(handler: @escaping (InteractionContext) -> Bool) -> Self {
        with(self, setter(\.longPressHandler, handler))
    }

    /// Adds a handler for long press gesture on current annotation.
    ///
    /// - Parameters:
    ///   - handler: A handler for long press gesture.
    public func onLongPressGesture(handler: @escaping () -> Void) -> Self {
        onLongPressGesture { _ in
            handler()
            return true
        }
    }
}

extension PointAnnotation {
    /// Part of the icon placed closest to the anchor.
    /// Default value: "center".
    public func iconAnchor(_ newValue: IconAnchor) -> Self {
        with(self, setter(\.iconAnchor, newValue))
    }

    /// Name of image in sprite to use for drawing an image background.
    public func iconImage(_ newValue: String) -> Self {
        with(self, setter(\.iconImage, newValue))
    }

    /// Offset distance of icon from its anchor. Positive values indicate right and down, while negative values indicate left and up. Each component is multiplied by the value of `icon-size` to obtain the final offset in pixels. When combined with `icon-rotate` the offset will be as if the rotated direction was up.
    /// Default value: [0,0].
    public func iconOffset(x: Double, y: Double) -> Self {
        with(self, setter(\.iconOffset, [x, y]))
    }

    /// Rotates the icon clockwise.
    /// Default value: 0. The unit of iconRotate is in degrees.
    public func iconRotate(_ newValue: Double) -> Self {
        with(self, setter(\.iconRotate, newValue))
    }

    /// Scales the original size of the icon by the provided factor. The new pixel size of the image will be the original pixel size multiplied by `icon-size`. 1 is the original size; 3 triples the size of the image.
    /// Default value: 1. Minimum value: 0. The unit of iconSize is in factor of the original icon size.
    public func iconSize(_ newValue: Double) -> Self {
        with(self, setter(\.iconSize, newValue))
    }

    /// Scales the icon to fit around the associated text.
    /// Default value: "none".
    public func iconTextFit(_ newValue: IconTextFit) -> Self {
        with(self, setter(\.iconTextFit, newValue))
    }

    /// Size of the additional area added to dimensions determined by `icon-text-fit`, in clockwise order: top, right, bottom, left.
    /// Default value: [0,0,0,0]. The unit of iconTextFitPadding is in pixels.
    public func iconTextFitPadding(_ padding: UIEdgeInsets) -> Self {
        with(self, setter(\.iconTextFitPadding, [padding.top, padding.right, padding.bottom, padding.left]))
    }

    /// Sorts features in ascending order based on this value. Features with lower sort keys are drawn and placed first. When `icon-allow-overlap` or `text-allow-overlap` is `false`, features with a lower sort key will have priority during placement. When `icon-allow-overlap` or `text-allow-overlap` is set to `true`, features with a higher sort key will overlap over features with a lower sort key.
    public func symbolSortKey(_ newValue: Double) -> Self {
        with(self, setter(\.symbolSortKey, newValue))
    }

    /// Part of the text placed closest to the anchor.
    /// Default value: "center".
    public func textAnchor(_ newValue: TextAnchor) -> Self {
        with(self, setter(\.textAnchor, newValue))
    }

    /// Value to use for a text label. If a plain `string` is provided, it will be treated as a `formatted` with default/inherited formatting options. SDF images are not supported in formatted text and will be ignored.
    /// Default value: "".
    public func textField(_ newValue: String) -> Self {
        with(self, setter(\.textField, newValue))
    }

    /// Text justification options.
    /// Default value: "center".
    public func textJustify(_ newValue: TextJustify) -> Self {
        with(self, setter(\.textJustify, newValue))
    }

    /// Text tracking amount.
    /// Default value: 0. The unit of textLetterSpacing is in ems.
    public func textLetterSpacing(_ newValue: Double) -> Self {
        with(self, setter(\.textLetterSpacing, newValue))
    }

    /// Text leading value for multi-line text.
    /// Default value: 1.2. The unit of textLineHeight is in ems.
    public func textLineHeight(_ newValue: Double) -> Self {
        with(self, setter(\.textLineHeight, newValue))
    }

    /// The maximum line width for text wrapping.
    /// Default value: 10. Minimum value: 0. The unit of textMaxWidth is in ems.
    public func textMaxWidth(_ newValue: Double) -> Self {
        with(self, setter(\.textMaxWidth, newValue))
    }

    /// Offset distance of text from its anchor. Positive values indicate right and down, while negative values indicate left and up. If used with text-variable-anchor, input values will be taken as absolute values. Offsets along the x- and y-axis will be applied automatically based on the anchor position.
    /// Default value: [0,0]. The unit of textOffset is in ems.
    public func textOffset(x: Double, y: Double) -> Self {
        with(self, setter(\.textOffset, [x, y]))
    }

    /// Radial offset of text, in the direction of the symbol's anchor. Useful in combination with `text-variable-anchor`, which defaults to using the two-dimensional `text-offset` if present.
    /// Default value: 0. The unit of textRadialOffset is in ems.
    public func textRadialOffset(_ newValue: Double) -> Self {
        with(self, setter(\.textRadialOffset, newValue))
    }

    /// Rotates the text clockwise.
    /// Default value: 0. The unit of textRotate is in degrees.
    public func textRotate(_ newValue: Double) -> Self {
        with(self, setter(\.textRotate, newValue))
    }

    /// Font size.
    /// Default value: 16. Minimum value: 0. The unit of textSize is in pixels.
    public func textSize(_ newValue: Double) -> Self {
        with(self, setter(\.textSize, newValue))
    }

    /// Specifies how to capitalize text, similar to the CSS `text-transform` property.
    /// Default value: "none".
    public func textTransform(_ newValue: TextTransform) -> Self {
        with(self, setter(\.textTransform, newValue))
    }

    /// The color of the icon. This can only be used with [SDF icons](/help/troubleshooting/using-recolorable-images-in-mapbox-maps/).
    /// Default value: "#000000".
    public func iconColor(_ color: UIColor) -> Self {
        with(self, setter(\.iconColor, StyleColor(color)))
    }

    /// This property defines whether the `iconColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func iconColorUseTheme(_ useTheme: ColorUseTheme) -> Self {
        with(self, setter(\.iconColorUseTheme, useTheme))
    }

    /// Transition property for `iconColor`
    public func iconColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.iconColorTransition, transition))
    }

    /// The color of the icon. This can only be used with [SDF icons](/help/troubleshooting/using-recolorable-images-in-mapbox-maps/).
    /// Default value: "#000000".
    public func iconColor(_ newValue: StyleColor) -> Self {
        with(self, setter(\.iconColor, newValue))
    }

    /// Transition property for `iconEmissiveStrength`
    public func iconEmissiveStrengthTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.iconEmissiveStrengthTransition, transition))
    }

    /// Controls the intensity of light emitted on the source features.
    /// Default value: 1. Minimum value: 0. The unit of iconEmissiveStrength is in intensity.
    public func iconEmissiveStrength(_ newValue: Double) -> Self {
        with(self, setter(\.iconEmissiveStrength, newValue))
    }

    /// Transition property for `iconHaloBlur`
    public func iconHaloBlurTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.iconHaloBlurTransition, transition))
    }

    /// Fade out the halo towards the outside.
    /// Default value: 0. Minimum value: 0. The unit of iconHaloBlur is in pixels.
    public func iconHaloBlur(_ newValue: Double) -> Self {
        with(self, setter(\.iconHaloBlur, newValue))
    }

    /// The color of the icon's halo. Icon halos can only be used with [SDF icons](/help/troubleshooting/using-recolorable-images-in-mapbox-maps/).
    /// Default value: "rgba(0, 0, 0, 0)".
    public func iconHaloColor(_ color: UIColor) -> Self {
        with(self, setter(\.iconHaloColor, StyleColor(color)))
    }

    /// This property defines whether the `iconHaloColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func iconHaloColorUseTheme(_ useTheme: ColorUseTheme) -> Self {
        with(self, setter(\.iconHaloColorUseTheme, useTheme))
    }

    /// Transition property for `iconHaloColor`
    public func iconHaloColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.iconHaloColorTransition, transition))
    }

    /// The color of the icon's halo. Icon halos can only be used with [SDF icons](/help/troubleshooting/using-recolorable-images-in-mapbox-maps/).
    /// Default value: "rgba(0, 0, 0, 0)".
    public func iconHaloColor(_ newValue: StyleColor) -> Self {
        with(self, setter(\.iconHaloColor, newValue))
    }

    /// Transition property for `iconHaloWidth`
    public func iconHaloWidthTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.iconHaloWidthTransition, transition))
    }

    /// Distance of halo to the icon outline.
    /// Default value: 0. Minimum value: 0. The unit of iconHaloWidth is in pixels.
    public func iconHaloWidth(_ newValue: Double) -> Self {
        with(self, setter(\.iconHaloWidth, newValue))
    }

    /// Transition property for `iconOcclusionOpacity`
    public func iconOcclusionOpacityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.iconOcclusionOpacityTransition, transition))
    }

    /// The opacity at which the icon will be drawn in case of being depth occluded. Absent value means full occlusion against terrain only.
    /// Default value: 0. Value range: [0, 1]
    public func iconOcclusionOpacity(_ newValue: Double) -> Self {
        with(self, setter(\.iconOcclusionOpacity, newValue))
    }

    /// Transition property for `iconOpacity`
    public func iconOpacityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.iconOpacityTransition, transition))
    }

    /// The opacity at which the icon will be drawn.
    /// Default value: 1. Value range: [0, 1]
    public func iconOpacity(_ newValue: Double) -> Self {
        with(self, setter(\.iconOpacity, newValue))
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
    public func symbolZOffset(_ newValue: Double) -> Self {
        with(self, setter(\.symbolZOffset, newValue))
    }

    /// The color with which the text will be drawn.
    /// Default value: "#000000".
    public func textColor(_ color: UIColor) -> Self {
        with(self, setter(\.textColor, StyleColor(color)))
    }

    /// This property defines whether the `textColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func textColorUseTheme(_ useTheme: ColorUseTheme) -> Self {
        with(self, setter(\.textColorUseTheme, useTheme))
    }

    /// Transition property for `textColor`
    public func textColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.textColorTransition, transition))
    }

    /// The color with which the text will be drawn.
    /// Default value: "#000000".
    public func textColor(_ newValue: StyleColor) -> Self {
        with(self, setter(\.textColor, newValue))
    }

    /// Transition property for `textEmissiveStrength`
    public func textEmissiveStrengthTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.textEmissiveStrengthTransition, transition))
    }

    /// Controls the intensity of light emitted on the source features.
    /// Default value: 1. Minimum value: 0. The unit of textEmissiveStrength is in intensity.
    public func textEmissiveStrength(_ newValue: Double) -> Self {
        with(self, setter(\.textEmissiveStrength, newValue))
    }

    /// Transition property for `textHaloBlur`
    public func textHaloBlurTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.textHaloBlurTransition, transition))
    }

    /// The halo's fadeout distance towards the outside.
    /// Default value: 0. Minimum value: 0. The unit of textHaloBlur is in pixels.
    public func textHaloBlur(_ newValue: Double) -> Self {
        with(self, setter(\.textHaloBlur, newValue))
    }

    /// The color of the text's halo, which helps it stand out from backgrounds.
    /// Default value: "rgba(0, 0, 0, 0)".
    public func textHaloColor(_ color: UIColor) -> Self {
        with(self, setter(\.textHaloColor, StyleColor(color)))
    }

    /// This property defines whether the `textHaloColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func textHaloColorUseTheme(_ useTheme: ColorUseTheme) -> Self {
        with(self, setter(\.textHaloColorUseTheme, useTheme))
    }

    /// Transition property for `textHaloColor`
    public func textHaloColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.textHaloColorTransition, transition))
    }

    /// The color of the text's halo, which helps it stand out from backgrounds.
    /// Default value: "rgba(0, 0, 0, 0)".
    public func textHaloColor(_ newValue: StyleColor) -> Self {
        with(self, setter(\.textHaloColor, newValue))
    }

    /// Transition property for `textHaloWidth`
    public func textHaloWidthTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.textHaloWidthTransition, transition))
    }

    /// Distance of halo to the font outline. Max text halo width is 1/4 of the font-size.
    /// Default value: 0. Minimum value: 0. The unit of textHaloWidth is in pixels.
    public func textHaloWidth(_ newValue: Double) -> Self {
        with(self, setter(\.textHaloWidth, newValue))
    }

    /// Transition property for `textOcclusionOpacity`
    public func textOcclusionOpacityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.textOcclusionOpacityTransition, transition))
    }

    /// The opacity at which the text will be drawn in case of being depth occluded. Absent value means full occlusion against terrain only.
    /// Default value: 0. Value range: [0, 1]
    public func textOcclusionOpacity(_ newValue: Double) -> Self {
        with(self, setter(\.textOcclusionOpacity, newValue))
    }

    /// Transition property for `textOpacity`
    public func textOpacityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.textOpacityTransition, transition))
    }

    /// The opacity at which the text will be drawn.
    /// Default value: 1. Value range: [0, 1]
    public func textOpacity(_ newValue: Double) -> Self {
        with(self, setter(\.textOpacity, newValue))
    }

    /// Sets icon image.
    public func image(_ image: Image?) -> Self {
        with(self, setter(\.image, image))
    }

    /// Sets named image as icon
    public func image(named name: String) -> Self {
        with(self, setter(\.image, Image(image: UIImage(named: name)!, name: name)))
    }
}

extension PointAnnotation: MapContent, PrimitiveMapContent {

    func visit(_ node: MapContentNode) {
        PointAnnotationGroup { self }.visit(node)
    }
}

extension PointAnnotation {
    /// Transition property for `iconImageCrossFade`
    @available(*, deprecated, message: "Use PointAnnotationManager.iconImageCrossFadeTransition instead")
    public func iconImageCrossFadeTransition(_ transition: StyleTransition) -> Self { return self }

    /// Controls the transition progress between the image variants of icon-image. Zero means the first variant is used, one is the second, and in between they are blended together.
    /// Default value: 0. Value range: [0, 1]
    @available(*, deprecated, message: "Use PointAnnotationManager.iconImageCrossFade instead")
    public func iconImageCrossFade(_ newValue: Double) -> Self { return self }
}
// End of generated file.
