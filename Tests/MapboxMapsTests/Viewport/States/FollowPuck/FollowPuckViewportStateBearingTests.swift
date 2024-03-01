import XCTest
@testable import MapboxMaps

final class FollowPuckViewportStateBearingTests: XCTestCase {
    func testConstant() {
        let state = FollowPuckViewportState.RenderingState(coordinate: .random())
        let value = CLLocationDirection.random(in: 0..<360)

        let bearing = FollowPuckViewportStateBearing.constant(value)

        XCTAssertEqual(bearing.evaluate(with: state), value)
    }

    func testHeading() {
        let state = FollowPuckViewportState.RenderingState(coordinate: .random())
        let bearing = FollowPuckViewportStateBearing.heading

        XCTAssertEqual(bearing.evaluate(with: state), state.heading)
    }

    func testCourse() {
        let state = FollowPuckViewportState.RenderingState(coordinate: .random())
        let bearing = FollowPuckViewportStateBearing.course

        XCTAssertEqual(bearing.evaluate(with: state), state.bearing)
    }
}
