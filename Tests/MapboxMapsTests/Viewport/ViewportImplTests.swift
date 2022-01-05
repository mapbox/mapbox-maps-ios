import XCTest
@testable import MapboxMaps

final class ViewportImplTests: XCTestCase {

    var defaultTransition: MockViewportTransition!
    var viewportImpl: ViewportImpl!

    override func setUp() {
        super.setUp()
        defaultTransition = MockViewportTransition()
        viewportImpl = ViewportImpl(
            defaultTransition: defaultTransition)
    }

    override func tearDown() {
        viewportImpl = nil
        defaultTransition = nil
        super.tearDown()
    }

    func testStatusDefaultsToNil() {
        XCTAssertNil(viewportImpl.status)
    }

    func testStatesDefaultsToEmpty() {
        XCTAssertTrue(viewportImpl.states.isEmpty)
    }

    func testAddState() {
        let state = MockViewportState()

        viewportImpl.addState(state)

        XCTAssertEqual(viewportImpl.states.count, 1)
        XCTAssertTrue(viewportImpl.states.first === state)
    }

    func testAddStateMoreThanOnceDoesNothing() {
        let state = MockViewportState()

        viewportImpl.addState(state)
        viewportImpl.addState(state)

        XCTAssertEqual(viewportImpl.states.count, 1)
        XCTAssertTrue(viewportImpl.states.first === state)
    }

    func testRemoveStateThatWasNeverAddedDoesNothing() {
        let stateA = MockViewportState()
        let stateB = MockViewportState()
        viewportImpl.addState(stateA)

        viewportImpl.removeState(stateB)

        XCTAssertEqual(viewportImpl.states.count, 1)
        XCTAssertTrue(viewportImpl.states.first === stateA)
    }

    func testRemoveState() {
        let state = MockViewportState()
        viewportImpl.addState(state)

        viewportImpl.removeState(state)

        XCTAssertTrue(viewportImpl.states.isEmpty)
    }

    func testRemoveStateWhenStateIsCurrentSetsStatusToIdle() throws {
        let state = MockViewportState()
        viewportImpl.addState(state)
        viewportImpl.transition(to: state, completion: nil)
        // complete the transition
        defaultTransition.runStub.invocations.first?.parameters.completion(true)
        // get the startUpdating Cancelable
        let cancelable = try XCTUnwrap(state.startUpdatingCameraStub.invocations.first?.returnValue as? MockCancelable)

        viewportImpl.removeState(state)

        XCTAssertNil(viewportImpl.status)
        XCTAssertEqual(cancelable.cancelStub.invocations.count, 1)
    }

    func testRemoveStateWhenTransitioningFromStateSetsStatusToIdle() throws {
        let fromState = MockViewportState()
        let toState = MockViewportState()
        viewportImpl.addState(fromState)
        viewportImpl.addState(toState)
        viewportImpl.transition(to: fromState, completion: nil)
        // complete the transition
        defaultTransition.runStub.invocations.first?.parameters.completion(true)
        viewportImpl.transition(to: toState, completion: nil)

        // get the run Cancelable
        let cancelable = try XCTUnwrap(defaultTransition.runStub.invocations.last?.returnValue as? MockCancelable)

        viewportImpl.removeState(fromState)

        XCTAssertNil(viewportImpl.status)
        XCTAssertEqual(cancelable.cancelStub.invocations.count, 1)
    }

    func testRemoveStateWhenTransitioningToStateSetsStatusToIdle() throws {
        let toState = MockViewportState()
        viewportImpl.addState(toState)
        viewportImpl.transition(to: toState, completion: nil)

        // get the run Cancelable
        let cancelable = try XCTUnwrap(defaultTransition.runStub.invocations.last?.returnValue as? MockCancelable)

        viewportImpl.removeState(toState)

        XCTAssertNil(viewportImpl.status)
        XCTAssertEqual(cancelable.cancelStub.invocations.count, 1)
    }
}
