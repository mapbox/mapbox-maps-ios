// swiftlint:disable all
// This file is generated.
import Foundation

public struct PolygonAnnotation: Annotation {

    /// Identifier for this annotation
    public let id: String

    /// The geometry backing this annotation
    public var geometry: Turf.Geometry {
        return .polygon(polygon)
    }

    /// The polygon backing this annotation
    public var polygon: Turf.Polygon

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


    /// Create a polygon annotation with a `Turf.Polygon` and an optional identifier.
    public init(id: String = UUID().uuidString, polygon: Turf.Polygon) {
        self.id = id
        self.polygon = polygon
    }

    // MARK: - Style Properties -

    
    /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
    public var fillSortKey: Double? {
        get {
            return styles["fill-sort-key"] as? Double
        }
        set {
            styles["fill-sort-key"] = newValue
        }
    }
    
    /// The color of the filled part of this layer. This color can be specified as `rgba` with an alpha component and the color's opacity will not affect the opacity of the 1px stroke, if it is used.
    public var fillColor: ColorRepresentable? {
        get {
            return styles["fill-color"].flatMap { $0 as? String }.flatMap { try? JSONDecoder().decode(ColorRepresentable.self, from: $0.data(using: .utf8)!) }
        }
        set {
            styles["fill-color"] = newValue.flatMap { try? String(data: JSONEncoder().encode($0), encoding: .utf8) }
        }
    }
    
    /// The opacity of the entire fill layer. In contrast to the `fill-color`, this value will also affect the 1px stroke around the fill, if the stroke is used.
    public var fillOpacity: Double? {
        get {
            return styles["fill-opacity"] as? Double
        }
        set {
            styles["fill-opacity"] = newValue
        }
    }
    
    /// The outline color of the fill. Matches the value of `fill-color` if unspecified.
    public var fillOutlineColor: ColorRepresentable? {
        get {
            return styles["fill-outline-color"].flatMap { $0 as? String }.flatMap { try? JSONDecoder().decode(ColorRepresentable.self, from: $0.data(using: .utf8)!) }
        }
        set {
            styles["fill-outline-color"] = newValue.flatMap { try? String(data: JSONEncoder().encode($0), encoding: .utf8) }
        }
    }
    
    /// Name of image in sprite to use for drawing image fills. For seamless patterns, image width and height must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    public var fillPattern: String? {
        get {
            return styles["fill-pattern"] as? String
        }
        set {
            styles["fill-pattern"] = newValue
        }
    }

}

// End of generated file.
// swiftlint:enable all
