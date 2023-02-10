import XCTest
@testable import MapboxMaps

class UtilsTests: XCTestCase {

    func testWrapWithValueGreaterThanMaxValue() throws {
        let wrappedValue = Utils.wrap(forValue: 361.0, min: 0.0, max: 360.0)
        XCTAssert(wrappedValue == 1.0)
    }

    func testWrapWithValueLesserThanMinValue() throws {
        let wrappedValue = Utils.wrap(forValue: -1.0, min: 0.0, max: 360.0)
        XCTAssert(wrappedValue == 359.0)
    }

    func testWrapWithValueEqualToMaxValue() throws {
        let wrappedValue = Utils.wrap(forValue: 360.0, min: 0.0, max: 360.0)
        XCTAssert(wrappedValue == 0.0)
    }

    func testWrapWithValueBetweenMaxAndMinValue() throws {
        let wrappedValue = Utils.wrap(forValue: 45.0, min: 0.0, max: 360.0)
        XCTAssert(wrappedValue == 45.0)
    }

    func testNormalizeWithSameDegree() throws {
        for bearing in (0..<361).map({Double($0)}) {
            let destBearing = -Utils.normalize(angle: -bearing.toRadians(), anchorAngle: CLLocationDirection(floatLiteral: bearing).toRadians()).toDegrees()
            let sourceBearing = Utils.normalize(angle: CLLocationDirection(floatLiteral: bearing).toRadians(), anchorAngle: destBearing.toRadians()).toDegrees()
            let epsilon = 0.0001
            XCTAssertEqual(destBearing, sourceBearing, accuracy: epsilon, "bearing: "+bearing.description)
        }
    }
}
