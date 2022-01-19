import MapboxMaps
import XCTest

final class ViewportStatusTests: XCTestCase {

    func verifyEqual(_ lhs: ViewportStatus, _ rhs: ViewportStatus) {
        XCTAssertTrue(lhs == rhs)
        XCTAssertTrue(rhs == lhs)
        XCTAssertEqual(lhs.hashValue, rhs.hashValue)
    }

    func verifyNotEqual(_ lhs: ViewportStatus, _ rhs: ViewportStatus) {
        XCTAssertFalse(lhs == rhs)
        XCTAssertFalse(rhs == lhs)
    }

    func testEquatableAndHashable() {
        let stateA = MockViewportState()
        let stateB = MockViewportState()
        let transition1 = MockViewportTransition()
        let transition2 = MockViewportTransition()

        verifyEqual(.idle, .idle)
        verifyEqual(.state(stateA), .state(stateA))
        verifyEqual(
            .transition(transition1, toState: stateA),
            .transition(transition1, toState: stateA))

        verifyNotEqual(.idle, .state(stateA))
        verifyNotEqual(.idle, .transition(transition1, toState: stateA))
        verifyNotEqual(.state(stateA), .state(stateB))
        verifyNotEqual(.state(stateA), .transition(transition1, toState: stateA))
        verifyNotEqual(
            .transition(transition1, toState: stateA),
            .transition(transition1, toState: stateB))
        verifyNotEqual(
            .transition(transition1, toState: stateA),
            .transition(transition2, toState: stateA))
    }
}
