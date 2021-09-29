import XCTest
import CoreLocation
@testable import MapboxMaps

// Disabling rules against force casting for test file.
// swiftlint:disable explicit_top_level_acl explicit_acl force_try
class PointTests: XCTestCase {

    func testPointFeature() {
        let data = try! Fixture.geojsonData(from: "point")!
        let geojson = try! JSONDecoder().decode(Feature.self, from: data)
        let coordinate = CLLocationCoordinate2D(latitude: 26.194876675795218, longitude: 14.765625)

        guard case let .point(point) = geojson.geometry else {
            XCTFail("Failed to create Point.")
            return
        }
        XCTAssertEqual(point.coordinates, coordinate)
        XCTAssertEqual(geojson.identifier, 1)

        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! JSONDecoder().decode(Feature.self, from: encodedData)

        XCTAssertEqual(geojson.geometry, decoded.geometry)
    }

    func testUnkownPointFeature() {
        let data = try! Fixture.geojsonData(from: "point")!
        let geojson = try! JSONDecoder().decode(GeoJSONObject.self, from: data)

        if case let .feature(feature) = geojson,
           case .point = feature.geometry {} else {
            XCTFail("GeoJSON should decode as a point feature.")
        }
    }
}
