import Foundation
import MapboxCommon
import Turf

// MARK: - Feature

extension Feature {

    /// Initialize a `Turf.Feature` with an `MBXFeature` object.
    /// - Parameter feature: The `MBXFeature` to use to create the `Feature`.
    public init?(_ feature: MBXFeature) {
        guard let geometry = Geometry(feature.geometry) else { return nil }

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

        self.properties = feature.properties
    }

    /// Initialize a `Turf.Feature` with a `Point`.
    /// - Parameter point: The `Point` to use to create the `Turf.Feature`.
    public init(_ point: Point) {
        self.init(geometry: Geometry.point(point))
    }

    /// Initialize a `Turf.Feature` with a `LineString`.
    /// - Parameter line: The `LineString` to use to create the `Turf.Feature`.
    public init(_ line: LineString) {
        self.init(geometry: Geometry.lineString(line))
    }

    /// Initialize a `Turf.Feature` with a `Polygon`.
    /// - Parameter polygon: The `Polygon` to use to create the `Turf.Feature`.
    public init(_ polygon: Polygon) {
        self.init(geometry: Geometry.polygon(polygon))
    }

    /// Initialize a `Turf.Feature` with a `MultiPoint`.
    /// - Parameter multiPoint: The `MultiPoint` to use to create the `Turf.Feature`.
    public init(_ multiPoint: MultiPoint) {
        self.init(geometry: Geometry.multiPoint(multiPoint))
    }

    /// Initialize a `Turf.Feature` with a `MultiLineString`.
    /// - Parameter multiLine: The `MultiLineString` to use to create the `Turf.Feature`.
    public init(_ multiLine: MultiLineString) {
        self.init(geometry: Geometry.multiLineString(multiLine))
    }

    /// Initialize a `Turf.Feature` with a `MultiPolygon`.
    /// - Parameter multiPolygon: The `MultiPolygon` to use to create the `Turf.Feature`.
    public init(_ multiPolygon: MultiPolygon) {
        self.init(geometry: Geometry.multiPolygon(multiPolygon))
    }

    /// Initialize a `Turf.Feature` with a `GeometryCollection`.
    /// - Parameter geometryCollection: The `GeometryCollection` to use to create the `Turf.Feature`.
    public init(_ geometryCollection: GeometryCollection) {
        self.init(geometry: Geometry.geometryCollection(geometryCollection))
    }
}
