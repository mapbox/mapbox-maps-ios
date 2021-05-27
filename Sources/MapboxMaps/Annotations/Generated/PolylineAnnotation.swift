// swiftlint:disable all
// This file is generated.
import Foundation
import Turf

public struct PolylineAnnotation: Annotation {

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

    public var type: AnnotationType = .polyline

    /// Create a polyline annotation with a `Turf.Polyline` and an optional identifier.
    public init(id: String = UUID().uuidString, line: Turf.LineString) {
        self.id = id
        self.feature = Turf.Feature(line)
        self.feature.properties = ["annotation-id": id]
    }

    /// Create a polyline annotation with an array of coordinates and an optional identifier.
    public init(id: String = UUID().uuidString, lineCoordinates: [CLLocationCoordinate2D]) {
        let line = Turf.LineString(lineCoordinates)
        self.init(id: id, line: line)
    }

    // MARK: - Properties -

    /// Set of used data driven properties
    internal var dataDrivenPropertiesUsedSet: Set<String> = []

    
    /// The display of lines when joining.
    public var lineJoin: LineJoin? {
        didSet {
            feature.properties?["line-join"] = lineJoin?.rawValue 
            if lineJoin != nil {
                dataDrivenPropertiesUsedSet.insert("line-join")
            }
        }
    }
    
    /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
    public var lineSortKey: Double? {
        didSet {
            feature.properties?["line-sort-key"] = lineSortKey 
            if lineSortKey != nil {
                dataDrivenPropertiesUsedSet.insert("line-sort-key")
            }
        }
    }
    
    /// Blur applied to the line, in pixels.
    public var lineBlur: Double? {
        didSet {
            feature.properties?["line-blur"] = lineBlur 
            if lineBlur != nil {
                dataDrivenPropertiesUsedSet.insert("line-blur")
            }
        }
    }
    
    /// The color with which the line will be drawn.
    public var lineColor: ColorRepresentable? {
        didSet {
            feature.properties?["line-color"] = lineColor?.rgbaDescription 
            if lineColor != nil {
                dataDrivenPropertiesUsedSet.insert("line-color")
            }
        }
    }
    
    /// Draws a line casing outside of a line's actual path. Value indicates the width of the inner gap.
    public var lineGapWidth: Double? {
        didSet {
            feature.properties?["line-gap-width"] = lineGapWidth 
            if lineGapWidth != nil {
                dataDrivenPropertiesUsedSet.insert("line-gap-width")
            }
        }
    }
    
    /// The line's offset. For linear features, a positive value offsets the line to the right, relative to the direction of the line, and a negative value to the left. For polygon features, a positive value results in an inset, and a negative value results in an outset.
    public var lineOffset: Double? {
        didSet {
            feature.properties?["line-offset"] = lineOffset 
            if lineOffset != nil {
                dataDrivenPropertiesUsedSet.insert("line-offset")
            }
        }
    }
    
    /// The opacity at which the line will be drawn.
    public var lineOpacity: Double? {
        didSet {
            feature.properties?["line-opacity"] = lineOpacity 
            if lineOpacity != nil {
                dataDrivenPropertiesUsedSet.insert("line-opacity")
            }
        }
    }
    
    /// Name of image in sprite to use for drawing image lines. For seamless patterns, image width must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    public var linePattern: String? {
        didSet {
            feature.properties?["line-pattern"] = linePattern 
            if linePattern != nil {
                dataDrivenPropertiesUsedSet.insert("line-pattern")
            }
        }
    }
    
    /// Stroke thickness.
    public var lineWidth: Double? {
        didSet {
            feature.properties?["line-width"] = lineWidth 
            if lineWidth != nil {
                dataDrivenPropertiesUsedSet.insert("line-width")
            }
        }
    }

}

// End of generated file.
// swiftlint:enable all