/// An object representing points, curves, and surfaces in coordinate space. Use an instance of this enumeration whenever a value could be any kind of Geometry object.
public typealias Geometry = Turf.Geometry

extension Geometry {

    /// Allows a Turf object to be initialized with an internal `Geometry` object.
    /// - Parameter geometry: The `Geometry` object to transform.
    internal init?(_ geometry: MapboxCommon.Geometry) {
        let optionalResult: Geometry?
        switch geometry.geometryType {
        case GeometryType_Point:
            optionalResult = geometry.extractLocations().map {
                .point(Point($0.coordinateValue()))
            }
        case GeometryType_Line:
            optionalResult = geometry.extractLocationsArray().map {
                .lineString(LineString($0.map { $0.coordinateValue() }))
            }
        case GeometryType_Polygon:
            optionalResult = geometry.extractLocations2DArray().map {
                .polygon(Polygon($0.map(NSValue.toCoordinates(array:))))
            }
        case GeometryType_MultiPoint:
            optionalResult = geometry.extractLocationsArray().map {
                .multiPoint(MultiPoint($0.map({ $0.coordinateValue() })))
            }
        case GeometryType_MultiLine:
            optionalResult = geometry.extractLocations2DArray().map {
                .multiLineString(MultiLineString($0.map(NSValue.toCoordinates(array:))))
            }
        case GeometryType_MultiPolygon:
            optionalResult = geometry.extractLocations3DArray().map {
                .multiPolygon(MultiPolygon($0.map(NSValue.toCoordinates2D(array:))))
            }
        case GeometryType_GeometryCollection:
            optionalResult = geometry.extractGeometriesArray().map {
                .geometryCollection(GeometryCollection(geometries: $0.compactMap(Geometry.init(_:))))
            }
        default:
            optionalResult = nil
        }

        guard let result = optionalResult else {
            return nil
        }
        self = result
    }
}

extension MapboxCommon.Geometry {

    /// Allows a `MapboxCommon.Geometry` to be initialized with a `GeometryConvertible`.
    /// - Parameter geometry: The `GeometryConvertible` to transform into a `MapboxCommon.Geometry`.
    internal convenience init(_ geometry: GeometryConvertible) {
        switch geometry.geometry {
        case .point(let point):
            self.init(point: point.coordinates.toValue())
        case .lineString(let line):
            self.init(line: line.coordinates.map { $0.toValue() })
        case .polygon(let polygon):
            self.init(polygon: polygon.coordinates.map { $0.map { $0.toValue() } })
        case .multiPoint(let multiPoint):
            self.init(multiPoint: multiPoint.coordinates.map { $0.toValue() })
        case .multiLineString(let multiLine):
            self.init(multiLine: multiLine.coordinates.map { $0.map { $0.toValue() } })
        case .multiPolygon(let multiPolygon):
            self.init(multiPolygon: multiPolygon.coordinates.map { $0.map { $0.map { $0.toValue() } } })
        case .geometryCollection(let geometryCollection):
            self.init(geometryCollection: geometryCollection.geometries.map(MapboxCommon.Geometry.init(_:)))

        #if USING_TURF_WITH_LIBRARY_EVOLUTION
        @unknown default:
            fatalError("Could not determine Geometry from given Turf Geometry")
        #endif
        }
    }
}

extension Geometry {
    /// Collects all coordinates for this geometry.
    var coordinates: [CLLocationCoordinate2D] {
        switch self {
        case .point(let point):
            return [point.coordinates]
        case .lineString(let lineString):
            return lineString.coordinates
        case .polygon(let polygon):
            return polygon.coordinates.flatMap { $0 }
        case .multiPoint(let multipoint):
            return multipoint.coordinates
        case .multiLineString(let multiLineString):
            return multiLineString.coordinates.flatMap { $0 }
        case .multiPolygon(let multiPolygon):
            return multiPolygon.coordinates.flatMap { $0.flatMap { $0 } }
        case .geometryCollection(let geometryCollection):
            return geometryCollection.geometries.flatMap { $0.coordinates }
        #if USING_TURF_WITH_LIBRARY_EVOLUTION
        @unknown default:
            return []
        #endif
        }
    }
}
