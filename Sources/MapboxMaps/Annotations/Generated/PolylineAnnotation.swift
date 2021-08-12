// swiftlint:disable all
// This file is generated.
import Foundation
import Turf

public struct PolylineAnnotation: Annotation {

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
        get {
            return feature.properties?["line-join"] as? LineJoin 
        }
        set {
            feature.properties?["line-join"] = newValue?.rawValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("line-join")
            } else {
                dataDrivenPropertiesUsedSet.remove("line-join")
            }
        }
    }
    
    /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
    public var lineSortKey: Double? {
        get {
            return feature.properties?["line-sort-key"] as? Double 
        }
        set {
            feature.properties?["line-sort-key"] = newValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("line-sort-key")
            } else {
                dataDrivenPropertiesUsedSet.remove("line-sort-key")
            }
        }
    }
    
    /// Blur applied to the line, in pixels.
    public var lineBlur: Double? {
        get {
            return feature.properties?["line-blur"] as? Double 
        }
        set {
            feature.properties?["line-blur"] = newValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("line-blur")
            } else {
                dataDrivenPropertiesUsedSet.remove("line-blur")
            }
        }
    }
    
    /// The color with which the line will be drawn.
    public var lineColor: ColorRepresentable? {
        get {
            return feature.properties?["line-color"] as? ColorRepresentable 
        }
        set {
            feature.properties?["line-color"] = newValue?.rgbaDescription 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("line-color")
            } else {
                dataDrivenPropertiesUsedSet.remove("line-color")
            }
        }
    }
    
    /// Draws a line casing outside of a line's actual path. Value indicates the width of the inner gap.
    public var lineGapWidth: Double? {
        get {
            return feature.properties?["line-gap-width"] as? Double 
        }
        set {
            feature.properties?["line-gap-width"] = newValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("line-gap-width")
            } else {
                dataDrivenPropertiesUsedSet.remove("line-gap-width")
            }
        }
    }
    
    /// The line's offset. For linear features, a positive value offsets the line to the right, relative to the direction of the line, and a negative value to the left. For polygon features, a positive value results in an inset, and a negative value results in an outset.
    public var lineOffset: Double? {
        get {
            return feature.properties?["line-offset"] as? Double 
        }
        set {
            feature.properties?["line-offset"] = newValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("line-offset")
            } else {
                dataDrivenPropertiesUsedSet.remove("line-offset")
            }
        }
    }
    
    /// The opacity at which the line will be drawn.
    public var lineOpacity: Double? {
        get {
            return feature.properties?["line-opacity"] as? Double 
        }
        set {
            feature.properties?["line-opacity"] = newValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("line-opacity")
            } else {
                dataDrivenPropertiesUsedSet.remove("line-opacity")
            }
        }
    }
    
    /// Name of image in sprite to use for drawing image lines. For seamless patterns, image width must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    public var linePattern: String? {
        get {
            return feature.properties?["line-pattern"] as? String 
        }
        set {
            feature.properties?["line-pattern"] = newValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("line-pattern")
            } else {
                dataDrivenPropertiesUsedSet.remove("line-pattern")
            }
        }
    }
    
    /// Stroke thickness.
    public var lineWidth: Double? {
        get {
            return feature.properties?["line-width"] as? Double 
        }
        set {
            feature.properties?["line-width"] = newValue 
            if newValue != nil {
                dataDrivenPropertiesUsedSet.insert("line-width")
            } else {
                dataDrivenPropertiesUsedSet.remove("line-width")
            }
        }
    }

}

// End of generated file.
// swiftlint:enable all