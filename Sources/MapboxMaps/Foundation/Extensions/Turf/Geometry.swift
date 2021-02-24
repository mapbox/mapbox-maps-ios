import Turf
import MapboxCommon

// swiftlint:disable cyclomatic_complexity

// MARK: - Geometry

extension Geometry {

    /// Allows a Turf object to be initialized with an internal `MBXGeometry` object.
    /// - Parameter geometry: The `MBXGeometry` object to transform.
    public init?(_ geometry: MBXGeometry) {
        switch geometry.geometryType {
        case MBXGeometryType_Point:
            guard let coordinate = geometry.extractLocations()?.coordinateValue() else {
                return nil
            }

            self = Geometry.point(Point(coordinate))

        case MBXGeometryType_Line:
            guard let coordinates = geometry.extractLocationsArray()?.map({ $0.coordinateValue() }) else {
                return nil
            }

            self = Geometry.lineString(LineString(coordinates))

        case MBXGeometryType_Polygon:
            guard let coordinates = geometry.extractLocations2DArray()?.map(NSValue.toCoordinates(array:)) else {
                return nil
            }

            self = Geometry.polygon(Polygon(coordinates))

        case MBXGeometryType_MultiPoint:
            guard let coordinates = geometry.extractLocationsArray()?.map({ $0.coordinateValue() }) else {
                return nil
            }

            self = Geometry.multiPoint(MultiPoint(coordinates))

        case MBXGeometryType_MultiLine:
            guard let coordinates = geometry.extractLocations2DArray()?.map(NSValue.toCoordinates(array:)) else {
                return nil
            }

            self = Geometry.multiLineString(MultiLineString(coordinates))

        case MBXGeometryType_MultiPolygon:
            guard let coordinates = geometry.extractLocations3DArray()?.map(NSValue.toCoordinates2D(array:)) else {
                return nil
            }

            self = Geometry.multiPolygon(MultiPolygon(coordinates))

        case MBXGeometryType_GeometryCollection:
            guard let geometries = geometry.extractGeometriesArray()?.compactMap({ Geometry($0) }) else {
                return nil
            }

            self = Geometry.geometryCollection(GeometryCollection(geometries: geometries))

        default:
            return nil
        }
    }
}
