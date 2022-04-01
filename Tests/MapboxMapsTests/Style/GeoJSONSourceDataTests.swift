import CoreLocation
import XCTest
@testable import MapboxMaps

//swiftlint:disable explicit_acl explicit_top_level_acl
class GeoJSONSourceDataTests: XCTestCase {

    func testGeoJSONSourceDataEncodingDecodingURL() throws {
        let data: GeoJSONSourceData = GeoJSONSourceData.url(URL(string: "./lines.geojson")!)
        var source = GeoJSONSource()
        source.data = data

        let sourceData = try? JSONEncoder().encode(source)
        XCTAssertNotNil(sourceData)

        let decodedSource = try? JSONDecoder().decode(GeoJSONSource.self, from: sourceData!)
        XCTAssertNotNil(decodedSource)
        XCTAssertNotNil(decodedSource)

        if let validData = decodedSource?.data,
           case let GeoJSONSourceData.url(url) = validData {
            XCTAssert(url.path == "./lines.geojson")
        } else {
            XCTFail("Failed to read decoded geojson fixture.")
        }
    }

    func testGeoJSONSourceDataEncodingDecodingFeature() throws {

        let pointCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        var feature = Feature(geometry: Point(pointCoordinate))
        feature.identifier = FeatureIdentifier.string("id")

        let data: GeoJSONSourceData = GeoJSONSourceData.feature(feature)
        var source = GeoJSONSource()
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
