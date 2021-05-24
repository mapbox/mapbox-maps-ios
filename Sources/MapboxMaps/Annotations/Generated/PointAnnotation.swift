
// This file is generated.
import Foundation
import Turf

public struct PointAnnotation: Hashable {

    // Identifier for this annotation
    public let id: String

    // The feature backing this annotation
    internal var feature: Turf.Feature

    public init(id: String = UUID().uuidString, point: Turf.Point) {
        self.id = id
        self.feature = Turf.Feature(point)
        self.feature.properties = ["id": id]
    }

    // MARK:- Properties -

    /// Part of the icon placed closest to the anchor.
    public var iconAnchor: IconAnchor? {
        didSet {
            do {
                let data = try JSONEncoder().encode(iconAnchor)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["icon-anchor"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PointAnnotation.iconAnchor")
            }
        }
    }

    /// Name of image in sprite to use for drawing an image background.
    public var iconImage: String? {
        didSet {
            do {
                let data = try JSONEncoder().encode(iconImage)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["icon-image"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PointAnnotation.iconImage")
            }
        }
    }

    /// Offset distance of icon from its anchor. Positive values indicate right and down, while negative values indicate left and up. Each component is multiplied by the value of `icon-size` to obtain the final offset in pixels. When combined with `icon-rotate` the offset will be as if the rotated direction was up.
    public var iconOffset: [Double]? {
        didSet {
            do {
                let data = try JSONEncoder().encode(iconOffset)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["icon-offset"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PointAnnotation.iconOffset")
            }
        }
    }

    /// Rotates the icon clockwise.
    public var iconRotate: Double? {
        didSet {
            do {
                let data = try JSONEncoder().encode(iconRotate)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["icon-rotate"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PointAnnotation.iconRotate")
            }
        }
    }

    /// Scales the original size of the icon by the provided factor. The new pixel size of the image will be the original pixel size multiplied by `icon-size`. 1 is the original size; 3 triples the size of the image.
    public var iconSize: Double? {
        didSet {
            do {
                let data = try JSONEncoder().encode(iconSize)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["icon-size"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PointAnnotation.iconSize")
            }
        }
    }

    /// Sorts features in ascending order based on this value. Features with lower sort keys are drawn and placed first.  When `icon-allow-overlap` or `text-allow-overlap` is `false`, features with a lower sort key will have priority during placement. When `icon-allow-overlap` or `text-allow-overlap` is set to `true`, features with a higher sort key will overlap over features with a lower sort key.
    public var symbolSortKey: Double? {
        didSet {
            do {
                let data = try JSONEncoder().encode(symbolSortKey)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["symbol-sort-key"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PointAnnotation.symbolSortKey")
            }
        }
    }

    /// Part of the text placed closest to the anchor.
    public var textAnchor: TextAnchor? {
        didSet {
            do {
                let data = try JSONEncoder().encode(textAnchor)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["text-anchor"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PointAnnotation.textAnchor")
            }
        }
    }

    /// Value to use for a text label. If a plain `string` is provided, it will be treated as a `formatted` with default/inherited formatting options.
    public var textField: String? {
        didSet {
            do {
                let data = try JSONEncoder().encode(textField)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["text-field"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PointAnnotation.textField")
            }
        }
    }

    /// Font stack to use for displaying text.
    public var textFont: [String]? {
        didSet {
            do {
                let data = try JSONEncoder().encode(textFont)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["text-font"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PointAnnotation.textFont")
            }
        }
    }

    /// Text justification options.
    public var textJustify: TextJustify? {
        didSet {
            do {
                let data = try JSONEncoder().encode(textJustify)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["text-justify"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PointAnnotation.textJustify")
            }
        }
    }

    /// Text tracking amount.
    public var textLetterSpacing: Double? {
        didSet {
            do {
                let data = try JSONEncoder().encode(textLetterSpacing)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["text-letter-spacing"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PointAnnotation.textLetterSpacing")
            }
        }
    }

    /// The maximum line width for text wrapping.
    public var textMaxWidth: Double? {
        didSet {
            do {
                let data = try JSONEncoder().encode(textMaxWidth)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["text-max-width"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PointAnnotation.textMaxWidth")
            }
        }
    }

    /// Offset distance of text from its anchor. Positive values indicate right and down, while negative values indicate left and up. If used with text-variable-anchor, input values will be taken as absolute values. Offsets along the x- and y-axis will be applied automatically based on the anchor position.
    public var textOffset: [Double]? {
        didSet {
            do {
                let data = try JSONEncoder().encode(textOffset)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["text-offset"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PointAnnotation.textOffset")
            }
        }
    }

    /// Radial offset of text, in the direction of the symbol's anchor. Useful in combination with `text-variable-anchor`, which defaults to using the two-dimensional `text-offset` if present.
    public var textRadialOffset: Double? {
        didSet {
            do {
                let data = try JSONEncoder().encode(textRadialOffset)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["text-radial-offset"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PointAnnotation.textRadialOffset")
            }
        }
    }

    /// Rotates the text clockwise.
    public var textRotate: Double? {
        didSet {
            do {
                let data = try JSONEncoder().encode(textRotate)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["text-rotate"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PointAnnotation.textRotate")
            }
        }
    }

    /// Font size.
    public var textSize: Double? {
        didSet {
            do {
                let data = try JSONEncoder().encode(textSize)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["text-size"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PointAnnotation.textSize")
            }
        }
    }

    /// Specifies how to capitalize text, similar to the CSS `text-transform` property.
    public var textTransform: TextTransform? {
        didSet {
            do {
                let data = try JSONEncoder().encode(textTransform)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["text-transform"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PointAnnotation.textTransform")
            }
        }
    }

    /// The color of the icon. This can only be used with sdf icons.
    public var iconColor: ColorRepresentable? {
        didSet {
            do {
                let data = try JSONEncoder().encode(iconColor)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["icon-color"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PointAnnotation.iconColor")
            }
        }
    }

    /// Fade out the halo towards the outside.
    public var iconHaloBlur: Double? {
        didSet {
            do {
                let data = try JSONEncoder().encode(iconHaloBlur)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["icon-halo-blur"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PointAnnotation.iconHaloBlur")
            }
        }
    }

    /// The color of the icon's halo. Icon halos can only be used with SDF icons.
    public var iconHaloColor: ColorRepresentable? {
        didSet {
            do {
                let data = try JSONEncoder().encode(iconHaloColor)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["icon-halo-color"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PointAnnotation.iconHaloColor")
            }
        }
    }

    /// Distance of halo to the icon outline.
    public var iconHaloWidth: Double? {
        didSet {
            do {
                let data = try JSONEncoder().encode(iconHaloWidth)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["icon-halo-width"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PointAnnotation.iconHaloWidth")
            }
        }
    }

    /// The opacity at which the icon will be drawn.
    public var iconOpacity: Double? {
        didSet {
            do {
                let data = try JSONEncoder().encode(iconOpacity)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["icon-opacity"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PointAnnotation.iconOpacity")
            }
        }
    }

    /// The color with which the text will be drawn.
    public var textColor: ColorRepresentable? {
        didSet {
            do {
                let data = try JSONEncoder().encode(textColor)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["text-color"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PointAnnotation.textColor")
            }
        }
    }

    /// The halo's fadeout distance towards the outside.
    public var textHaloBlur: Double? {
        didSet {
            do {
                let data = try JSONEncoder().encode(textHaloBlur)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["text-halo-blur"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PointAnnotation.textHaloBlur")
            }
        }
    }

    /// The color of the text's halo, which helps it stand out from backgrounds.
    public var textHaloColor: ColorRepresentable? {
        didSet {
            do {
                let data = try JSONEncoder().encode(textHaloColor)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["text-halo-color"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PointAnnotation.textHaloColor")
            }
        }
    }

    /// Distance of halo to the font outline. Max text halo width is 1/4 of the font-size.
    public var textHaloWidth: Double? {
        didSet {
            do {
                let data = try JSONEncoder().encode(textHaloWidth)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["text-halo-width"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PointAnnotation.textHaloWidth")
            }
        }
    }

    /// The opacity at which the text will be drawn.
    public var textOpacity: Double? {
        didSet {
            do {
                let data = try JSONEncoder().encode(textOpacity)
                let jsonValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                feature.properties?["text-opacity"] = jsonValue
            } catch {
                fatalError("Could not convert to json for keyPath: PointAnnotation.textOpacity")
            }
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