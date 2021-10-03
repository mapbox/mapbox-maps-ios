import Foundation
import MapboxCommon
import CoreLocation

// MARK: - Geometry

public typealias Geometry = Turf.Geometry

extension MapboxCommon.Geometry {

    /// Allows a `Geometry` object to be initialized with a `Geometry` object.
    /// - Parameter geometry: The `Geometry` object to transform into the `Geometry` type.
    internal convenience init(_ geometry: Geometry) {
        switch geometry {
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
