// This file is generated.
import UIKit

public struct PointAnnotation: Annotation, Equatable {

    /// Identifier for this annotation
    internal(set) public var id: String

    /// The geometry backing this annotation
    public var geometry: Geometry {
        return .point(point)
    }

    /// The point backing this annotation
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
    public var tapHandler: ((MapContentGestureContext) -> Bool)? {
        get { gestureHandlers.tap }
        set { gestureHandlers.tap = newValue }
    }

    /// Handles long press gesture on this annotation.
    ///
    /// Should return `true` if the gesture is handled, or `false` to propagate it to the annotations or layers below.
    public var longPressHandler: ((MapContentGestureContext) -> Bool)? {
        get { gestureHandlers.longPress }
        set { gestureHandlers.longPress = newValue }
    }

    /// Properties associated with the annotation
    public var userInfo: [String: Any]? {
        get { _userInfo?.rawValue as? [String: Any] }
        set {
            let newValue = newValue ?? [:]
            _userInfo = JSONObject(rawValue: newValue)
        }
    }
    private var _userInfo: JSONObject?

    internal var layerProperties: [String: Any] {
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
        properties["icon-emissive-strength"] = iconEmissiveStrength
        properties["icon-halo-blur"] = iconHaloBlur
        properties["icon-halo-color"] = iconHaloColor?.rawValue
        properties["icon-halo-width"] = iconHaloWidth
        properties["icon-image-cross-fade"] = iconImageCrossFade
        properties["icon-opacity"] = iconOpacity
        properties["text-color"] = textColor?.rawValue
        properties["text-emissive-strength"] = textEmissiveStrength
        properties["text-halo-blur"] = textHaloBlur
        properties["text-halo-color"] = textHaloColor?.rawValue
        properties["text-halo-width"] = textHaloWidth
        properties["text-opacity"] = textOpacity
        return properties
    }

    internal var feature: Feature {
        var feature = Feature(geometry: geometry)
        feature.identifier = .string(id)
        var properties = JSONObject()
        properties["layerProperties"] = JSONValue(rawValue: layerProperties)
        if let _userInfo {
            properties["userInfo"] = .object(_userInfo)
        }
        feature.properties = properties
        return feature
    }

    private var gestureHandlers = AnnotationGestureHandlers()

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
    public init(id: String = UUID().uuidString, coordinate: CLLocationCoordinate2D, isSelected: Bool = false, isDraggable: Bool = false) {
        let point = Point(coordinate)
        self.init(id: id, point: point, isSelected: isSelected, isDraggable: isDraggable)
    }

    // MARK: - Style Properties -

    /// Part of the icon placed closest to the anchor.
    public var iconAnchor: IconAnchor?

    /// Name of image in sprite to use for drawing an image background.
    public var iconImage: String?

    /// Offset distance of icon from its anchor. Positive values indicate right and down, while negative values indicate left and up. Each component is multiplied by the value of `icon-size` to obtain the final offset in pixels. When combined with `icon-rotate` the offset will be as if the rotated direction was up.
    public var iconOffset: [Double]?

    /// Rotates the icon clockwise.
    public var iconRotate: Double?

    /// Scales the original size of the icon by the provided factor. The new pixel size of the image will be the original pixel size multiplied by `icon-size`. 1 is the original size; 3 triples the size of the image.
    public var iconSize: Double?

    /// Scales the icon to fit around the associated text.
    public var iconTextFit: IconTextFit?

    /// Size of the additional area added to dimensions determined by `icon-text-fit`, in clockwise order: top, right, bottom, left.
    public var iconTextFitPadding: [Double]?

    /// Sorts features in ascending order based on this value. Features with lower sort keys are drawn and placed first. When `icon-allow-overlap` or `text-allow-overlap` is `false`, features with a lower sort key will have priority during placement. When `icon-allow-overlap` or `text-allow-overlap` is set to `true`, features with a higher sort key will overlap over features with a lower sort key.
    public var symbolSortKey: Double?

    /// Part of the text placed closest to the anchor.
    public var textAnchor: TextAnchor?

    /// Value to use for a text label. If a plain `string` is provided, it will be treated as a `formatted` with default/inherited formatting options. SDF images are not supported in formatted text and will be ignored.
    public var textField: String?

    /// Text justification options.
    public var textJustify: TextJustify?

    /// Text tracking amount.
    public var textLetterSpacing: Double?

    /// Text leading value for multi-line text.
    public var textLineHeight: Double?

    /// The maximum line width for text wrapping.
    public var textMaxWidth: Double?

    /// Offset distance of text from its anchor. Positive values indicate right and down, while negative values indicate left and up. If used with text-variable-anchor, input values will be taken as absolute values. Offsets along the x- and y-axis will be applied automatically based on the anchor position.
    public var textOffset: [Double]?

    /// Radial offset of text, in the direction of the symbol's anchor. Useful in combination with `text-variable-anchor`, which defaults to using the two-dimensional `text-offset` if present.
    public var textRadialOffset: Double?

    /// Rotates the text clockwise.
    public var textRotate: Double?

    /// Font size.
    public var textSize: Double?

