import XCTest
import CoreLocation
@testable import MapboxMaps

// Disabling rules against force try for test file.
// swiftlint:disable explicit_top_level_acl explicit_acl force_try
class MultiPointTests: XCTestCase {

    func testMultiPointFeature() {
        let data = try! Fixture.geojsonData(from: "multipoint")!
        let firstCoordinate = CLLocationCoordinate2D(latitude: 26.194876675795218, longitude: 14.765625)
        let lastCoordinate = CLLocationCoordinate2D(latitude: 24.926294766395593, longitude: 17.75390625)

        let geojson = try! GeoJSON.parse(Feature.self, from: data)

        XCTAssert(geojson.geometry.type == .MultiPoint)
        guard case let .multiPoint(multipointCoordinates) = geojson.geometry else {
            XCTFail("Failed to create MultiPoint.")
            return
        }
        XCTAssert(multipointCoordinates.coordinates.first == firstCoordinate)
        XCTAssert(multipointCoordinates.coordinates.last == lastCoordinate)

        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! GeoJSON.parse(Feature.self, from: encodedData)
        guard case let .multiPoint(decodedMultipointCoordinates) = decoded.geometry else {
            XCTFail("Failed to create MultiPoint.")
            return
        }
        XCTAssert(decodedMultipointCoordinates.coordinates.first == firstCoordinate)
        XCTAssert(decodedMultipointCoordinates.coordinates.last == lastCoordinate)
    }
}
