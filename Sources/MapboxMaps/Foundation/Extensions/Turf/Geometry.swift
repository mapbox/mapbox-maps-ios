import Turf
import MapboxCommon

// swiftlint:disable cyclomatic_complexity

// MARK: - Geometry

public typealias Geometry = MapboxCommon.Geometry

extension Turf.Geometry {

    /// Allows a Turf object to be initialized with an internal `Geometry` object.
    /// - Parameter geometry: The `Geometry` object to transform.
    internal init?(_ geometry: Geometry) {
        switch geometry.geometryType {
        case GeometryType_Point:
            guard let coordinate = geometry.extractLocations()?.coordinateValue() else {
                return nil
            }

            self = Turf.Geometry.point(Point(coordinate))

        case GeometryType_Line:
            guard let coordinates = geometry.extractLocationsArray()?.map({ $0.coordinateValue() }) else {
                return nil
            }

            self = Turf.Geometry.lineString(LineString(coordinates))

        case GeometryType_Polygon:
            guard let coordinates = geometry.extractLocations2DArray()?.map(NSValue.toCoordinates(array:)) else {
                return nil
            }

            self = Turf.Geometry.polygon(Polygon(coordinates))

        case GeometryType_MultiPoint:
            guard let coordinates = geometry.extractLocationsArray()?.map({ $0.coordinateValue() }) else {
                return nil
            }

            self = Turf.Geometry.multiPoint(MultiPoint(coordinates))

        case GeometryType_MultiLine:
            guard let coordinates = geometry.extractLocations2DArray()?.map(NSValue.toCoordinates(array:)) else {
                return nil
            }

            self = Turf.Geometry.multiLineString(MultiLineString(coordinates))

        case GeometryType_MultiPolygon:
            guard let coordinates = geometry.extractLocations3DArray()?.map(NSValue.toCoordinates2D(array:)) else {
                return nil
            }

            self = Turf.Geometry.multiPolygon(MultiPolygon(coordinates))

        case GeometryType_GeometryCollection:
            guard let geometries = geometry.extractGeometriesArray()?.compactMap({ Turf.Geometry($0) }) else {
                return nil
            }

            self = Turf.Geometry.geometryCollection(GeometryCollection(geometries: geometries))

        default:
            return nil
        }
    }
}
