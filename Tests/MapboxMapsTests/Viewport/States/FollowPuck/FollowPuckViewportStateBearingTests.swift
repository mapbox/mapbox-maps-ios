import XCTest
@testable @_spi(Experimental) import MapboxMaps

final class FollowPuckViewportStateBearingTests: XCTestCase {

    func testConstant() {
        let value = CLLocationDirection.random(in: 0..<360)

        let bearing = FollowPuckViewportStateBearing.constant(value)

        XCTAssertEqual(bearing.evaluate(with: .random()), value)
    }

    func testHeading() {
        let location = InterpolatedLocation.random()

        let bearing = FollowPuckViewportStateBearing.heading

        XCTAssertEqual(bearing.evaluate(with: location), location.heading)
    }

    func testCourse() {
        let location = InterpolatedLocation.random()

        let bearing = FollowPuckViewportStateBearing.course

        XCTAssertEqual(bearing.evaluate(with: location), location.course)
    }
}
