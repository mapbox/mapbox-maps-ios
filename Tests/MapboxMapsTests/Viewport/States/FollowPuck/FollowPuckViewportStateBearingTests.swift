import XCTest
@testable import MapboxMaps

final class FollowPuckViewportStateBearingTests: XCTestCase {
    let state = FollowPuckViewportState.RenderingState(coordinate: .random())

    func testConstant() {
        let value = CLLocationDirection.random(in: 0..<360)

        let bearing = FollowPuckViewportStateBearing.constant(value)

        XCTAssertEqual(bearing.evaluate(state: state), value)
    }

    func testHeading() {
        let bearing = FollowPuckViewportStateBearing.heading

        XCTAssertEqual(bearing.evaluate(state: state), state.heading)
    }

    func testCourse() {
        let bearing = FollowPuckViewportStateBearing.course

        XCTAssertEqual(bearing.evaluate(state: state), state.bearing)
    }
}
