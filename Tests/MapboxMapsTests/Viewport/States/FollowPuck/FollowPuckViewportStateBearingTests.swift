import XCTest
@testable import MapboxMaps

final class FollowPuckViewportStateBearingTests: XCTestCase {

    func testConstant() {
        let value = CLLocationDirection.random(in: 0..<360)

        let bearing = FollowPuckViewportStateBearing.constant(value)

        XCTAssertEqual(bearing.evaluate(with: .random()), value)
    }

    func testHeading() {
        let data = PuckRenderingData.random()

        let bearing = FollowPuckViewportStateBearing.heading

        XCTAssertEqual(bearing.evaluate(with: data), data.heading?.direction)
    }

    func testCourse() {
        let data = PuckRenderingData.random()

        let bearing = FollowPuckViewportStateBearing.course

        XCTAssertEqual(bearing.evaluate(with: data), data.location.bearing)
    }
}