    /// Specifies how to capitalize text, similar to the CSS `text-transform` property.
    public var textTransform: TextTransform?

    /// The color of the icon. This can only be used with [SDF icons](/help/troubleshooting/using-recolorable-images-in-mapbox-maps/).
    public var iconColor: StyleColor?

    /// Controls the intensity of light emitted on the source features. This property works only with 3D light, i.e. when `lights` root property is defined.
    public var iconEmissiveStrength: Double?

    /// Fade out the halo towards the outside.
    public var iconHaloBlur: Double?

    /// The color of the icon's halo. Icon halos can only be used with [SDF icons](/help/troubleshooting/using-recolorable-images-in-mapbox-maps/).
    public var iconHaloColor: StyleColor?

    /// Distance of halo to the icon outline.
    public var iconHaloWidth: Double?

    /// Controls the transition progress between the image variants of icon-image. Zero means the first variant is used, one is the second, and in between they are blended together.
    public var iconImageCrossFade: Double?

    /// The opacity at which the icon will be drawn.
    public var iconOpacity: Double?

    /// The color with which the text will be drawn.
    public var textColor: StyleColor?

    /// Controls the intensity of light emitted on the source features. This property works only with 3D light, i.e. when `lights` root property is defined.
    public var textEmissiveStrength: Double?

    /// The halo's fadeout distance towards the outside.
    public var textHaloBlur: Double?

    /// The color of the text's halo, which helps it stand out from backgrounds.
    public var textHaloColor: StyleColor?

    /// Distance of halo to the font outline. Max text halo width is 1/4 of the font-size.
    public var textHaloWidth: Double?

    /// The opacity at which the text will be drawn.
    public var textOpacity: Double?

    // MARK: - Image Convenience -

    public var image: Image? {
        didSet {
            self.iconImage = image?.name
        }
    }
}

#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
@_spi(Experimental) extension PointAnnotation {

