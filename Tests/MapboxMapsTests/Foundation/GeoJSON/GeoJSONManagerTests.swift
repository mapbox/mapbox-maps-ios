import XCTest
import Turf

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsFoundation
#endif

// Disabling rules against force casting for test file.
// swiftlint:disable explicit_top_level_acl explicit_acl force_try force_cast
class GeoJSONManagerTests: XCTestCase {

    var pointJSON: Data {
        return try! Fixture.geojsonData(from: "point")!
    }

    var collectionJSON: Data {
        return try! Fixture.geojsonData(from: "featurecollection")!
    }

    var pointFeature: Feature {
        return try! GeoJSON.parse(Feature.self, from: pointJSON)
    }

    var featureCollection: FeatureCollection {
        return try! GeoJSON.parse(FeatureCollection.self, from: collectionJSON)
    }

    func testDecodeUnnownMethodDecodesGeoJSONFeatureData() throws {
        // Given
        let potentialFeature: GeoJSONObject?

        // When
        potentialFeature = try! GeoJSONManager.decodeUnknown(pointJSON)

        // Then
        XCTAssertNotNil(potentialFeature)
        XCTAssertTrue(potentialFeature is Feature)
        XCTAssertFalse(potentialFeature is FeatureCollection)
    }

    func testDecodeUnknownMethodDecodesGeoJSONFeatureCollectionData() throws {
        // Given
        let potentialFeatureCollection: GeoJSONObject?

        // When
        potentialFeatureCollection = try! GeoJSONManager.decodeUnknown(collectionJSON)

        // Then
        XCTAssertNotNil(potentialFeatureCollection)
        XCTAssertFalse(potentialFeatureCollection is Feature)
        XCTAssertTrue(potentialFeatureCollection is FeatureCollection)
    }

    func testDecodeKnownMethodDecodesGeoJSONFeatureData() throws {
        // Given
        let potentialFeature: Feature?

        // When
        potentialFeature = try! GeoJSONManager.decodeKnown(pointJSON)

        // Then
        XCTAssertNotNil(potentialFeature)
    }

    func testDecodeKnownMethodDecodesGeoJSONFeatureCollectionData() throws {
        // Given
        let potentialFeatureCollection: FeatureCollection?

        // When
        potentialFeatureCollection = try! GeoJSONManager.decodeKnown(collectionJSON)

        // Then
        XCTAssertNotNil(potentialFeatureCollection)
    }

    func testEncodeDecodeGeoJSONFeature() {
        // Given
        let pointFeature = self.pointFeature

        // When
        let encodedFeatureData = try! GeoJSONManager.encode(pointFeature)
        let decodedFeature: Feature? = try! GeoJSONManager.decodeKnown(encodedFeatureData)

        // Then
        XCTAssertNotNil(decodedFeature)
        XCTAssertEqual(pointFeature.identifier?.value as! Number,
                       decodedFeature?.identifier?.value as! Number)
        XCTAssertEqual(pointFeature.properties?.count, decodedFeature?.properties?.count)
        XCTAssertEqual(pointFeature.geometry.type, decodedFeature?.geometry.type)
    }

    func testEncodeDecodeGeoJSONFeatureCollection() {
        // Given
        let featureCollection = self.featureCollection

        // When
        let encodedFeatureCollectionData = try! GeoJSONManager.encode(featureCollection)
        let decodedFeatureCollection: FeatureCollection? = try! GeoJSONManager.decodeKnown(encodedFeatureCollectionData)

        // Then
        XCTAssertNotNil(decodedFeatureCollection)
        XCTAssertEqual(featureCollection.properties?.count,
                       decodedFeatureCollection?.properties?.count)
        XCTAssertEqual(featureCollection.features.count,
                       decodedFeatureCollection?.features.count)
    }

    func testDecodeToDictionary() {
        // Given
        let pointFeature = self.pointFeature

        // When
        let geoJSONDictionary = try? GeoJSONManager.dictionaryFrom(pointFeature)

        // Then
        guard let dictionary = geoJSONDictionary else {
            XCTFail("Should contain dictionary")
            return
        }

        XCTAssertTrue(geoJSONDictionary!["type"] as! String == "Feature")

        guard let geometry = dictionary["geometry"] as? [String: Any] else {
            XCTFail("Geometry should be [String: Any]")
            return
        }

        XCTAssertNil(geometry["id"])
        XCTAssertNil(geometry["properties"])

        guard let coordinates = geometry["coordinates"] as? [NSNumber] else {
            XCTFail("Could not get coordinates from geometry")
            return
        }

        let point = pointFeature.geometry.value as! Point
        XCTAssertEqual(coordinates[1].doubleValue, point.coordinates.latitude)
        XCTAssertEqual(coordinates[0].doubleValue, point.coordinates.longitude)
    }
}
