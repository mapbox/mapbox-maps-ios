import XCTest
@testable import MapboxMaps

final class FeatureExtensionValueTests: XCTestCase {

    func testInitializationWithNils() {
        let featureExtensionValue = FeatureExtensionValue(
            value: nil,
            features: nil)

        XCTAssertNil(featureExtensionValue.value)
        XCTAssertNil(featureExtensionValue.__featureCollection)
    }

    func testInitializationWithWithNonNilValues() throws {
        let value = 99
        let features = Array.testFixture(withLength: 2) { () -> Feature in
            var feature = Feature(geometry: Point(.testConstantValue()))
            feature.identifier = .number(3)
            return feature
        }

        let featureExtensionValue = FeatureExtensionValue(
            value: value,
            features: features)

        XCTAssertEqual(featureExtensionValue.value as? Int, value)
        XCTAssertEqual(featureExtensionValue.__featureCollection?.count, features.count)
    }

    func testNilFeatures() {
        let featureExtensionValue = FeatureExtensionValue(
            __value: nil,
            featureCollection: nil)

        XCTAssertNil(featureExtensionValue.features)
    }

    func testNonNilFeatures() {
        let features = Array.testFixture(withLength: 0) { () -> Feature in
            var feature = Feature(geometry: Point(.testConstantValue()))
            feature.identifier = .number(5)
            return feature
        }.map(MapboxCommon.Feature.init(_:))

        let featureExtensionValue = FeatureExtensionValue(
            __value: nil,
            featureCollection: features)

        XCTAssertEqual(featureExtensionValue.features?.count, features.count)
    }
}
