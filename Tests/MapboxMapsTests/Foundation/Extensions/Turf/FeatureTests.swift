import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class FeatureTests: XCTestCase {

    let geometry = Geometry.point(Point(.random()))

    func testInitializingTurfFeatureFromCommonFeatureNilIdentifier() throws {
        let commonFeature = MapboxCommon.Feature(
            identifier: NSObject(),
            geometry: MapboxCommon.Geometry(geometry),
            properties: [:])

        let feature = try XCTUnwrap(Feature(commonFeature))

        XCTAssertNil(feature.identifier)
    }

    func testInitializingTurfFeatureFromCommonFeatureNumberIdentifier() throws {
        let commonFeature = MapboxCommon.Feature(
            identifier: NSNumber(value: 2.0),
            geometry: MapboxCommon.Geometry(geometry),
            properties: [:])

        let feature = try XCTUnwrap(Feature(commonFeature))

        guard feature.identifier == 2.0 else {
            XCTFail("feature.identifier did not match the expected value")
            return
        }
    }

    func testInitializingTurfFeatureFromCommonFeatureStringIdentifier() throws {
        let commonFeature = MapboxCommon.Feature(
            identifier: NSString(string: "abc"),
            geometry: MapboxCommon.Geometry(geometry),
            properties: [:])

        let feature = try XCTUnwrap(Feature(commonFeature))

        guard case .string("abc") = feature.identifier else {
            XCTFail("feature.identifier did not match the expected value")
            return
        }
    }

    func testInitializingCommonFeatureFromTurfFeatureNilIdentifier() throws {
        var feature = Feature(geometry: geometry)
        feature.identifier = nil

        let commonFeature = MapboxCommon.Feature(feature)

        XCTAssertTrue(commonFeature.identifier.isMember(of: NSObject.self))
    }

    func testInitializingCommonFeatureFromTurfFeatureNumberIdentifier() throws {
        var feature = Feature(geometry: geometry)
        feature.identifier = 2.0

        let commonFeature = MapboxCommon.Feature(feature)

        XCTAssertEqual(commonFeature.identifier, NSNumber(value: 2.0))
    }

    func testInitializingCommonFeatureFromTurfFeatureStringIdentifier() throws {
        var feature = Feature(geometry: geometry)
        feature.identifier = .string("abc")

        let commonFeature = MapboxCommon.Feature(feature)

        XCTAssertEqual(commonFeature.identifier, NSString(string: "abc"))
    }

    func testInitializingCommonFeatureFromTurfFeatureNilProperties() throws {
        var feature = Feature(geometry: geometry)
        feature.properties = nil

        let commonFeature = MapboxCommon.Feature(feature)

        XCTAssertEqual(commonFeature.properties, [:])
    }

    func testInitializingCommonFeatureFromTurfFeatureNonNilProperties() throws {
        var feature = Feature(geometry: geometry)
        feature.properties = [
            "a": 123,
            "b": "c",
            "d": [1, 2, 3],
            "e": ["f": "g"],
            "h": nil]

        let commonFeature = MapboxCommon.Feature(feature)

        XCTAssertEqual(
            commonFeature.properties,
            [
                "a": NSNumber(value: 123),
                "b": NSString(string: "c"),
                "d": NSArray(array: [1, 2, 3]),
                "e": NSDictionary(dictionary: ["f": "g"])])
        XCTAssertFalse(commonFeature.properties.keys.contains("h"))
    }

    func testSetPropertiesWithFunction() throws {
        let feature = Feature(geometry: geometry)
            .properties([
                "a": 123,
                "b": "c",
                "d": [1, 2, 3],
                "e": ["f": "g"],
                "h": nil])

        let commonFeature = MapboxCommon.Feature(feature)

        XCTAssertEqual(
            commonFeature.properties,
            [
                "a": NSNumber(value: 123),
                "b": NSString(string: "c"),
                "d": NSArray(array: [1, 2, 3]),
                "e": NSDictionary(dictionary: ["f": "g"])])
        XCTAssertFalse(commonFeature.properties.keys.contains("h"))
    }
}
