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
    
    public var isDraggable: Bool? {
        didSet {
            feature.properties?["is-draggable"] = isDraggable
        }
    }

    /// Set of used data driven properties
    internal var dataDrivenPropertiesUsedSet: Set<String> = []

    
    /// Part of the icon placed closest to the anchor.
    public var iconAnchor: IconAnchor? {
        didSet {
            feature.properties?["icon-anchor"] = iconAnchor?.rawValue 
            if iconAnchor != nil {
                dataDrivenPropertiesUsedSet.insert("icon-anchor")
            }
        }
    }
    
    /// Name of image in sprite to use for drawing an image background.
    public var iconImage: String? {
        didSet {
            feature.properties?["icon-image"] = iconImage 
            if iconImage != nil {
                dataDrivenPropertiesUsedSet.insert("icon-image")
            }
        }
    }
    
    /// Offset distance of icon from its anchor. Positive values indicate right and down, while negative values indicate left and up. Each component is multiplied by the value of `icon-size` to obtain the final offset in pixels. When combined with `icon-rotate` the offset will be as if the rotated direction was up.
    public var iconOffset: [Double]? {
        didSet {
            feature.properties?["icon-offset"] = iconOffset 
            if iconOffset != nil {
                dataDrivenPropertiesUsedSet.insert("icon-offset")
            }
        }
    }
    
    /// Rotates the icon clockwise.
    public var iconRotate: Double? {
        didSet {
            feature.properties?["icon-rotate"] = iconRotate 
            if iconRotate != nil {
                dataDrivenPropertiesUsedSet.insert("icon-rotate")
            }
        }
    }
    
    /// Scales the original size of the icon by the provided factor. The new pixel size of the image will be the original pixel size multiplied by `icon-size`. 1 is the original size; 3 triples the size of the image.
    public var iconSize: Double? {
        didSet {
            feature.properties?["icon-size"] = iconSize 
            if iconSize != nil {
                dataDrivenPropertiesUsedSet.insert("icon-size")
            }
        }
    }
    
    /// Sorts features in ascending order based on this value. Features with lower sort keys are drawn and placed first.  When `icon-allow-overlap` or `text-allow-overlap` is `false`, features with a lower sort key will have priority during placement. When `icon-allow-overlap` or `text-allow-overlap` is set to `true`, features with a higher sort key will overlap over features with a lower sort key.
    public var symbolSortKey: Double? {
        didSet {
            feature.properties?["symbol-sort-key"] = symbolSortKey 
            if symbolSortKey != nil {
                dataDrivenPropertiesUsedSet.insert("symbol-sort-key")
            }
        }
    }
    
    /// Part of the text placed closest to the anchor.
    public var textAnchor: TextAnchor? {
        didSet {
            feature.properties?["text-anchor"] = textAnchor?.rawValue 
            if textAnchor != nil {
                dataDrivenPropertiesUsedSet.insert("text-anchor")
            }
        }
    }
    
    /// Value to use for a text label. If a plain `string` is provided, it will be treated as a `formatted` with default/inherited formatting options.
    public var textField: String? {
        didSet {
            feature.properties?["text-field"] = textField 
            if textField != nil {
                dataDrivenPropertiesUsedSet.insert("text-field")
            }
        }
    }
    
    /// Text justification options.
    public var textJustify: TextJustify? {
        didSet {
            feature.properties?["text-justify"] = textJustify?.rawValue 
            if textJustify != nil {
                dataDrivenPropertiesUsedSet.insert("text-justify")
            }
        }
    }
    
    /// Text tracking amount.
    public var textLetterSpacing: Double? {
        didSet {
            feature.properties?["text-letter-spacing"] = textLetterSpacing 
            if textLetterSpacing != nil {
                dataDrivenPropertiesUsedSet.insert("text-letter-spacing")
            }
        }
    }
    
    /// The maximum line width for text wrapping.
    public var textMaxWidth: Double? {
        didSet {
            feature.properties?["text-max-width"] = textMaxWidth 
            if textMaxWidth != nil {
                dataDrivenPropertiesUsedSet.insert("text-max-width")
            }
        }
    }
    
    /// Offset distance of text from its anchor. Positive values indicate right and down, while negative values indicate left and up. If used with text-variable-anchor, input values will be taken as absolute values. Offsets along the x- and y-axis will be applied automatically based on the anchor position.
    public var textOffset: [Double]? {
        didSet {
            feature.properties?["text-offset"] = textOffset 
            if textOffset != nil {
                dataDrivenPropertiesUsedSet.insert("text-offset")
            }
        }
    }
    
    /// Radial offset of text, in the direction of the symbol's anchor. Useful in combination with `text-variable-anchor`, which defaults to using the two-dimensional `text-offset` if present.
    public var textRadialOffset: Double? {
        didSet {
            feature.properties?["text-radial-offset"] = textRadialOffset 
            if textRadialOffset != nil {
                dataDrivenPropertiesUsedSet.insert("text-radial-offset")
            }
        }
    }
    
    /// Rotates the text clockwise.
    public var textRotate: Double? {
        didSet {
            feature.properties?["text-rotate"] = textRotate 
            if textRotate != nil {
                dataDrivenPropertiesUsedSet.insert("text-rotate")
            }
        }
    }
    
    /// Font size.
    public var textSize: Double? {
        didSet {
            feature.properties?["text-size"] = textSize 
            if textSize != nil {
                dataDrivenPropertiesUsedSet.insert("text-size")
            }
        }
    }
    
    /// Specifies how to capitalize text, similar to the CSS `text-transform` property.
    public var textTransform: TextTransform? {
        didSet {
            feature.properties?["text-transform"] = textTransform?.rawValue 
            if textTransform != nil {
                dataDrivenPropertiesUsedSet.insert("text-transform")
            }
        }
    }
    
    /// The color of the icon. This can only be used with sdf icons.
    public var iconColor: ColorRepresentable? {
        didSet {
            feature.properties?["icon-color"] = iconColor?.rgbaDescription 
            if iconColor != nil {
                dataDrivenPropertiesUsedSet.insert("icon-color")
            }
        }
    }
    
    /// Fade out the halo towards the outside.
    public var iconHaloBlur: Double? {
        didSet {
            feature.properties?["icon-halo-blur"] = iconHaloBlur 
            if iconHaloBlur != nil {
                dataDrivenPropertiesUsedSet.insert("icon-halo-blur")
            }
        }
    }
    
    /// The color of the icon's halo. Icon halos can only be used with SDF icons.
    public var iconHaloColor: ColorRepresentable? {
        didSet {
            feature.properties?["icon-halo-color"] = iconHaloColor?.rgbaDescription 
            if iconHaloColor != nil {
                dataDrivenPropertiesUsedSet.insert("icon-halo-color")
            }
        }
    }
    
    /// Distance of halo to the icon outline.
    public var iconHaloWidth: Double? {
        didSet {
            feature.properties?["icon-halo-width"] = iconHaloWidth 
            if iconHaloWidth != nil {
                dataDrivenPropertiesUsedSet.insert("icon-halo-width")
            }
        }
    }
    
    /// The opacity at which the icon will be drawn.
    public var iconOpacity: Double? {
        didSet {
            feature.properties?["icon-opacity"] = iconOpacity 
            if iconOpacity != nil {
                dataDrivenPropertiesUsedSet.insert("icon-opacity")
            }
        }
    }
    
    /// The color with which the text will be drawn.
    public var textColor: ColorRepresentable? {
        didSet {
            feature.properties?["text-color"] = textColor?.rgbaDescription 
            if textColor != nil {
                dataDrivenPropertiesUsedSet.insert("text-color")
            }
        }
    }
    
    /// The halo's fadeout distance towards the outside.
    public var textHaloBlur: Double? {
        didSet {
            feature.properties?["text-halo-blur"] = textHaloBlur 
            if textHaloBlur != nil {
                dataDrivenPropertiesUsedSet.insert("text-halo-blur")
            }
        }
    }
    
    /// The color of the text's halo, which helps it stand out from backgrounds.
    public var textHaloColor: ColorRepresentable? {
        didSet {
            feature.properties?["text-halo-color"] = textHaloColor?.rgbaDescription 
            if textHaloColor != nil {
                dataDrivenPropertiesUsedSet.insert("text-halo-color")
            }
        }
    }
    
    /// Distance of halo to the font outline. Max text halo width is 1/4 of the font-size.
    public var textHaloWidth: Double? {
        didSet {
            feature.properties?["text-halo-width"] = textHaloWidth 
            if textHaloWidth != nil {
                dataDrivenPropertiesUsedSet.insert("text-halo-width")
            }
        }
    }
    
    /// The opacity at which the text will be drawn.
    public var textOpacity: Double? {
        didSet {
            feature.properties?["text-opacity"] = textOpacity 
            if textOpacity != nil {
                dataDrivenPropertiesUsedSet.insert("text-opacity")
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
