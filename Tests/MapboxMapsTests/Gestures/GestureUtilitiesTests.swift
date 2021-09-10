import XCTest
@testable import MapboxMaps

final class GestureUtilitiesTests: XCTestCase {
    func testAngleBetweenPoints() {
        let pointA = CGPoint(x: 0, y: 0)
        let pointB = CGPoint(x: 100, y: 100)
        XCTAssertEqual(GestureUtilities.angleBetweenPoints(pointA, pointB), 45)
    }
}
