import XCTest
@testable import MapboxMaps

//swiftlint:disable explicit_acl explicit_top_level_acl
class GestureUtilitiesTests: XCTestCase {

    func testAngleBetweenPoints() {
        let pointA = CGPoint(x: 0, y: 0)
        let pointB = CGPoint(x: 100, y: 100)

        if let angleBetweenPoints = GestureUtilities.angleBetweenPoints(pointA, pointB) {
            XCTAssertEqual(angleBetweenPoints, 45)
        } else {
            XCTFail("Could not infer CLLocationDegrees from type Double")
        }
    }

}