    /// Part of the icon placed closest to the anchor.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func iconAnchor(_ newValue: IconAnchor) -> Self {
        with(self, setter(\.iconAnchor, newValue))
    }

    /// Name of image in sprite to use for drawing an image background.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func iconImage(_ newValue: String) -> Self {
        with(self, setter(\.iconImage, newValue))
    }

    /// Offset distance of icon from its anchor. Positive values indicate right and down, while negative values indicate left and up. Each component is multiplied by the value of `icon-size` to obtain the final offset in pixels. When combined with `icon-rotate` the offset will be as if the rotated direction was up.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func iconOffset(_ newValue: [Double]) -> Self {
        with(self, setter(\.iconOffset, newValue))
    }

    /// Rotates the icon clockwise.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func iconRotate(_ newValue: Double) -> Self {
        with(self, setter(\.iconRotate, newValue))
    }

    /// Scales the original size of the icon by the provided factor. The new pixel size of the image will be the original pixel size multiplied by `icon-size`. 1 is the original size; 3 triples the size of the image.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func iconSize(_ newValue: Double) -> Self {
        with(self, setter(\.iconSize, newValue))
    }

    /// Scales the icon to fit around the associated text.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func iconTextFit(_ newValue: IconTextFit) -> Self {
        with(self, setter(\.iconTextFit, newValue))
    }

    /// Size of the additional area added to dimensions determined by `icon-text-fit`, in clockwise order: top, right, bottom, left.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func iconTextFitPadding(_ newValue: [Double]) -> Self {
        with(self, setter(\.iconTextFitPadding, newValue))
    }

    /// Sorts features in ascending order based on this value. Features with lower sort keys are drawn and placed first. When `icon-allow-overlap` or `text-allow-overlap` is `false`, features with a lower sort key will have priority during placement. When `icon-allow-overlap` or `text-allow-overlap` is set to `true`, features with a higher sort key will overlap over features with a lower sort key.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func symbolSortKey(_ newValue: Double) -> Self {
        with(self, setter(\.symbolSortKey, newValue))
    }

    /// Part of the text placed closest to the anchor.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func textAnchor(_ newValue: TextAnchor) -> Self {
        with(self, setter(\.textAnchor, newValue))
    }

    /// Value to use for a text label. If a plain `string` is provided, it will be treated as a `formatted` with default/inherited formatting options. SDF images are not supported in formatted text and will be ignored.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func textField(_ newValue: String) -> Self {
        with(self, setter(\.textField, newValue))
    }

    /// Text justification options.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func textJustify(_ newValue: TextJustify) -> Self {
        with(self, setter(\.textJustify, newValue))
    }

    /// Text tracking amount.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func textLetterSpacing(_ newValue: Double) -> Self {
        with(self, setter(\.textLetterSpacing, newValue))
    }

    /// Text leading value for multi-line text.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func textLineHeight(_ newValue: Double) -> Self {
        with(self, setter(\.textLineHeight, newValue))
    }

    /// The maximum line width for text wrapping.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func textMaxWidth(_ newValue: Double) -> Self {
        with(self, setter(\.textMaxWidth, newValue))
    }

    /// Offset distance of text from its anchor. Positive values indicate right and down, while negative values indicate left and up. If used with text-variable-anchor, input values will be taken as absolute values. Offsets along the x- and y-axis will be applied automatically based on the anchor position.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func textOffset(_ newValue: [Double]) -> Self {
        with(self, setter(\.textOffset, newValue))
    }

    /// Radial offset of text, in the direction of the symbol's anchor. Useful in combination with `text-variable-anchor`, which defaults to using the two-dimensional `text-offset` if present.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func textRadialOffset(_ newValue: Double) -> Self {
        with(self, setter(\.textRadialOffset, newValue))
    }

    /// Rotates the text clockwise.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func textRotate(_ newValue: Double) -> Self {
        with(self, setter(\.textRotate, newValue))
    }

    /// Font size.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func textSize(_ newValue: Double) -> Self {
        with(self, setter(\.textSize, newValue))
    }

    /// Specifies how to capitalize text, similar to the CSS `text-transform` property.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func textTransform(_ newValue: TextTransform) -> Self {
        with(self, setter(\.textTransform, newValue))
    }

    /// The color of the icon. This can only be used with [SDF icons](/help/troubleshooting/using-recolorable-images-in-mapbox-maps/).
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func iconColor(_ newValue: StyleColor) -> Self {
        with(self, setter(\.iconColor, newValue))
    }

    /// Controls the intensity of light emitted on the source features. This property works only with 3D light, i.e. when `lights` root property is defined.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func iconEmissiveStrength(_ newValue: Double) -> Self {
        with(self, setter(\.iconEmissiveStrength, newValue))
    }

    /// Fade out the halo towards the outside.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func iconHaloBlur(_ newValue: Double) -> Self {
        with(self, setter(\.iconHaloBlur, newValue))
    }

    /// The color of the icon's halo. Icon halos can only be used with [SDF icons](/help/troubleshooting/using-recolorable-images-in-mapbox-maps/).
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func iconHaloColor(_ newValue: StyleColor) -> Self {
        with(self, setter(\.iconHaloColor, newValue))
    }

    /// Distance of halo to the icon outline.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func iconHaloWidth(_ newValue: Double) -> Self {
        with(self, setter(\.iconHaloWidth, newValue))
    }

    /// Controls the transition progress between the image variants of icon-image. Zero means the first variant is used, one is the second, and in between they are blended together.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func iconImageCrossFade(_ newValue: Double) -> Self {
        with(self, setter(\.iconImageCrossFade, newValue))
    }

    /// The opacity at which the icon will be drawn.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func iconOpacity(_ newValue: Double) -> Self {
        with(self, setter(\.iconOpacity, newValue))
    }

    /// The color with which the text will be drawn.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func textColor(_ newValue: StyleColor) -> Self {
        with(self, setter(\.textColor, newValue))
    }

    /// Controls the intensity of light emitted on the source features. This property works only with 3D light, i.e. when `lights` root property is defined.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func textEmissiveStrength(_ newValue: Double) -> Self {
        with(self, setter(\.textEmissiveStrength, newValue))
    }

    /// The halo's fadeout distance towards the outside.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func textHaloBlur(_ newValue: Double) -> Self {
        with(self, setter(\.textHaloBlur, newValue))
    }

    /// The color of the text's halo, which helps it stand out from backgrounds.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func textHaloColor(_ newValue: StyleColor) -> Self {
        with(self, setter(\.textHaloColor, newValue))
    }

    /// Distance of halo to the font outline. Max text halo width is 1/4 of the font-size.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func textHaloWidth(_ newValue: Double) -> Self {
        with(self, setter(\.textHaloWidth, newValue))
    }

    /// The opacity at which the text will be drawn.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func textOpacity(_ newValue: Double) -> Self {
        with(self, setter(\.textOpacity, newValue))
    }

    /// Sets icon image.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func image(_ image: Image?) -> Self {
        with(self, setter(\.image, image))
    }

    /// Sets named image as icon.
    public func image(named name: String) -> Self {
        let uiImage = UIImage(named: name)!
        return image(Image(image: uiImage, name: name))
    }

    /// Adds a handler for tap gesture on current annotation.
    ///
    /// The handler should return `true` if the gesture is handled, or `false` to propagate it to the annotations or layers below.
    ///
    /// - Parameters:
    ///   - handler: A handler for tap gesture.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func onTapGesture(handler: @escaping (MapContentGestureContext) -> Bool) -> Self {
        with(self, setter(\.tapHandler, handler))
    }

    /// Adds a handler for tap gesture on current annotation.
    ///
    /// - Parameters:
    ///   - handler: A handler for tap gesture.
    #if swift(>=5.8)
    @_documentation(visibility: public)
#endif
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
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func onLongPressGesture(handler: @escaping (MapContentGestureContext) -> Bool) -> Self {
        with(self, setter(\.longPressHandler, handler))
    }

    /// Adds a handler for long press gesture on current annotation.
    ///
    /// - Parameters:
    ///   - handler: A handler for long press gesture.
    #if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func onLongPressGesture(handler: @escaping () -> Void) -> Self {
        onLongPressGesture { _ in
            handler()
            return true
        }
    }
}

// End of generated file.
