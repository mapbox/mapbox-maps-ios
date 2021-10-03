extension Geometry {

    /// Allows a Turf object to be initialized with an internal `Geometry` object.
    /// - Parameter geometry: The `Geometry` object to transform.
    internal init?(_ geometry: MapboxCommon.Geometry) {
        let result: Geometry?
        switch geometry.geometryType {
        case GeometryType_Point:
            result = geometry.extractLocations().map {
                .point(Point($0.coordinateValue()))
            }
        case GeometryType_Line:
            result = geometry.extractLocationsArray().map {
                .lineString(LineString($0.map { $0.coordinateValue() }))
            }
        case GeometryType_Polygon:
            result = geometry.extractLocations2DArray().map {
                .polygon(Polygon($0.map(NSValue.toCoordinates(array:))))
            }
        case GeometryType_MultiPoint:
            result = geometry.extractLocationsArray().map {
                .multiPoint(MultiPoint($0.map({ $0.coordinateValue() })))
            }
        case GeometryType_MultiLine:
            result = geometry.extractLocations2DArray().map {
                .multiLineString(MultiLineString($0.map(NSValue.toCoordinates(array:))))
            }
        case GeometryType_MultiPolygon:
            result = geometry.extractLocations3DArray().map {
                .multiPolygon(MultiPolygon($0.map(NSValue.toCoordinates2D(array:))))
            }
        case GeometryType_GeometryCollection:
            result = geometry.extractGeometriesArray().map {
                .geometryCollection(GeometryCollection(geometries: $0.compactMap(Geometry.init(_:))))
            }
        default:
            result = nil
        }

        guard let result = result else {
            return nil
        }
        self = result
    }
}
