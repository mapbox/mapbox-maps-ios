import XCTest
import CoreLocation
import Turf

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsFoundation
#endif

// Disabling rules against force try for test file.
// swiftlint:disable explicit_top_level_acl explicit_acl force_try
class MultiPolygonTests: XCTestCase {

    func testMultiPolygonFeature() {
        let data = try! Fixture.geojsonData(from: "multipolygon")!
        let firstCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let lastCoordinate = CLLocationCoordinate2D(latitude: 11, longitude: 11)

        let geojson = try! GeoJSON.parse(Feature.self, from: data)

        XCTAssert(geojson.geometry.type == .MultiPolygon)
        guard case let .multiPolygon(multipolygonCoordinates) = geojson.geometry else {
            XCTFail("Failed to create MultiPolygon.")
            return
        }

        XCTAssert(multipolygonCoordinates.coordinates.first?.first?.first == firstCoordinate)
        XCTAssert(multipolygonCoordinates.coordinates.last?.last?.last == lastCoordinate)

        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! GeoJSON.parse(Feature.self, from: encodedData)
        guard case let .multiPolygon(decodedMultipolygonCoordinates) = decoded.geometry else {
            XCTFail("Failed to decode MultiPolygon.")
            return
        }
        XCTAssert(decodedMultipolygonCoordinates.coordinates.first?.first?.first == firstCoordinate)
        XCTAssert(decodedMultipolygonCoordinates.coordinates.last?.last?.last == lastCoordinate)
    }

    func testBuildMultiPolygonFeature() {
        let coordinates =
        [
            [
                [
                    CLLocationCoordinate2D(latitude: 0, longitude: 0),
                    CLLocationCoordinate2D(latitude: 0, longitude: 5),
                    CLLocationCoordinate2D(latitude: 0, longitude: 5),
                    CLLocationCoordinate2D(latitude: 0, longitude: 10),
                    CLLocationCoordinate2D(latitude: 10, longitude: 10),
                    CLLocationCoordinate2D(latitude: 10, longitude: 0),
                    CLLocationCoordinate2D(latitude: 5, longitude: 0),
                    CLLocationCoordinate2D(latitude: 0, longitude: 0)
                ], [
                    CLLocationCoordinate2D(latitude: 5, longitude: 1),
                    CLLocationCoordinate2D(latitude: 7, longitude: 1),
                    CLLocationCoordinate2D(latitude: 8.5, longitude: 1),
                    CLLocationCoordinate2D(latitude: 8.5, longitude: 4.5),
                    CLLocationCoordinate2D(latitude: 7, longitude: 4.5),
                    CLLocationCoordinate2D(latitude: 5, longitude: 4.5),
                    CLLocationCoordinate2D(latitude: 5, longitude: 1)
                ]
            ], [
                [
                    CLLocationCoordinate2D(latitude: 11, longitude: 11),
                    CLLocationCoordinate2D(latitude: 11.5, longitude: 11.5),
                    CLLocationCoordinate2D(latitude: 12, longitude: 12),
                    CLLocationCoordinate2D(latitude: 11, longitude: 12),
                    CLLocationCoordinate2D(latitude: 11, longitude: 11.5),
                    CLLocationCoordinate2D(latitude: 11, longitude: 11),
                    CLLocationCoordinate2D(latitude: 11, longitude: 11)
                ]
            ]
        ]

        var multiPolygonFeature = Feature(MultiPolygon(coordinates))
        multiPolygonFeature.identifier = FeatureIdentifier.string("uniqueIdentifier")
        multiPolygonFeature.properties = ["some": "var"]

        let encodedData = try! JSONEncoder().encode(multiPolygonFeature)
        let decodedCustomMultiPolygon = try! GeoJSON.parse(Feature.self, from: encodedData)

        let data = try! Fixture.geojsonData(from: "multipolygon")!
        let bundledMultiPolygon = try! GeoJSON.parse(Feature.self, from: data)
        guard case let .multiPolygon(bundledMultipolygonCoordinates) = bundledMultiPolygon.geometry else {
            XCTFail("Failed to create MultiPolygon from bundled MultiPolygon.")
            return
        }

        XCTAssert(decodedCustomMultiPolygon.geometry.type == .MultiPolygon)
        guard case let .multiPolygon(decodedMultipolygonCoordinates) = decodedCustomMultiPolygon.geometry else {
            XCTFail("Failed to create decoded MultiPolygon.")
            return
        }
        XCTAssertEqual(decodedMultipolygonCoordinates, bundledMultipolygonCoordinates)
    }
}
