import CoreLocation
import XCTest
@testable import MapboxMaps

class GeoJSONSourceDataTests: XCTestCase {
    func testStringCoding() throws {
        let original = GeoJSONSourceData.string("foo-string")
        let encodedData = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(GeoJSONSourceData.self, from: encodedData)
        XCTAssertEqual(original, decoded)
    }

    func testFeatureCoding() throws {
        var feature = Feature(geometry: Point(.random()))
        feature.identifier = "foo"
        let original = GeoJSONSourceData.feature(feature)
        let encodedData = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(GeoJSONSourceData.self, from: encodedData)
        XCTAssertEqual(original, decoded)
    }

    func testFeatureCollectionCoding() throws {
        var feature = Feature(geometry: Point(.random()))
        feature.identifier = "foo"
        let original = GeoJSONSourceData.featureCollection(FeatureCollection(features: [feature]))
        let encodedData = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(GeoJSONSourceData.self, from: encodedData)
        XCTAssertEqual(original, decoded)
    }

    func testGeometryCoding() throws {
        let point = Point(.random())
        let original = GeoJSONSourceData.geometry(.point(point))
        let encodedData = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(GeoJSONSourceData.self, from: encodedData)
        XCTAssertEqual(original, decoded)
    }

    func testGeoJSONSourceDataEncodingDecodingURL() throws {
        let data: GeoJSONSourceData = GeoJSONSourceData.url(URL(string: "./lines.geojson")!)
        var source = GeoJSONSource(id: "test-source")
        source.data = data

        let sourceData = try? JSONEncoder().encode(source)
        XCTAssertNotNil(sourceData)

        let decodedSource = try? JSONDecoder().decode(GeoJSONSource.self, from: sourceData!)
        XCTAssertNotNil(decodedSource)
        XCTAssertNotNil(decodedSource)

        if let validData = decodedSource?.data,
           case let GeoJSONSourceData.string(string) = validData {
            XCTAssert(string == "./lines.geojson")
        } else {
            XCTFail("Failed to read decoded geojson fixture.")
        }
    }

    func testGeoJSONSourceDataEncodingDecodingFeature() throws {
        let pointCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        var feature = Feature(geometry: Point(pointCoordinate))
        feature.identifier = FeatureIdentifier.string("id")

        let data: GeoJSONSourceData = GeoJSONSourceData.feature(feature)
        var source = GeoJSONSource(id: "test-source")
        source.data = data

        let sourceData = try? JSONEncoder().encode(source)
        XCTAssertNotNil(sourceData)

        let decodedSource = try? JSONDecoder().decode(GeoJSONSource.self, from: sourceData!)
        XCTAssertNotNil(decodedSource)

        if let validData = decodedSource?.data,
           case let GeoJSONSourceData.feature(feature) = validData {
            XCTAssert(feature.identifier != nil)
            if case .point = feature.geometry {} else {
                XCTFail("Geometry of the decoded feature should be a point.")
            }
        } else {
            XCTFail("Failed to read decoded geojson fixture.")
        }
    }
}
