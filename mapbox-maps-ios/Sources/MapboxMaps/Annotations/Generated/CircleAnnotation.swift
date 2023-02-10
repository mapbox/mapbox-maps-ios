// This file is generated.
import Foundation

public struct CircleAnnotation: Annotation {

    /// Identifier for this annotation
    public let id: String

    /// The geometry backing this annotation
    public var geometry: Geometry {
        return .point(point)
    }

    /// The point backing this annotation
    public var point: Point

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

    /// Create a circle annotation with a `Point` and an optional identifier.
    public init(id: String = UUID().uuidString, point: Point, isSelected: Bool = false, isDraggable: Bool = false) {
        self.id = id
        self.point = point
        self.isSelected = isSelected
        self.isDraggable = isDraggable
    }

    /// Create a circle annotation with a center coordinate and an optional identifier
    /// - Parameters:
    ///   - id: Optional identifier for this annotation
    ///   - coordinate: Coordinate where this circle annotation should be centered
    public init(id: String = UUID().uuidString, centerCoordinate: CLLocationCoordinate2D, isSelected: Bool = false, isDraggable: Bool = false) {
        let point = Point(centerCoordinate)
        self.init(id: id, point: point, isSelected: isSelected, isDraggable: isDraggable)
    }

    // MARK: - Style Properties -

    /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
    public var circleSortKey: Double? {
        get {
            return layerProperties["circle-sort-key"] as? Double
        }
        set {
            layerProperties["circle-sort-key"] = newValue
        }
    }

    /// Amount to blur the circle. 1 blurs the circle such that only the centerpoint is full opacity.
    public var circleBlur: Double? {
        get {
            return layerProperties["circle-blur"] as? Double
        }
        set {
            layerProperties["circle-blur"] = newValue
        }
    }

    /// The fill color of the circle.
    public var circleColor: StyleColor? {
        get {
            return layerProperties["circle-color"].flatMap { $0 as? String }.flatMap(StyleColor.init(rgbaString:))
        }
        set {
            layerProperties["circle-color"] = newValue?.rgbaString
        }
    }

    /// The opacity at which the circle will be drawn.
    public var circleOpacity: Double? {
        get {
            return layerProperties["circle-opacity"] as? Double
        }
        set {
            layerProperties["circle-opacity"] = newValue
        }
    }

    /// Circle radius.
    public var circleRadius: Double? {
        get {
            return layerProperties["circle-radius"] as? Double
        }
        set {
            layerProperties["circle-radius"] = newValue
        }
    }

    /// The stroke color of the circle.
    public var circleStrokeColor: StyleColor? {
        get {
            return layerProperties["circle-stroke-color"].flatMap { $0 as? String }.flatMap(StyleColor.init(rgbaString:))
        }
        set {
            layerProperties["circle-stroke-color"] = newValue?.rgbaString
        }
    }

    /// The opacity of the circle's stroke.
    public var circleStrokeOpacity: Double? {
        get {
            return layerProperties["circle-stroke-opacity"] as? Double
        }
        set {
            layerProperties["circle-stroke-opacity"] = newValue
        }
    }

    /// The width of the circle's stroke. Strokes are placed outside of the `circle-radius`.
    public var circleStrokeWidth: Double? {
        get {
            return layerProperties["circle-stroke-width"] as? Double
        }
        set {
            layerProperties["circle-stroke-width"] = newValue
        }
    }

}

// End of generated file.
