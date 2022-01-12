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
        let stateC = MockViewportState()
        let transition1 = MockViewportTransition()
        let transition2 = MockViewportTransition()

        verifyEqual(.state(nil), .state(nil))
        verifyEqual(.state(stateA), .state(stateA))
        verifyEqual(
            .transition(transition1, fromState: nil, toState: stateA),
            .transition(transition1, fromState: nil, toState: stateA))
        verifyEqual(
            .transition(transition1, fromState: stateA, toState: stateB),
            .transition(transition1, fromState: stateA, toState: stateB))

        verifyNotEqual(.state(nil), .state(stateA))
        verifyNotEqual(.state(stateA), .state(stateB))
        verifyNotEqual(.state(nil), .transition(transition1, fromState: nil, toState: stateA))
        verifyNotEqual(.state(stateA), .transition(transition1, fromState: nil, toState: stateA))
        verifyNotEqual(.state(nil), .transition(transition1, fromState: stateA, toState: stateB))
        verifyNotEqual(.state(stateA), .transition(transition1, fromState: stateA, toState: stateB))
        verifyNotEqual(.state(stateB), .transition(transition1, fromState: stateA, toState: stateB))
        verifyNotEqual(
            .transition(transition1, fromState: stateA, toState: stateB),
            .transition(transition1, fromState: nil, toState: stateB))
        verifyNotEqual(
            .transition(transition1, fromState: stateA, toState: stateB),
            .transition(transition1, fromState: stateA, toState: stateC))
        verifyNotEqual(
            .transition(transition1, fromState: stateA, toState: stateC),
            .transition(transition1, fromState: stateB, toState: stateC))
        verifyNotEqual(
            .transition(transition1, fromState: stateA, toState: stateB),
            .transition(transition2, fromState: stateA, toState: stateB))
    }
}
