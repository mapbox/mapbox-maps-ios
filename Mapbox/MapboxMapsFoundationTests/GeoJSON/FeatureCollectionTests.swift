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
class FeatureCollectionTests: XCTestCase {

    func testFeatureCollection() {
        let data = try! Fixture.geojsonData(from: "featurecollection")!
        let geojson = try! GeoJSON.parse(FeatureCollection.self, from: data)

        XCTAssert(geojson.features[0].geometry.type == .LineString)
        XCTAssert(geojson.features[1].geometry.type == .Polygon)
        XCTAssert(geojson.features[2].geometry.type == .Polygon)
        XCTAssert(geojson.features[3].geometry.type == .Point)

        let lineStringFeature = geojson.features[0]
        guard case let .lineString(lineStringCoordinates) = lineStringFeature.geometry else {
            XCTFail("Failed to create LineString.")
            return
        }
        XCTAssert(lineStringCoordinates.coordinates.count == 19)
        XCTAssert(lineStringFeature.properties!["id"] as! Int == 1)
        XCTAssert(lineStringCoordinates.coordinates.first!.latitude == -26.17500493262446)
        XCTAssert(lineStringCoordinates.coordinates.first!.longitude == 27.977542877197266)

        let polygonFeature = geojson.features[1]
        guard case let .polygon(polygonCoordinates) = polygonFeature.geometry else {
            XCTFail("Failed to create a Polygon.")
            return
        }
        XCTAssert(polygonFeature.properties!["id"] as! Int == 2)
        XCTAssert(polygonCoordinates.coordinates[0].count == 21)
        XCTAssert(polygonCoordinates.coordinates[0].first!.latitude == -26.199035448897074)
        XCTAssert(polygonCoordinates.coordinates[0].first!.longitude == 27.972049713134762)

        let pointFeature = geojson.features[3]
        guard case let .point(pointCoordinates) = pointFeature.geometry else {
            XCTFail("Failed to create a Point.")
            return
        }
        XCTAssert(pointFeature.properties!["id"] as! Int == 4)
        XCTAssert(pointCoordinates.coordinates.latitude == -26.152510345365126)
        XCTAssert(pointCoordinates.coordinates.longitude == 27.95642852783203)
    }

    func testDecodedFeatureCollection() {
        let data = try! Fixture.geojsonData(from: "featurecollection")!
        let geojson = try! GeoJSON.parse(FeatureCollection.self, from: data)

        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! GeoJSON.parse(FeatureCollection.self, from: encodedData)

        XCTAssert(decoded.features[0].geometry.type == .LineString)
        XCTAssert(decoded.features[1].geometry.type == .Polygon)
        XCTAssert(decoded.features[2].geometry.type == .Polygon)
        XCTAssert(decoded.features[3].geometry.type == .Point)

        let decodedLineStringFeature = decoded.features[0]
        guard case let .lineString(decodedLineStringCoordinates) = decodedLineStringFeature.geometry else {
                   XCTFail("Failed to decode LineString.")
                   return
               }
        XCTAssert(decodedLineStringCoordinates.coordinates.count == 19)
        XCTAssert(decodedLineStringFeature.properties!["id"] as! Int == 1)
        XCTAssert(decodedLineStringCoordinates.coordinates.first!.latitude == -26.17500493262446)
        XCTAssert(decodedLineStringCoordinates.coordinates.first!.longitude == 27.977542877197266)

        let decodedPolygonFeature = decoded.features[1]
        guard case let .polygon(decodedPolygonCoordinates) = decodedPolygonFeature.geometry else {
            XCTFail("Failed to decode Polygon.")
            return
        }
        XCTAssert(decodedPolygonFeature.properties!["id"] as! Int == 2)
        XCTAssert(decodedPolygonCoordinates.coordinates[0].count == 21)
        XCTAssert(decodedPolygonCoordinates.coordinates[0].first!.latitude == -26.199035448897074)
        XCTAssert(decodedPolygonCoordinates.coordinates[0].first!.longitude == 27.972049713134762)

        let decodedPointFeature = decoded.features[3]
        guard case let .point(decodedPointCoordinates) = decodedPointFeature.geometry else {
            XCTFail("Failed to decode Point.")
            return
        }
        XCTAssert(decodedPointFeature.properties!["id"] as! Int == 4)
        XCTAssert(decodedPointCoordinates.coordinates.latitude == -26.152510345365126)
        XCTAssert(decodedPointCoordinates.coordinates.longitude == 27.95642852783203)
    }

    func testFeatureCollectionDecodeWithoutProperties() {
        let data = try! Fixture.geojsonData(from: "featurecollection-no-properties")!
        let geojson = try! GeoJSON.parse(data)
        XCTAssert(geojson.decoded is FeatureCollection)
    }

    func testUnkownFeatureCollection() {
        let data = try! Fixture.geojsonData(from: "featurecollection")!
        let geojson = try! GeoJSON.parse(data)
        XCTAssert(geojson.decoded is FeatureCollection)
    }

    func testPerformanceDecodeFeatureCollection() {
        let data = try! Fixture.geojsonData(from: "featurecollection")!

        measure {
            for _ in 0...100 {
                _ = try! GeoJSON.parse(FeatureCollection.self, from: data)
            }
        }
    }

    func testPerformanceEncodeFeatureCollection() {
        let data = try! Fixture.geojsonData(from: "featurecollection")!
        let decoded = try! GeoJSON.parse(FeatureCollection.self, from: data)

        measure {
            for _ in 0...100 {
                _ = try! JSONEncoder().encode(decoded)
            }
        }
    }

    func testPerformanceDecodeEncodeFeatureCollection() {
        let data = try! Fixture.geojsonData(from: "featurecollection")!

        measure {
            for _ in 0...100 {
                let decoded = try! GeoJSON.parse(FeatureCollection.self, from: data)
                _ = try! JSONEncoder().encode(decoded)
            }
        }
    }
}
