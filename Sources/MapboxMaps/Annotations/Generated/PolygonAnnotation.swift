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

    /// Property to determine annotation state
    public var isSelected: Bool = false

    /// Property to determine whether annotation is selected
    public var isSelectable: Bool = false

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
    public init(id: String = UUID().uuidString, polygon: Polygon) {
        self.id = id
        self.polygon = polygon
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

    func getOffsetGeometry(view: MapView, moveDistancesObject: MoveDistancesObject?) -> Polygon? {
        let maxMercatorLatitude = 85.05112877980659
        let minMercatorLatitude = -85.05112877980659

        guard let moveDistancesObject = moveDistancesObject else { return nil}

        let points = self.polygon.outerRing.coordinates
        if points.isEmpty {
            return nil
        }

        let latitudeSum = points.map { $0.latitude }.reduce(0, +)
        let longitudeSum = points.map { $0.longitude }.reduce(0, +)

        let latitudeAverage = latitudeSum / CGFloat(points.count)
        let longitudeAverage = longitudeSum / CGFloat(points.count)

        // calculate center point from existing shape
        let averageCoordinates = CLLocationCoordinate2D(latitude: latitudeAverage, longitude: longitudeAverage)

        let centerPoint = Point(averageCoordinates)

        // convert coordinate to point
        let centerScreenCoordinate = view.mapboxMap.point(for: centerPoint.coordinates)


        let targetCoordinates = view.mapboxMap.coordinate(for: CGPoint(x: moveDistancesObject.currentX, y: moveDistancesObject.currentY)
        )

        print("target coordinate: ", targetCoordinates)


        let targetPoint = Point(targetCoordinates)

        let shiftMercatorCoordinate = ConvertUtils.calculateMercatorCoordinateShift(startPoint: centerPoint, endPoint: targetPoint, zoomLevel: view.mapboxMap.cameraState.zoom)

        let targetPoints = points.map {ConvertUtils.shiftPointWithMercatorCoordinate(point: Point($0), shiftMercatorCoordinate: shiftMercatorCoordinate, zoomLevel: view.mapboxMap.cameraState.zoom)}


        if targetPoints.contains(where: {$0.coordinates.latitude > maxMercatorLatitude || $0.coordinates.latitude < minMercatorLatitude }) {
            return nil
        }

        return Polygon([targetPoints.map {$0.coordinates}])
    }

}

// End of generated file.
