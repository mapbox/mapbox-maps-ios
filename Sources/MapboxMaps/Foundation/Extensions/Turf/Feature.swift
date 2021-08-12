import Foundation
import MapboxCommon
import Turf

// MARK: - Feature

extension Turf.Feature {

    /// Initialize a `Turf.Feature` with an `Feature` object.
    /// - Parameter feature: The `Feature` to use to create the `Feature`.
    internal init?(_ feature: MapboxCommon.Feature) {
        guard let geometry = Turf.Geometry(feature.geometry) else { return nil }

        self.init(geometry: geometry)

        /**
         Features may or may not have an identifier. If they have one,
         it is either a number or string value.
         */
        switch feature.identifier {
        case let identifier where identifier is NSNumber:
            guard let value = identifier as? NSNumber else { break }
            self.identifier = FeatureIdentifier.number(Number.double(value.doubleValue))
        case let identifier where identifier is NSString:
            guard let value = identifier as? NSString else { break }
            self.identifier = FeatureIdentifier.string(value as String)
        default:
            break
        }

        properties = feature.properties
    }

    /// Initialize a `Turf.Feature` with a `Point`.
    /// - Parameter point: The `Point` to use to create the `Turf.Feature`.
    internal init(_ point: Point) {
        self.init(geometry: Turf.Geometry.point(point))
    }

    /// Initialize a `Turf.Feature` with a `LineString`.
    /// - Parameter line: The `LineString` to use to create the `Turf.Feature`.
    internal init(_ line: LineString) {
        self.init(geometry: Turf.Geometry.lineString(line))
    }

    /// Initialize a `Turf.Feature` with a `Polygon`.
    /// - Parameter polygon: The `Polygon` to use to create the `Turf.Feature`.
    internal init(_ polygon: Turf.Polygon) {
        self.init(geometry: Turf.Geometry.polygon(polygon))
    }

    /// Initialize a `Turf.Feature` with a `MultiPoint`.
    /// - Parameter multiPoint: The `MultiPoint` to use to create the `Turf.Feature`.
    internal init(_ multiPoint: MultiPoint) {
        self.init(geometry: Turf.Geometry.multiPoint(multiPoint))
    }

    /// Initialize a `Turf.Feature` with a `MultiLineString`.
    /// - Parameter multiLine: The `MultiLineString` to use to create the `Turf.Feature`.
    internal init(_ multiLine: MultiLineString) {
        self.init(geometry: Turf.Geometry.multiLineString(multiLine))
    }

    /// Initialize a `Turf.Feature` with a `MultiPolygon`.
    /// - Parameter multiPolygon: The `MultiPolygon` to use to create the `Turf.Feature`.
    internal init(_ multiPolygon: MultiPolygon) {
        self.init(geometry: Turf.Geometry.multiPolygon(multiPolygon))
    }

    /// Initialize a `Turf.Feature` with a `GeometryCollection`.
    /// - Parameter geometryCollection: The `GeometryCollection` to use to create the `Turf.Feature`.
    internal init(_ geometryCollection: GeometryCollection) {
        self.init(geometry: Turf.Geometry.geometryCollection(geometryCollection))
    }
}

extension MapboxCommon.Feature {
    /// Initialize an `Feature` with a `Turf.Feature`
    internal convenience init?(_ feature: Turf.Feature) {

        let identifier: Any?

        // Features may or may not have an identifier. If they have one,
        // it is either a number or string value.
        switch feature.identifier {
        case let .number(.int(intId)):
            identifier = NSNumber(value: intId)
        case let .number(.double(doubleId)):
            identifier = NSNumber(value: doubleId)
        case let .string(stringId):
            identifier = stringId
        case .none:
            identifier = nil
        #if USING_TURF_WITH_LIBRARY_EVOLUTION
        @unknown default:
            identifier = nil
        #endif
        }

        let geometry = Geometry(geometry: feature.geometry)
        let properties = feature.properties

        guard let nsIdentifier = identifier as? NSObject,
              let nsProperties = properties as? [String: NSObject] else {
            fatalError("Unexpected conversion")
        }

        self.init(identifier: nsIdentifier,
                  geometry: geometry,
                  properties: nsProperties)
    }
}
