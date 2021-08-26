// swiftlint:disable all
// This file is generated.
import Foundation

public struct PointAnnotation: Annotation {

    /// Identifier for this annotation
    public let id: String

    /// The geometry backing this annotation
    public var geometry: Turf.Geometry {
        return .point(point)
    }

    /// The point backing this annotation
    public var point: Turf.Point

    /// Properties associated with the annotation
    public var userInfo: [String: Any]?

    internal private(set) var styles: [String: Any] = [:]

    internal var feature: Turf.Feature {
        var feature = Turf.Feature(geometry: geometry)
        feature.identifier = .string(id)
        var properties = [String: Any?]()
        properties["styles"] = styles
        properties["userInfo"] = userInfo
        feature.properties = properties
        return feature
    }


    /// Create a point annotation with a `Turf.Point` and an optional identifier.
    public init(id: String = UUID().uuidString, point: Turf.Point) {
        self.id = id
        self.point = point
    }

    /// Create a point annotation with a coordinate and an optional identifier
    /// - Parameters:
    ///   - id: Optional identifier for this annotation
    ///   - coordinate: Coordinate where this annotation should be rendered
    public init(id: String = UUID().uuidString, coordinate: CLLocationCoordinate2D) {
        let point = Turf.Point(coordinate)
        self.init(id: id, point: point)
    }

    // MARK: - Style Properties -

    
    /// Part of the icon placed closest to the anchor.
    public var iconAnchor: IconAnchor? {
        get {
            return styles["icon-anchor"].flatMap { $0 as? String }.flatMap { IconAnchor(rawValue: $0) }
        }
        set {
            styles["icon-anchor"] = newValue?.rawValue
        }
    }
    
    /// Name of image in sprite to use for drawing an image background.
    public var iconImage: String? {
        get {
            return styles["icon-image"] as? String
        }
        set {
            styles["icon-image"] = newValue
        }
    }
    
    /// Offset distance of icon from its anchor. Positive values indicate right and down, while negative values indicate left and up. Each component is multiplied by the value of `icon-size` to obtain the final offset in pixels. When combined with `icon-rotate` the offset will be as if the rotated direction was up.
    public var iconOffset: [Double]? {
        get {
            return styles["icon-offset"] as? [Double]
        }
        set {
            styles["icon-offset"] = newValue
        }
    }
    
    /// Rotates the icon clockwise.
    public var iconRotate: Double? {
        get {
            return styles["icon-rotate"] as? Double
        }
        set {
            styles["icon-rotate"] = newValue
        }
    }
    
    /// Scales the original size of the icon by the provided factor. The new pixel size of the image will be the original pixel size multiplied by `icon-size`. 1 is the original size; 3 triples the size of the image.
    public var iconSize: Double? {
        get {
            return styles["icon-size"] as? Double
        }
        set {
            styles["icon-size"] = newValue
        }
    }
    
    /// Sorts features in ascending order based on this value. Features with lower sort keys are drawn and placed first.  When `icon-allow-overlap` or `text-allow-overlap` is `false`, features with a lower sort key will have priority during placement. When `icon-allow-overlap` or `text-allow-overlap` is set to `true`, features with a higher sort key will overlap over features with a lower sort key.
    public var symbolSortKey: Double? {
        get {
            return styles["symbol-sort-key"] as? Double
        }
        set {
            styles["symbol-sort-key"] = newValue
        }
    }
    
    /// Part of the text placed closest to the anchor.
    public var textAnchor: TextAnchor? {
        get {
            return styles["text-anchor"].flatMap { $0 as? String }.flatMap { TextAnchor(rawValue: $0) }
        }
        set {
            styles["text-anchor"] = newValue?.rawValue
        }
    }
    
    /// Value to use for a text label. If a plain `string` is provided, it will be treated as a `formatted` with default/inherited formatting options.
    public var textField: String? {
        get {
            return styles["text-field"] as? String
        }
        set {
            styles["text-field"] = newValue
        }
    }
    
    /// Text justification options.
    public var textJustify: TextJustify? {
        get {
            return styles["text-justify"].flatMap { $0 as? String }.flatMap { TextJustify(rawValue: $0) }
        }
        set {
            styles["text-justify"] = newValue?.rawValue
        }
    }
    
    /// Text tracking amount.
    public var textLetterSpacing: Double? {
        get {
            return styles["text-letter-spacing"] as? Double
        }
        set {
            styles["text-letter-spacing"] = newValue
        }
    }
    
    /// The maximum line width for text wrapping.
    public var textMaxWidth: Double? {
        get {
            return styles["text-max-width"] as? Double
        }
        set {
            styles["text-max-width"] = newValue
        }
    }
    
