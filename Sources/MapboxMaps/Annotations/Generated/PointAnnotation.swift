// swiftlint:disable all
// This file is generated.
import Foundation
import Turf

public struct PointAnnotation: Annotation {

    /// Identifier for this annotation
    public let id: String

    /// The feature backing this annotation
    public internal(set) var feature: Turf.Feature

    /// Properties associated with the annotation
    public var userInfo: [String: Any]? { 
        didSet {
            feature.properties?["userInfo"] = userInfo
        }
    }


    /// Create a point annotation with a `Turf.Point` and an optional identifier.
    public init(id: String = UUID().uuidString, point: Turf.Point) {
        self.id = id
        self.feature = Turf.Feature(point)
        self.feature.properties = ["annotation-id": id]
    }

    /// Create a point annotation with a coordinate and an optional identifier
    /// - Parameters:
    ///   - id: Optional identifier for this annotation
    ///   - coordinate: Coordinate where this annotation should be rendered
    public init(id: String = UUID().uuidString, coordinate: CLLocationCoordinate2D) {
        let point = Turf.Point(coordinate)
        self.init(id: id, point: point)
    }

    // MARK: - Properties -

    /// Set of used data driven properties
    internal var dataDrivenPropertiesUsedSet: Set<String> = []

    
    /// Part of the icon placed closest to the anchor.
    public var iconAnchor: IconAnchor? {
        get {
            return feature.properties?["icon-anchor"] as? IconAnchor 
        }
        set {
            feature.properties?["icon-anchor"] = newValue?.rawValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("icon-anchor")
            } else {
                dataDrivenPropertiesUsedSet.remove("icon-anchor")
            }
        }
    }
    
    /// Name of image in sprite to use for drawing an image background.
    public var iconImage: String? {
        get {
            return feature.properties?["icon-image"] as? String 
        }
        set {
            feature.properties?["icon-image"] = newValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("icon-image")
            } else {
                dataDrivenPropertiesUsedSet.remove("icon-image")
            }
        }
    }
    
    /// Offset distance of icon from its anchor. Positive values indicate right and down, while negative values indicate left and up. Each component is multiplied by the value of `icon-size` to obtain the final offset in pixels. When combined with `icon-rotate` the offset will be as if the rotated direction was up.
    public var iconOffset: [Double]? {
        get {
            return feature.properties?["icon-offset"] as? [Double] 
        }
        set {
            feature.properties?["icon-offset"] = newValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("icon-offset")
            } else {
                dataDrivenPropertiesUsedSet.remove("icon-offset")
            }
        }
    }
    
    /// Rotates the icon clockwise.
    public var iconRotate: Double? {
        get {
            return feature.properties?["icon-rotate"] as? Double 
        }
        set {
            feature.properties?["icon-rotate"] = newValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("icon-rotate")
            } else {
                dataDrivenPropertiesUsedSet.remove("icon-rotate")
            }
        }
    }
    
    /// Scales the original size of the icon by the provided factor. The new pixel size of the image will be the original pixel size multiplied by `icon-size`. 1 is the original size; 3 triples the size of the image.
    public var iconSize: Double? {
        get {
            return feature.properties?["icon-size"] as? Double 
        }
        set {
            feature.properties?["icon-size"] = newValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("icon-size")
            } else {
                dataDrivenPropertiesUsedSet.remove("icon-size")
            }
        }
    }
    
    /// Sorts features in ascending order based on this value. Features with lower sort keys are drawn and placed first.  When `icon-allow-overlap` or `text-allow-overlap` is `false`, features with a lower sort key will have priority during placement. When `icon-allow-overlap` or `text-allow-overlap` is set to `true`, features with a higher sort key will overlap over features with a lower sort key.
    public var symbolSortKey: Double? {
        get {
            return feature.properties?["symbol-sort-key"] as? Double 
        }
        set {
            feature.properties?["symbol-sort-key"] = newValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("symbol-sort-key")
            } else {
                dataDrivenPropertiesUsedSet.remove("symbol-sort-key")
            }
        }
    }
    
    /// Part of the text placed closest to the anchor.
    public var textAnchor: TextAnchor? {
        get {
            return feature.properties?["text-anchor"] as? TextAnchor 
        }
        set {
            feature.properties?["text-anchor"] = newValue?.rawValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("text-anchor")
            } else {
                dataDrivenPropertiesUsedSet.remove("text-anchor")
            }
        }
    }
    
    /// Value to use for a text label. If a plain `string` is provided, it will be treated as a `formatted` with default/inherited formatting options.
    public var textField: String? {
        get {
            return feature.properties?["text-field"] as? String 
        }
        set {
            feature.properties?["text-field"] = newValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("text-field")
            } else {
                dataDrivenPropertiesUsedSet.remove("text-field")
            }
        }
    }
    
    /// Text justification options.
    public var textJustify: TextJustify? {
        get {
            return feature.properties?["text-justify"] as? TextJustify 
        }
        set {
            feature.properties?["text-justify"] = newValue?.rawValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("text-justify")
            } else {
                dataDrivenPropertiesUsedSet.remove("text-justify")
            }
        }
    }
    
    /// Text tracking amount.
    public var textLetterSpacing: Double? {
        get {
            return feature.properties?["text-letter-spacing"] as? Double 
        }
        set {
            feature.properties?["text-letter-spacing"] = newValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("text-letter-spacing")
            } else {
                dataDrivenPropertiesUsedSet.remove("text-letter-spacing")
            }
        }
    }
    
    /// The maximum line width for text wrapping.
    public var textMaxWidth: Double? {
        get {
            return feature.properties?["text-max-width"] as? Double 
        }
        set {
            feature.properties?["text-max-width"] = newValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("text-max-width")
            } else {
                dataDrivenPropertiesUsedSet.remove("text-max-width")
            }
        }
    }
    
    /// Offset distance of text from its anchor. Positive values indicate right and down, while negative values indicate left and up. If used with text-variable-anchor, input values will be taken as absolute values. Offsets along the x- and y-axis will be applied automatically based on the anchor position.
    public var textOffset: [Double]? {
        get {
            return feature.properties?["text-offset"] as? [Double] 
        }
        set {
            feature.properties?["text-offset"] = newValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("text-offset")
            } else {
                dataDrivenPropertiesUsedSet.remove("text-offset")
            }
        }
    }
    
    /// Radial offset of text, in the direction of the symbol's anchor. Useful in combination with `text-variable-anchor`, which defaults to using the two-dimensional `text-offset` if present.
    public var textRadialOffset: Double? {
        get {
            return feature.properties?["text-radial-offset"] as? Double 
        }
        set {
            feature.properties?["text-radial-offset"] = newValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("text-radial-offset")
            } else {
                dataDrivenPropertiesUsedSet.remove("text-radial-offset")
            }
        }
    }
    
    /// Rotates the text clockwise.
    public var textRotate: Double? {
        get {
            return feature.properties?["text-rotate"] as? Double 
        }
        set {
            feature.properties?["text-rotate"] = newValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("text-rotate")
            } else {
                dataDrivenPropertiesUsedSet.remove("text-rotate")
            }
        }
    }
    
    /// Font size.
    public var textSize: Double? {
        get {
            return feature.properties?["text-size"] as? Double 
        }
        set {
            feature.properties?["text-size"] = newValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("text-size")
            } else {
                dataDrivenPropertiesUsedSet.remove("text-size")
            }
        }
    }
    
    /// Specifies how to capitalize text, similar to the CSS `text-transform` property.
    public var textTransform: TextTransform? {
        get {
            return feature.properties?["text-transform"] as? TextTransform 
        }
        set {
            feature.properties?["text-transform"] = newValue?.rawValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("text-transform")
            } else {
                dataDrivenPropertiesUsedSet.remove("text-transform")
            }
        }
    }
    
    /// The color of the icon. This can only be used with sdf icons.
    public var iconColor: ColorRepresentable? {
        get {
            return feature.properties?["icon-color"] as? ColorRepresentable 
        }
        set {
            feature.properties?["icon-color"] = newValue?.rgbaDescription 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("icon-color")
            } else {
                dataDrivenPropertiesUsedSet.remove("icon-color")
            }
        }
    }
    
    /// Fade out the halo towards the outside.
    public var iconHaloBlur: Double? {
        get {
            return feature.properties?["icon-halo-blur"] as? Double 
        }
        set {
            feature.properties?["icon-halo-blur"] = newValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("icon-halo-blur")
            } else {
                dataDrivenPropertiesUsedSet.remove("icon-halo-blur")
            }
        }
    }
    
    /// The color of the icon's halo. Icon halos can only be used with SDF icons.
    public var iconHaloColor: ColorRepresentable? {
        get {
            return feature.properties?["icon-halo-color"] as? ColorRepresentable 
        }
        set {
            feature.properties?["icon-halo-color"] = newValue?.rgbaDescription 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("icon-halo-color")
            } else {
                dataDrivenPropertiesUsedSet.remove("icon-halo-color")
            }
        }
    }
    
    /// Distance of halo to the icon outline.
    public var iconHaloWidth: Double? {
        get {
            return feature.properties?["icon-halo-width"] as? Double 
        }
        set {
            feature.properties?["icon-halo-width"] = newValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("icon-halo-width")
            } else {
                dataDrivenPropertiesUsedSet.remove("icon-halo-width")
            }
        }
    }
    
    /// The opacity at which the icon will be drawn.
    public var iconOpacity: Double? {
        get {
            return feature.properties?["icon-opacity"] as? Double 
        }
        set {
            feature.properties?["icon-opacity"] = newValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("icon-opacity")
            } else {
                dataDrivenPropertiesUsedSet.remove("icon-opacity")
            }
        }
    }
    
    /// The color with which the text will be drawn.
    public var textColor: ColorRepresentable? {
        get {
            return feature.properties?["text-color"] as? ColorRepresentable 
        }
        set {
            feature.properties?["text-color"] = newValue?.rgbaDescription 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("text-color")
            } else {
                dataDrivenPropertiesUsedSet.remove("text-color")
            }
        }
    }
    
    /// The halo's fadeout distance towards the outside.
    public var textHaloBlur: Double? {
        get {
            return feature.properties?["text-halo-blur"] as? Double 
        }
        set {
            feature.properties?["text-halo-blur"] = newValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("text-halo-blur")
            } else {
                dataDrivenPropertiesUsedSet.remove("text-halo-blur")
            }
        }
    }
    
    /// The color of the text's halo, which helps it stand out from backgrounds.
    public var textHaloColor: ColorRepresentable? {
        get {
            return feature.properties?["text-halo-color"] as? ColorRepresentable 
        }
        set {
            feature.properties?["text-halo-color"] = newValue?.rgbaDescription 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("text-halo-color")
            } else {
                dataDrivenPropertiesUsedSet.remove("text-halo-color")
            }
        }
    }
    
    /// Distance of halo to the font outline. Max text halo width is 1/4 of the font-size.
    public var textHaloWidth: Double? {
        get {
            return feature.properties?["text-halo-width"] as? Double 
        }
        set {
            feature.properties?["text-halo-width"] = newValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("text-halo-width")
            } else {
                dataDrivenPropertiesUsedSet.remove("text-halo-width")
            }
        }
    }
    
    /// The opacity at which the text will be drawn.
    public var textOpacity: Double? {
        get {
            return feature.properties?["text-opacity"] as? Double 
        }
        set {
            feature.properties?["text-opacity"] = newValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("text-opacity")
            } else {
                dataDrivenPropertiesUsedSet.remove("text-opacity")
            }
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