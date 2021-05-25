// This file is generated.
import Foundation
import Turf

public struct PointAnnotation: Annotation {

    /// Identifier for this annotation
    public let id: String

    /// The feature backing this annotation
    public internal(set) var feature: Turf.Feature
    
    /// A Boolean value that indicates whether an annotation is selected, either
    /// programmatically or via user-interactions.
    public var isSelected: Bool = false { 
        didSet {
            feature.properties?["is-selected"] = isSelected
        }
    }

    /// Properties associated with the annotation
    public var userInfo: [String: Any]? { 
        didSet {
            feature.properties?["userInfo"] = userInfo
        }
    }

    public var type: AnnotationType = .point

    /// Create a point annotation with a `Turf.Point` and an optional identifier.
    public init(id: String = UUID().uuidString, point: Turf.Point) {
        self.id = id
        self.feature = Turf.Feature(point)
        self.feature.properties = ["annotation-id": id]
    }

    // MARK:- Properties -
    
    /// Part of the icon placed closest to the anchor.
    public var iconAnchor: IconAnchor? {
        didSet {
            feature.properties?["icon-anchor"] = iconAnchor?.rawValue 
        }
    }
    
    /// Name of image in sprite to use for drawing an image background.
    public var iconImage: String? {
        didSet {
            feature.properties?["icon-image"] = iconImage 
        }
    }
    
    /// Offset distance of icon from its anchor. Positive values indicate right and down, while negative values indicate left and up. Each component is multiplied by the value of `icon-size` to obtain the final offset in pixels. When combined with `icon-rotate` the offset will be as if the rotated direction was up.
    public var iconOffset: [Double]? {
        didSet {
            feature.properties?["icon-offset"] = iconOffset 
        }
    }
    
    /// Rotates the icon clockwise.
    public var iconRotate: Double? {
        didSet {
            feature.properties?["icon-rotate"] = iconRotate 
        }
    }
    
    /// Scales the original size of the icon by the provided factor. The new pixel size of the image will be the original pixel size multiplied by `icon-size`. 1 is the original size; 3 triples the size of the image.
    public var iconSize: Double? {
        didSet {
            feature.properties?["icon-size"] = iconSize 
        }
    }
    
    /// Sorts features in ascending order based on this value. Features with lower sort keys are drawn and placed first.  When `icon-allow-overlap` or `text-allow-overlap` is `false`, features with a lower sort key will have priority during placement. When `icon-allow-overlap` or `text-allow-overlap` is set to `true`, features with a higher sort key will overlap over features with a lower sort key.
    public var symbolSortKey: Double? {
        didSet {
            feature.properties?["symbol-sort-key"] = symbolSortKey 
        }
    }
    
    /// Part of the text placed closest to the anchor.
    public var textAnchor: TextAnchor? {
        didSet {
            feature.properties?["text-anchor"] = textAnchor?.rawValue 
        }
    }
    
    /// Value to use for a text label. If a plain `string` is provided, it will be treated as a `formatted` with default/inherited formatting options.
    public var textField: String? {
        didSet {
            feature.properties?["text-field"] = textField 
        }
    }
    
    /// Font stack to use for displaying text.
    public var textFont: [String]? {
        didSet {
            feature.properties?["text-font"] = textFont 
        }
    }
    
    /// Text justification options.
    public var textJustify: TextJustify? {
        didSet {
            feature.properties?["text-justify"] = textJustify?.rawValue 
        }
    }
    
    /// Text tracking amount.
    public var textLetterSpacing: Double? {
        didSet {
            feature.properties?["text-letter-spacing"] = textLetterSpacing 
        }
    }
    
    /// The maximum line width for text wrapping.
    public var textMaxWidth: Double? {
        didSet {
            feature.properties?["text-max-width"] = textMaxWidth 
        }
    }
    
    /// Offset distance of text from its anchor. Positive values indicate right and down, while negative values indicate left and up. If used with text-variable-anchor, input values will be taken as absolute values. Offsets along the x- and y-axis will be applied automatically based on the anchor position.
    public var textOffset: [Double]? {
        didSet {
            feature.properties?["text-offset"] = textOffset 
        }
    }
    
    /// Radial offset of text, in the direction of the symbol's anchor. Useful in combination with `text-variable-anchor`, which defaults to using the two-dimensional `text-offset` if present.
    public var textRadialOffset: Double? {
        didSet {
            feature.properties?["text-radial-offset"] = textRadialOffset 
        }
    }
    
    /// Rotates the text clockwise.
    public var textRotate: Double? {
        didSet {
            feature.properties?["text-rotate"] = textRotate 
        }
    }
    
    /// Font size.
    public var textSize: Double? {
        didSet {
            feature.properties?["text-size"] = textSize 
        }
    }
    
    /// Specifies how to capitalize text, similar to the CSS `text-transform` property.
    public var textTransform: TextTransform? {
        didSet {
            feature.properties?["text-transform"] = textTransform?.rawValue 
        }
    }
    
    /// The color of the icon. This can only be used with sdf icons.
    public var iconColor: ColorRepresentable? {
        didSet {
            feature.properties?["icon-color"] = iconColor?.rgbaDescription 
        }
    }
    
    /// Fade out the halo towards the outside.
    public var iconHaloBlur: Double? {
        didSet {
            feature.properties?["icon-halo-blur"] = iconHaloBlur 
        }
    }
    
    /// The color of the icon's halo. Icon halos can only be used with SDF icons.
    public var iconHaloColor: ColorRepresentable? {
        didSet {
            feature.properties?["icon-halo-color"] = iconHaloColor?.rgbaDescription 
        }
    }
    
    /// Distance of halo to the icon outline.
    public var iconHaloWidth: Double? {
        didSet {
            feature.properties?["icon-halo-width"] = iconHaloWidth 
        }
    }
    
    /// The opacity at which the icon will be drawn.
    public var iconOpacity: Double? {
        didSet {
            feature.properties?["icon-opacity"] = iconOpacity 
        }
    }
    
    /// The color with which the text will be drawn.
    public var textColor: ColorRepresentable? {
        didSet {
            feature.properties?["text-color"] = textColor?.rgbaDescription 
        }
    }
    
    /// The halo's fadeout distance towards the outside.
    public var textHaloBlur: Double? {
        didSet {
            feature.properties?["text-halo-blur"] = textHaloBlur 
        }
    }
    
    /// The color of the text's halo, which helps it stand out from backgrounds.
    public var textHaloColor: ColorRepresentable? {
        didSet {
            feature.properties?["text-halo-color"] = textHaloColor?.rgbaDescription 
        }
    }
    
    /// Distance of halo to the font outline. Max text halo width is 1/4 of the font-size.
    public var textHaloWidth: Double? {
        didSet {
            feature.properties?["text-halo-width"] = textHaloWidth 
        }
    }
    
    /// The opacity at which the text will be drawn.
    public var textOpacity: Double? {
        didSet {
            feature.properties?["text-opacity"] = textOpacity 
        }
    }

    // MARK:- Hashable -

    public static func == (lhs: PointAnnotation, rhs: PointAnnotation) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }   
}

// End of generated file.