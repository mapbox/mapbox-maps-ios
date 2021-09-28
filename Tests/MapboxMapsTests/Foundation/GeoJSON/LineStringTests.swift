import XCTest
import CoreLocation
@testable import MapboxMaps

// swiftlint:disable explicit_top_level_acl explicit_acl force_try
let metersPerMile: CLLocationDistance = 1_609.344

class LineStringTests: XCTestCase {

    func testLineStringFeature() {
        let data = try! Fixture.geojsonData(from: "simple-line")!
        let geojson = try! JSONDecoder().decode(Feature.self, from: data)

        guard case let .lineString(lineStringCoordinates) = geojson.geometry else {
            XCTFail("Failed to create a LineString.")
            return
        }

        XCTAssert(lineStringCoordinates.coordinates.count == 6)
        let first = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let last = CLLocationCoordinate2D(latitude: 10, longitude: 0)
        XCTAssert(lineStringCoordinates.coordinates.first == first)
        XCTAssert(lineStringCoordinates.coordinates.last == last)
        XCTAssertEqual(geojson.identifier, "1")

        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! JSONDecoder().decode(Feature.self, from: encodedData)
        guard case let .lineString(decodedLineStringCoordinates) = decoded.geometry else {
            XCTFail("Failed to create a LineString.")
            return
        }

        XCTAssertEqual(lineStringCoordinates, decodedLineStringCoordinates)
        XCTAssertEqual(geojson.identifier, decoded.identifier)
    }
}
// 
