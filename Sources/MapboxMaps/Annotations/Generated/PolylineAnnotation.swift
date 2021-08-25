// swiftlint:disable all
// This file is generated.
import Foundation
import Turf

public struct PolylineAnnotation: Annotation {

    /// Identifier for this annotation
    public let id: String

    /// The geometry backing this annotation
    public var geometry: Turf.Geometry {
        return .lineString(lineString)
    }

    /// The line string backing this annotation
    public var lineString: Turf.LineString

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


    /// Create a polyline annotation with a `Turf.LineString` and an optional identifier.
    public init(id: String = UUID().uuidString, lineString: Turf.LineString) {
        self.id = id
        self.lineString = lineString
    }

    /// Create a polyline annotation with an array of coordinates and an optional identifier.
    public init(id: String = UUID().uuidString, lineCoordinates: [CLLocationCoordinate2D]) {
        let lineString = Turf.LineString(lineCoordinates)
        self.init(id: id, lineString: lineString)
    }

    // MARK: - Style Properties -

    
    /// The display of lines when joining.
    public var lineJoin: LineJoin? {
        get {
            return styles["line-join"].flatMap { $0 as? String }.flatMap { LineJoin(rawValue: $0) }
        }
        set {
            styles["line-join"] = newValue?.rawValue
        }
    }
    
    /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
    public var lineSortKey: Double? {
        get {
            return styles["line-sort-key"] as? Double
        }
        set {
            styles["line-sort-key"] = newValue
        }
    }
    
    /// Blur applied to the line, in pixels.
    public var lineBlur: Double? {
        get {
            return styles["line-blur"] as? Double
        }
        set {
            styles["line-blur"] = newValue
        }
    }
    
    /// The color with which the line will be drawn.
    public var lineColor: ColorRepresentable? {
        get {
            return styles["line-color"].flatMap { $0 as? String }.flatMap { try? JSONDecoder().decode(ColorRepresentable.self, from: $0.data(using: .utf8)!) }
        }
        set {
            styles["line-color"] = newValue.flatMap { try? String(data: JSONEncoder().encode($0), encoding: .utf8) }
        }
    }
    
    /// Draws a line casing outside of a line's actual path. Value indicates the width of the inner gap.
    public var lineGapWidth: Double? {
        get {
            return styles["line-gap-width"] as? Double
        }
        set {
            styles["line-gap-width"] = newValue
        }
    }
    
    /// The line's offset. For linear features, a positive value offsets the line to the right, relative to the direction of the line, and a negative value to the left. For polygon features, a positive value results in an inset, and a negative value results in an outset.
    public var lineOffset: Double? {
        get {
            return styles["line-offset"] as? Double
        }
        set {
            styles["line-offset"] = newValue
        }
    }
    
    /// The opacity at which the line will be drawn.
    public var lineOpacity: Double? {
        get {
            return styles["line-opacity"] as? Double
        }
        set {
            styles["line-opacity"] = newValue
        }
    }
    
    /// Name of image in sprite to use for drawing image lines. For seamless patterns, image width must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    public var linePattern: String? {
        get {
            return styles["line-pattern"] as? String
        }
        set {
            styles["line-pattern"] = newValue
        }
    }
    
    /// Stroke thickness.
    public var lineWidth: Double? {
        get {
            return styles["line-width"] as? Double
        }
        set {
            styles["line-width"] = newValue
        }
    }

}

// End of generated file.
// swiftlint:enable all