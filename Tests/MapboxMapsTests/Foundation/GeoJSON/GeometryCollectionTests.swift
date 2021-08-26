import XCTest
import CoreLocation
@testable import MapboxMaps

// Disabling rules against force try for test file.
// swiftlint:disable explicit_top_level_acl explicit_acl force_try
class GeometryCollectionTests: XCTestCase {

    func testGeometryCollectionFeatureDeserialization() {
        // Arrange
        let data = try! Fixture.geojsonData(from: "geometry-collection")!
        let multiPolygonCoordinate = CLLocationCoordinate2D(latitude: 8.5, longitude: 1)

        // Act
        let geoJSON = try! GeoJSON.parse(data)

        // Assert
        XCTAssert(geoJSON.decoded is Turf.Feature)

        guard let geometryCollectionFeature = geoJSON.decoded as? Turf.Feature else {
            XCTFail("Failed to create Feature.")
            return
        }

        XCTAssert(geometryCollectionFeature.geometry.type == .GeometryCollection)
        XCTAssert(geometryCollectionFeature.geometry.value is GeometryCollection)

        guard case let .geometryCollection(geometries) = geometryCollectionFeature.geometry else {
            XCTFail("Failed to create GeometryCollection.")
            return
        }

        XCTAssert(geometries.geometries[2].type == .MultiPolygon)
        guard case let .multiPolygon(decodedMultiPolygonCoordinate) = geometries.geometries[2] else {
            XCTFail("Failed to create MultiPolygon.")
            return
        }
        XCTAssertEqual(decodedMultiPolygonCoordinate.coordinates[0][1][2], multiPolygonCoordinate)
    }

    func testGeometryCollectionFeatureSerialization() {
        // Arrange
        let multiPolygonCoordinate = CLLocationCoordinate2D(latitude: 8.5, longitude: 1)
        let data = try! Fixture.geojsonData(from: "geometry-collection")!
        let geoJSON = try! GeoJSON.parse(data)

        // Act
        let encodedData = try! JSONEncoder().encode(geoJSON)
        let encodedJSON = try! GeoJSON.parse(encodedData)

        // Assert
        XCTAssert(encodedJSON.decoded is Turf.Feature)

        guard let geometryCollectionFeature = encodedJSON.decoded as? Turf.Feature else {
            XCTFail("Failed to create Feature.")
            return
        }

        XCTAssert(geometryCollectionFeature.geometry.type == .GeometryCollection)
        XCTAssert(geometryCollectionFeature.geometry.value is GeometryCollection)

        guard case let .geometryCollection(geometries) = geometryCollectionFeature.geometry else {
            XCTFail("Failed to create GeometryCollection.")
            return
        }

        XCTAssert(geometries.geometries[2].type == .MultiPolygon)
        guard case let .multiPolygon(decodedMultiPolygonCoordinate) = geometries.geometries[2] else {
            XCTFail("Failed to create MultiPolygon.")
            return
        }
        XCTAssertEqual(decodedMultiPolygonCoordinate.coordinates[0][1][2], multiPolygonCoordinate)
    }
}