    /// Offset distance of text from its anchor. Positive values indicate right and down, while negative values indicate left and up. If used with text-variable-anchor, input values will be taken as absolute values. Offsets along the x- and y-axis will be applied automatically based on the anchor position.
    public var textOffset: [Double]? {
        get {
            return styles["text-offset"] as? [Double]
        }
        set {
            styles["text-offset"] = newValue
        }
    }
    
    /// Radial offset of text, in the direction of the symbol's anchor. Useful in combination with `text-variable-anchor`, which defaults to using the two-dimensional `text-offset` if present.
    public var textRadialOffset: Double? {
        get {
            return styles["text-radial-offset"] as? Double
        }
        set {
            styles["text-radial-offset"] = newValue
        }
    }
    
    /// Rotates the text clockwise.
    public var textRotate: Double? {
        get {
            return styles["text-rotate"] as? Double
        }
        set {
            styles["text-rotate"] = newValue
        }
    }
    
    /// Font size.
    public var textSize: Double? {
        get {
            return styles["text-size"] as? Double
        }
        set {
            styles["text-size"] = newValue
        }
    }
    
    /// Specifies how to capitalize text, similar to the CSS `text-transform` property.
    public var textTransform: TextTransform? {
        get {
            return styles["text-transform"].flatMap { $0 as? String }.flatMap { TextTransform(rawValue: $0) }
        }
        set {
            styles["text-transform"] = newValue?.rawValue
        }
    }
    
    /// The color of the icon. This can only be used with sdf icons.
    public var iconColor: ColorRepresentable? {
        get {
            return styles["icon-color"].flatMap { $0 as? String }.flatMap { try? JSONDecoder().decode(ColorRepresentable.self, from: $0.data(using: .utf8)!) }
        }
        set {
            styles["icon-color"] = newValue.flatMap { try? String(data: JSONEncoder().encode($0), encoding: .utf8) }
        }
    }
    
    /// Fade out the halo towards the outside.
    public var iconHaloBlur: Double? {
        get {
            return styles["icon-halo-blur"] as? Double
        }
        set {
            styles["icon-halo-blur"] = newValue
        }
    }
    
    /// The color of the icon's halo. Icon halos can only be used with SDF icons.
    public var iconHaloColor: ColorRepresentable? {
        get {
            return styles["icon-halo-color"].flatMap { $0 as? String }.flatMap { try? JSONDecoder().decode(ColorRepresentable.self, from: $0.data(using: .utf8)!) }
        }
        set {
            styles["icon-halo-color"] = newValue.flatMap { try? String(data: JSONEncoder().encode($0), encoding: .utf8) }
        }
    }
    
    /// Distance of halo to the icon outline.
    public var iconHaloWidth: Double? {
        get {
            return styles["icon-halo-width"] as? Double
        }
        set {
            styles["icon-halo-width"] = newValue
        }
    }
    
    /// The opacity at which the icon will be drawn.
    public var iconOpacity: Double? {
        get {
            return styles["icon-opacity"] as? Double
        }
        set {
            styles["icon-opacity"] = newValue
        }
    }
    
    /// The color with which the text will be drawn.
    public var textColor: ColorRepresentable? {
        get {
            return styles["text-color"].flatMap { $0 as? String }.flatMap { try? JSONDecoder().decode(ColorRepresentable.self, from: $0.data(using: .utf8)!) }
        }
        set {
            styles["text-color"] = newValue.flatMap { try? String(data: JSONEncoder().encode($0), encoding: .utf8) }
        }
    }
    
    /// The halo's fadeout distance towards the outside.
    public var textHaloBlur: Double? {
        get {
            return styles["text-halo-blur"] as? Double
        }
        set {
            styles["text-halo-blur"] = newValue
        }
    }
    
    /// The color of the text's halo, which helps it stand out from backgrounds.
    public var textHaloColor: ColorRepresentable? {
        get {
            return styles["text-halo-color"].flatMap { $0 as? String }.flatMap { try? JSONDecoder().decode(ColorRepresentable.self, from: $0.data(using: .utf8)!) }
        }
        set {
            styles["text-halo-color"] = newValue.flatMap { try? String(data: JSONEncoder().encode($0), encoding: .utf8) }
        }
    }
    
    /// Distance of halo to the font outline. Max text halo width is 1/4 of the font-size.
    public var textHaloWidth: Double? {
        get {
            return styles["text-halo-width"] as? Double
        }
        set {
            styles["text-halo-width"] = newValue
        }
    }
    
    /// The opacity at which the text will be drawn.
    public var textOpacity: Double? {
        get {
            return styles["text-opacity"] as? Double
        }
        set {
            styles["text-opacity"] = newValue
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
// swiftlint:enable all