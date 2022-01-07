import XCTest
@testable import MapboxMaps

final class FollowingViewportStateBearingTests: XCTestCase {

    func testConstant() {
        let value = CLLocationDirection.random(in: 0..<360)

        let bearing = FollowingViewportStateBearing.constant(value)

        XCTAssertEqual(bearing.evaluate(with: .random()), value)
    }

    func testHeading() {
        let location = Location.random()

        let bearing = FollowingViewportStateBearing.heading

        XCTAssertEqual(bearing.evaluate(with: location), location.headingDirection)
    }

    func testCourse() {
        let location = Location.random()

        let bearing = FollowingViewportStateBearing.course

        XCTAssertEqual(bearing.evaluate(with: location), location.course)
    }
}
