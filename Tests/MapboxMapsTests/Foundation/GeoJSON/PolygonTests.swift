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
class PolygonTests: XCTestCase {

    func testPolygonFeature() {
        let data = try! Fixture.geojsonData(from: "polygon")!
        let geojson = try! GeoJSON.parse(Feature.self, from: data)

        let firstCoordinate = CLLocationCoordinate2D(latitude: 37.00255267215955, longitude: -109.05029296875)
        let lastCoordinate = CLLocationCoordinate2D(latitude: 40.6306300839918, longitude: -108.56689453125)

        XCTAssert((geojson.identifier!.value as! Number).value! as! Double == 1.01)

        guard case let .polygon(polygon) = geojson.geometry else {
            XCTFail("Failed to create polygon.")
            return
        }
        XCTAssert(polygon.outerRing.coordinates.first == firstCoordinate)
        XCTAssert(polygon.innerRings.last?.coordinates.last == lastCoordinate)
        XCTAssert(polygon.outerRing.coordinates.count == 5)
        XCTAssert(polygon.innerRings.first?.coordinates.count == 5)

        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! GeoJSON.parse(Feature.self, from: encodedData)
        guard case let .polygon(decodedPolygon) = decoded.geometry else {
                   XCTFail("Failed to create polygon")
                   return
               }

        XCTAssertEqual(polygon, decodedPolygon)
        XCTAssertEqual(geojson.identifier!.value as! Number, decoded.identifier!.value! as! Number)
        XCTAssert(decodedPolygon.outerRing.coordinates.first == firstCoordinate)
        XCTAssert(decodedPolygon.innerRings.last?.coordinates.last == lastCoordinate)
        XCTAssert(decodedPolygon.outerRing.coordinates.count == 5)
        XCTAssert(decodedPolygon.innerRings.first?.coordinates.count == 5)
    }
}
