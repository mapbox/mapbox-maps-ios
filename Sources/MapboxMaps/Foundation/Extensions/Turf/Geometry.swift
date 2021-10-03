import MapboxCommon

// swiftlint:disable cyclomatic_complexity

// MARK: - Geometry

extension Geometry {

    /// Allows a Turf object to be initialized with an internal `Geometry` object.
    /// - Parameter geometry: The `Geometry` object to transform.
    internal init?(_ geometry: MapboxCommon.Geometry) {
        switch geometry.geometryType {
        case GeometryType_Point:
            guard let coordinate = geometry.extractLocations()?.coordinateValue() else {
                return nil
            }

            self = Geometry.point(Point(coordinate))

        case GeometryType_Line:
            guard let coordinates = geometry.extractLocationsArray()?.map({ $0.coordinateValue() }) else {
                return nil
            }

            self = Geometry.lineString(LineString(coordinates))

        case GeometryType_Polygon:
            guard let coordinates = geometry.extractLocations2DArray()?.map(NSValue.toCoordinates(array:)) else {
                return nil
            }

            self = Geometry.polygon(Polygon(coordinates))

        case GeometryType_MultiPoint:
            guard let coordinates = geometry.extractLocationsArray()?.map({ $0.coordinateValue() }) else {
                return nil
            }

            self = Geometry.multiPoint(MultiPoint(coordinates))

        case GeometryType_MultiLine:
            guard let coordinates = geometry.extractLocations2DArray()?.map(NSValue.toCoordinates(array:)) else {
                return nil
            }

            self = Geometry.multiLineString(MultiLineString(coordinates))

        case GeometryType_MultiPolygon:
            guard let coordinates = geometry.extractLocations3DArray()?.map(NSValue.toCoordinates2D(array:)) else {
                return nil
            }

            self = Geometry.multiPolygon(MultiPolygon(coordinates))

        case GeometryType_GeometryCollection:
            guard let geometries = geometry.extractGeometriesArray()?.compactMap({ Geometry($0) }) else {
                return nil
            }

            self = Geometry.geometryCollection(GeometryCollection(geometries: geometries))

        default:
            return nil
        }
    }
}
