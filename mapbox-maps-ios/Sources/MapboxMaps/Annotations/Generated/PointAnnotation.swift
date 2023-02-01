// This file is generated.
import Foundation

public struct PointAnnotation: Annotation {

    /// Identifier for this annotation
    public let id: String

    /// The geometry backing this annotation
    public var geometry: Geometry {
        return .point(point)
    }

    /// The point backing this annotation
    public var point: Point

    /// Properties associated with the annotation
    public var userInfo: [String: Any]?

    /// Storage for layer properties
    internal var layerProperties: [String: Any] = [:]

    /// Toggles the annotation's selection state.
    /// If the annotation is deselected, it becomes selected.
    /// If the annotation is selected, it becomes deselected.
    public var isSelected: Bool = false

    /// Property to determine whether annotation can be manually moved around map
    public var isDraggable: Bool = false

    internal var feature: Feature {
        var feature = Feature(geometry: geometry)
        feature.identifier = .string(id)
        var properties = JSONObject()
        properties["layerProperties"] = JSONValue(rawValue: layerProperties)
        if let userInfoValue = userInfo.flatMap(JSONValue.init(rawValue:)) {
            properties["userInfo"] = userInfoValue
        }
        feature.properties = properties
        return feature
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
    public init(id: String = UUID().uuidString, coordinate: CLLocationCoordinate2D, isSelected: Bool = false, isDraggable: Bool = false) {
        let point = Point(coordinate)
        self.init(id: id, point: point, isSelected: isSelected, isDraggable: isDraggable)
    }

    // MARK: - Style Properties -

    /// Part of the icon placed closest to the anchor.
    public var iconAnchor: IconAnchor? {
        get {
            return layerProperties["icon-anchor"].flatMap { $0 as? String }.flatMap(IconAnchor.init(rawValue:))
        }
        set {
            layerProperties["icon-anchor"] = newValue?.rawValue
        }
    }

    /// Name of image in sprite to use for drawing an image background.
    public var iconImage: String? {
        get {
            return layerProperties["icon-image"] as? String
        }
        set {
            layerProperties["icon-image"] = newValue
        }
    }

    /// Offset distance of icon from its anchor. Positive values indicate right and down, while negative values indicate left and up. Each component is multiplied by the value of `icon-size` to obtain the final offset in pixels. When combined with `icon-rotate` the offset will be as if the rotated direction was up.
    public var iconOffset: [Double]? {
        get {
            return layerProperties["icon-offset"] as? [Double]
        }
        set {
            layerProperties["icon-offset"] = newValue
        }
    }

    /// Rotates the icon clockwise.
    public var iconRotate: Double? {
        get {
            return layerProperties["icon-rotate"] as? Double
        }
        set {
            layerProperties["icon-rotate"] = newValue
        }
    }

    /// Scales the original size of the icon by the provided factor. The new pixel size of the image will be the original pixel size multiplied by `icon-size`. 1 is the original size; 3 triples the size of the image.
    public var iconSize: Double? {
        get {
            return layerProperties["icon-size"] as? Double
        }
        set {
            layerProperties["icon-size"] = newValue
        }
    }

    /// Sorts features in ascending order based on this value. Features with lower sort keys are drawn and placed first.  When `icon-allow-overlap` or `text-allow-overlap` is `false`, features with a lower sort key will have priority during placement. When `icon-allow-overlap` or `text-allow-overlap` is set to `true`, features with a higher sort key will overlap over features with a lower sort key.
    public var symbolSortKey: Double? {
        get {
            return layerProperties["symbol-sort-key"] as? Double
        }
        set {
            layerProperties["symbol-sort-key"] = newValue
        }
    }

    /// Part of the text placed closest to the anchor.
    public var textAnchor: TextAnchor? {
        get {
            return layerProperties["text-anchor"].flatMap { $0 as? String }.flatMap(TextAnchor.init(rawValue:))
        }
        set {
            layerProperties["text-anchor"] = newValue?.rawValue
        }
    }

    /// Value to use for a text label. If a plain `string` is provided, it will be treated as a `formatted` with default/inherited formatting options. SDF images are not supported in formatted text and will be ignored.
    public var textField: String? {
        get {
            return layerProperties["text-field"] as? String
        }
        set {
            layerProperties["text-field"] = newValue
        }
    }

    /// Text justification options.
    public var textJustify: TextJustify? {
        get {
            return layerProperties["text-justify"].flatMap { $0 as? String }.flatMap(TextJustify.init(rawValue:))
        }
        set {
            layerProperties["text-justify"] = newValue?.rawValue
        }
    }

    /// Text tracking amount.
    public var textLetterSpacing: Double? {
        get {
            return layerProperties["text-letter-spacing"] as? Double
        }
        set {
            layerProperties["text-letter-spacing"] = newValue
        }
    }

    /// Text leading value for multi-line text.
    public var textLineHeight: Double? {
        get {
            return layerProperties["text-line-height"] as? Double
        }
        set {
            layerProperties["text-line-height"] = newValue
        }
    }

    /// The maximum line width for text wrapping.
    public var textMaxWidth: Double? {
        get {
            return layerProperties["text-max-width"] as? Double
        }
        set {
            layerProperties["text-max-width"] = newValue
        }
    }

    /// Offset distance of text from its anchor. Positive values indicate right and down, while negative values indicate left and up. If used with text-variable-anchor, input values will be taken as absolute values. Offsets along the x- and y-axis will be applied automatically based on the anchor position.
    public var textOffset: [Double]? {
        get {
            return layerProperties["text-offset"] as? [Double]
        }
        set {
            layerProperties["text-offset"] = newValue
        }
    }

    /// Radial offset of text, in the direction of the symbol's anchor. Useful in combination with `text-variable-anchor`, which defaults to using the two-dimensional `text-offset` if present.
    public var textRadialOffset: Double? {
        get {
            return layerProperties["text-radial-offset"] as? Double
        }
        set {
            layerProperties["text-radial-offset"] = newValue
        }
    }

    /// Rotates the text clockwise.
    public var textRotate: Double? {
        get {
            return layerProperties["text-rotate"] as? Double
        }
        set {
            layerProperties["text-rotate"] = newValue
        }
    }

    /// Font size.
    public var textSize: Double? {
        get {
            return layerProperties["text-size"] as? Double
        }
        set {
            layerProperties["text-size"] = newValue
        }
    }

    /// Specifies how to capitalize text, similar to the CSS `text-transform` property.
    public var textTransform: TextTransform? {
        get {
            return layerProperties["text-transform"].flatMap { $0 as? String }.flatMap(TextTransform.init(rawValue:))
        }
        set {
            layerProperties["text-transform"] = newValue?.rawValue
        }
    }

    /// The color of the icon. This can only be used with [SDF icons](/help/troubleshooting/using-recolorable-images-in-mapbox-maps/).
    public var iconColor: StyleColor? {
        get {
            return layerProperties["icon-color"].flatMap { $0 as? String }.flatMap(StyleColor.init(rgbaString:))
        }
        set {
            layerProperties["icon-color"] = newValue?.rgbaString
        }
    }

    /// Fade out the halo towards the outside.
    public var iconHaloBlur: Double? {
        get {
            return layerProperties["icon-halo-blur"] as? Double
        }
        set {
            layerProperties["icon-halo-blur"] = newValue
        }
    }

    /// The color of the icon's halo. Icon halos can only be used with [SDF icons](/help/troubleshooting/using-recolorable-images-in-mapbox-maps/).
    public var iconHaloColor: StyleColor? {
        get {
            return layerProperties["icon-halo-color"].flatMap { $0 as? String }.flatMap(StyleColor.init(rgbaString:))
        }
        set {
            layerProperties["icon-halo-color"] = newValue?.rgbaString
        }
    }

    /// Distance of halo to the icon outline.
    public var iconHaloWidth: Double? {
        get {
            return layerProperties["icon-halo-width"] as? Double
        }
        set {
            layerProperties["icon-halo-width"] = newValue
        }
    }

    /// The opacity at which the icon will be drawn.
    public var iconOpacity: Double? {
        get {
            return layerProperties["icon-opacity"] as? Double
        }
        set {
            layerProperties["icon-opacity"] = newValue
        }
    }

    /// The color with which the text will be drawn.
    public var textColor: StyleColor? {
        get {
            return layerProperties["text-color"].flatMap { $0 as? String }.flatMap(StyleColor.init(rgbaString:))
        }
        set {
            layerProperties["text-color"] = newValue?.rgbaString
        }
    }

    /// The halo's fadeout distance towards the outside.
    public var textHaloBlur: Double? {
        get {
            return layerProperties["text-halo-blur"] as? Double
        }
        set {
            layerProperties["text-halo-blur"] = newValue
        }
    }

    /// The color of the text's halo, which helps it stand out from backgrounds.
    public var textHaloColor: StyleColor? {
        get {
            return layerProperties["text-halo-color"].flatMap { $0 as? String }.flatMap(StyleColor.init(rgbaString:))
        }
        set {
            layerProperties["text-halo-color"] = newValue?.rgbaString
        }
    }

    /// Distance of halo to the font outline. Max text halo width is 1/4 of the font-size.
    public var textHaloWidth: Double? {
        get {
            return layerProperties["text-halo-width"] as? Double
        }
        set {
            layerProperties["text-halo-width"] = newValue
        }
    }

    /// The opacity at which the text will be drawn.
    public var textOpacity: Double? {
        get {
            return layerProperties["text-opacity"] as? Double
        }
        set {
            layerProperties["text-opacity"] = newValue
        }
    }

    // MARK: - Image Convenience -

    public var image: Image? {
        didSet {
            self.iconImage = image?.name
        }
    }
}

// End of generated file.
