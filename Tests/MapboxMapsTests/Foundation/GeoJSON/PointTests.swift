import XCTest
import CoreLocation
import Turf

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsFoundation
#endif

// Disabling rules against force casting for test file.
// swiftlint:disable explicit_top_level_acl explicit_acl force_try force_cast
class PointTests: XCTestCase {

    func testPointFeature() {
        let data = try! Fixture.geojsonData(from: "point")!
        let geojson = try! GeoJSON.parse(Feature.self, from: data)
        let coordinate = CLLocationCoordinate2D(latitude: 26.194876675795218, longitude: 14.765625)

        guard case let .point(point) = geojson.geometry else {
            XCTFail("Failed to create Point.")
            return
        }
        XCTAssertEqual(point.coordinates, coordinate)
        XCTAssert((geojson.identifier!.value as! Number).value! as! Int == 1)

        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! GeoJSON.parse(Feature.self, from: encodedData)

        XCTAssertEqual(geojson.geometry.value as! Point,
                       decoded.geometry.value as! Point)
        XCTAssertEqual(geojson.identifier!.value as! Number,
                       decoded.identifier!.value as! Number)
    }

    func testUnkownPointFeature() {
        let data = try! Fixture.geojsonData(from: "point")!
        let geojson = try! GeoJSON.parse(data)

        XCTAssert(geojson.decoded is Turf.Feature)
        XCTAssert(geojson.decodedFeature?.geometry.type == .Point)
    }
}
