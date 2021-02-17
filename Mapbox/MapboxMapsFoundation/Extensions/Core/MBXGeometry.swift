import Foundation
import MapboxCommon
import CoreLocation
import Turf

// MARK: - MBXGeometry

extension MBXGeometry {

    /// Initialize a `MBXGeometry` point from a coordinate.
    /// - Parameter coordinate: The coordinate to represent the `MBXGeometry` point.
    public convenience init(coordinate: CLLocationCoordinate2D) {
        let pointValue = coordinate.toValue()
        self.init(point: pointValue)
    }

    /// Initialize a `MBXGeometry` line from an array of coordinates.
    /// - Parameter coordinates: The coordinates to represent the `MBXGeometry` line.
    public convenience init(line coordinates: [CLLocationCoordinate2D]) {
        let lineValues = CLLocationCoordinate2D.convertToValues(from: coordinates)
        self.init(line: lineValues)
    }

    /// Initialize a `MBXGeometry` polygon from a two-dimensional array of coordinates.
    /// - Parameter coordinates: The coordinates to represent the `MBXGeometry` polygon.
    public convenience init(polygon coordinates: [[CLLocationCoordinate2D]]) {
        let polygons = coordinates.map({ CLLocationCoordinate2D.convertToValues(from: $0) })
        self.init(polygon: polygons)
    }

    /// Initialize a `MBXGeometry` multipoint from an array of `CLLocationCoordinate`s.
    /// - Parameter coordinates: The coordinates to represent the `MBXGeometry` multipoint.
    public convenience init(multiPoint coordinates: [CLLocationCoordinate2D]) {
        let multiPointValue = coordinates.map({ $0.toValue() })
        self.init(multiPoint: multiPointValue)
    }

    /// Initialize a `MBXGeometry` multiline from a two-dimensional array of `CLLocationCoordinate`s.
    /// - Parameter coordinates: The coordinates to represent the `MBXGeometry` multiline.
    public convenience init(multiLine coordinates: [[CLLocationCoordinate2D]]) {
        let multiLineValues = coordinates.map({ CLLocationCoordinate2D.convertToValues(from: $0) })
        self.init(multiLine: multiLineValues)
    }

    /// Initialize a `MBXGeometry` multipolygon from a three-dimensional array of `CLLocationCoordinate`s.
    /// - Parameter coordinates: The coordinates to represent the `MBXGeometry` multipolygon.
    public convenience init(multiPolygon coordinates: [[[CLLocationCoordinate2D]]]) {
        let multiPolygonValues = coordinates.map({
            $0.map({ CLLocationCoordinate2D.convertToValues(from: $0) })
        })
        self.init(multiPolygon: multiPolygonValues)
    }

    /// Allows an `MBXGeometry` object to be initialized with an turf `Geometry` object.
    /// - Parameter geometry: The turf `Geometry` object to transform into the `MBXGeometry` type.
    public convenience init(geometry: Geometry) {
        switch geometry {
        case .point(let point):
            let coordinate = point.coordinates
            self.init(coordinate: coordinate)

        case .lineString(let line):
            self.init(line: line.coordinates)

        case .polygon(let polygon):
            self.init(polygon: polygon.coordinates)

        case .multiPoint(let multiPoint):
            self.init(multiPoint: multiPoint.coordinates)

        case .multiLineString(let multiLine):
            self.init(multiLine: multiLine.coordinates)

        case .multiPolygon(let multiPolygon):
            self.init(multiPolygon: multiPolygon.coordinates)

        case .geometryCollection(let geometryCollection):
            let geometryValues = geometryCollection.geometries.map {( MBXGeometry.init(geometry: $0) )}
            self.init(geometryCollection: geometryValues)
        @unknown default:
            fatalError("Could not determine MBXGeometry from given Turf Geometry")
        }
    }
}
