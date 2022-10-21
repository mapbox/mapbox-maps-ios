// This file is generated.
import Foundation

public struct PolylineAnnotation: Annotation {

    /// Identifier for this annotation
    public let id: String

    /// The geometry backing this annotation
    public var geometry: Geometry {
        return .lineString(lineString)
    }

    /// The line string backing this annotation
    public var lineString: LineString

    /// Properties associated with the annotation
    public var userInfo: [String: Any]?

    /// Storage for layer properties
    internal var layerProperties: [String: Any] = [:]

    /// Property to determine whether annotation is selected
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

    /// Create a polyline annotation with a `LineString` and an optional identifier.
    public init(id: String = UUID().uuidString, lineString: LineString) {
        self.id = id
        self.lineString = lineString
    }

    /// Create a polyline annotation with an array of coordinates and an optional identifier.
    public init(id: String = UUID().uuidString, lineCoordinates: [CLLocationCoordinate2D]) {
        let lineString = LineString(lineCoordinates)
        self.init(id: id, lineString: lineString)
    }

    // MARK: - Style Properties -

    /// The display of lines when joining.
    public var lineJoin: LineJoin? {
        get {
            return layerProperties["line-join"].flatMap { $0 as? String }.flatMap(LineJoin.init(rawValue:))
        }
        set {
            layerProperties["line-join"] = newValue?.rawValue
        }
    }

    /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
    public var lineSortKey: Double? {
        get {
            return layerProperties["line-sort-key"] as? Double
        }
        set {
            layerProperties["line-sort-key"] = newValue
        }
    }

    /// Blur applied to the line, in pixels.
    public var lineBlur: Double? {
        get {
            return layerProperties["line-blur"] as? Double
        }
        set {
            layerProperties["line-blur"] = newValue
        }
    }

    /// The color with which the line will be drawn.
    public var lineColor: StyleColor? {
        get {
            return layerProperties["line-color"].flatMap { $0 as? String }.flatMap(StyleColor.init(rgbaString:))
        }
        set {
            layerProperties["line-color"] = newValue?.rgbaString
        }
    }

    /// Draws a line casing outside of a line's actual path. Value indicates the width of the inner gap.
    public var lineGapWidth: Double? {
        get {
            return layerProperties["line-gap-width"] as? Double
        }
        set {
            layerProperties["line-gap-width"] = newValue
        }
    }

    /// The line's offset. For linear features, a positive value offsets the line to the right, relative to the direction of the line, and a negative value to the left. For polygon features, a positive value results in an inset, and a negative value results in an outset.
    public var lineOffset: Double? {
        get {
            return layerProperties["line-offset"] as? Double
        }
        set {
            layerProperties["line-offset"] = newValue
        }
    }

    /// The opacity at which the line will be drawn.
    public var lineOpacity: Double? {
        get {
            return layerProperties["line-opacity"] as? Double
        }
        set {
            layerProperties["line-opacity"] = newValue
        }
    }

    /// Name of image in sprite to use for drawing image lines. For seamless patterns, image width must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    public var linePattern: String? {
        get {
            return layerProperties["line-pattern"] as? String
        }
        set {
            layerProperties["line-pattern"] = newValue
        }
    }

    /// Stroke thickness.
    public var lineWidth: Double? {
        get {
            return layerProperties["line-width"] as? Double
        }
        set {
            layerProperties["line-width"] = newValue
        }
    }


    /// Get the offset geometry for the touch point
    func getOffsetGeometry(mapboxMap: MapboxMap, moveDistancesObject: MoveDistancesObject?) -> Geometry? {
        let maxMercatorLatitude = 85.05112877980659
        let minMercatorLatitude = -85.05112877980659

        guard let moveDistancesObject = moveDistancesObject else { return nil}

           let points = self.lineString.coordinates

        if points.isEmpty {
            return nil
        }

        let latitudeSum = points.map { $0.latitude }.reduce(0, +)
        let longitudeSum = points.map { $0.longitude }.reduce(0, +)

        let latitudeAverage = latitudeSum / CGFloat(points.count)
        let longitudeAverage = longitudeSum / CGFloat(points.count)

        let averageCoordinates = CLLocationCoordinate2D(latitude: latitudeAverage, longitude: longitudeAverage)

        let centerPoint = Point(averageCoordinates)

        let centerScreenCoordinate = mapboxMap.point(for: centerPoint.coordinates)

        let targetCoordinates =  mapboxMap.coordinate(for: CGPoint(x: centerScreenCoordinate.x - moveDistancesObject.distanceXSinceLast, y: centerScreenCoordinate.y - moveDistancesObject.distanceYSinceLast))

        let targetPoint = Point(targetCoordinates)

        let shiftMercatorCoordinate = Projection.calculateMercatorCoordinateShift(startPoint: centerPoint, endPoint: targetPoint, zoomLevel: mapboxMap.cameraState.zoom)

        let targetPoints = points.map {Projection.shiftPointWithMercatorCoordinate(point: Point($0), shiftMercatorCoordinate: shiftMercatorCoordinate, zoomLevel: mapboxMap.cameraState.zoom)}

        if targetPoints.contains(where: {$0.coordinates.latitude > maxMercatorLatitude || $0.coordinates.latitude < minMercatorLatitude }) {
            return nil
        }
        return Geometry(LineString(.init(coordinates: targetPoints.map {$0.coordinates})))
    }
}

// End of generated file.
