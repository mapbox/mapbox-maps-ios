// This file is generated.
import Foundation

public struct PolygonAnnotation: Annotation {

    /// Identifier for this annotation
    public let id: String

    /// The geometry backing this annotation
    public var geometry: Geometry {
        return .polygon(polygon)
    }

    /// The polygon backing this annotation
    public var polygon: Polygon

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

    /// Create a polygon annotation with a `Polygon` and an optional identifier.
    public init(id: String = UUID().uuidString, polygon: Polygon, isSelected: Bool = false, isDraggable: Bool = false) {
        self.id = id
        self.polygon = polygon
        self.isSelected = isSelected
        self.isDraggable = isDraggable
    }

    // MARK: - Style Properties -

    /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
    public var fillSortKey: Double? {
        get {
            return layerProperties["fill-sort-key"] as? Double
        }
        set {
            layerProperties["fill-sort-key"] = newValue
        }
    }

    /// The color of the filled part of this layer. This color can be specified as `rgba` with an alpha component and the color's opacity will not affect the opacity of the 1px stroke, if it is used.
    public var fillColor: StyleColor? {
        get {
            return layerProperties["fill-color"].flatMap { $0 as? String }.flatMap(StyleColor.init(rgbaString:))
        }
        set {
            layerProperties["fill-color"] = newValue?.rgbaString
        }
    }

    /// The opacity of the entire fill layer. In contrast to the `fill-color`, this value will also affect the 1px stroke around the fill, if the stroke is used.
    public var fillOpacity: Double? {
        get {
            return layerProperties["fill-opacity"] as? Double
        }
        set {
            layerProperties["fill-opacity"] = newValue
        }
    }

    /// The outline color of the fill. Matches the value of `fill-color` if unspecified.
    public var fillOutlineColor: StyleColor? {
        get {
            return layerProperties["fill-outline-color"].flatMap { $0 as? String }.flatMap(StyleColor.init(rgbaString:))
        }
        set {
            layerProperties["fill-outline-color"] = newValue?.rgbaString
        }
    }

    /// Name of image in sprite to use for drawing image fills. For seamless patterns, image width and height must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    public var fillPattern: String? {
        get {
            return layerProperties["fill-pattern"] as? String
        }
        set {
            layerProperties["fill-pattern"] = newValue
        }
    }

}

// End of generated file.
