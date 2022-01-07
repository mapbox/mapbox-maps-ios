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

    func setUp(withCurrentState currentState: MockViewportState) throws {
        viewportImpl.addState(currentState)
        viewportImpl.transition(to: currentState, completion: nil)
        XCTAssertEqual(defaultTransition.runStub.invocations.count, 1)
        let runInvocation = try XCTUnwrap(defaultTransition.runStub.invocations.first)
        runInvocation.parameters.completion()
        defaultTransition.runStub.reset()
    }

    func testStatusDefaultsToNilState() {
        XCTAssertEqual(viewportImpl.status, .state(nil))
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
        try setUp(withCurrentState: state)

        viewportImpl.removeState(state)

        XCTAssertEqual(viewportImpl.status, .state(nil))
        XCTAssertEqual(state.stopUpdatingCameraStub.invocations.count, 1)
    }

    func testRemoveStateWhenTransitioningFromStateSetsStatusToIdle() throws {
        let fromState = MockViewportState()
        try setUp(withCurrentState: fromState)
        let toState = MockViewportState()
        viewportImpl.addState(toState)
        viewportImpl.transition(to: toState, completion: nil)
        let runInvocation = try XCTUnwrap(defaultTransition.runStub.invocations.first)
        let runCancelable = try XCTUnwrap(runInvocation.returnValue as? MockCancelable)

        viewportImpl.removeState(fromState)

        XCTAssertEqual(viewportImpl.status, .state(nil))
        XCTAssertEqual(runCancelable.cancelStub.invocations.count, 1)
    }

    func testRemoveStateWhenTransitioningToStateSetsStatusToIdle() throws {
        let toState = MockViewportState()
        viewportImpl.addState(toState)
        viewportImpl.transition(to: toState, completion: nil)

        // get the run Cancelable
        let cancelable = try XCTUnwrap(defaultTransition.runStub.invocations.last?.returnValue as? MockCancelable)

        viewportImpl.removeState(toState)

        XCTAssertEqual(viewportImpl.status, .state(nil))
        XCTAssertEqual(cancelable.cancelStub.invocations.count, 1)
    }

    func verifyTransition(from fromState: MockViewportState?,
                          to toState: MockViewportState,
                          expectedTransition: MockViewportTransition) throws {
        let completionStub = Stub<Bool, Void>()
        viewportImpl.transition(to: toState) { finished in
            // verifies that status is updated by the time the completion block is called
            XCTAssertEqual(self.viewportImpl.status, .state(toState))
            completionStub.call(with: finished)
        }

        if let fromState = fromState {
            XCTAssertEqual(fromState.stopUpdatingCameraStub.invocations.count, 1)
        }
        XCTAssertEqual(viewportImpl.status, .transition(expectedTransition, fromState: fromState, toState: toState))
        XCTAssertEqual(expectedTransition.runStub.invocations.count, 1)
        let runInvocation = try XCTUnwrap(expectedTransition.runStub.invocations.first)
        XCTAssertTrue(runInvocation.parameters.fromState === fromState)
        XCTAssertTrue(runInvocation.parameters.toState === toState)
        let transitionCompletion = try XCTUnwrap(runInvocation.parameters.completion)
        let transitionCancelable = try XCTUnwrap(runInvocation.returnValue as? MockCancelable)

        transitionCompletion()

        XCTAssertEqual(toState.startUpdatingCameraStub.invocations.count, 1)
        XCTAssertEqual(completionStub.invocations.map(\.parameters), [true])
        XCTAssertTrue(transitionCancelable.cancelStub.invocations.isEmpty)
        XCTAssertTrue(toState.stopUpdatingCameraStub.invocations.isEmpty)
    }

    func testTransitionToStateFromNilUsingDefaultTransition() throws {
        let state = MockViewportState()
        viewportImpl.addState(state)

        try verifyTransition(from: nil, to: state, expectedTransition: defaultTransition)
    }

    func testTransitionToStateThatHasNotBeenAddedFromNilUsingDefaultTransition() throws {
        let state = MockViewportState()

        try verifyTransition(from: nil, to: state, expectedTransition: defaultTransition)
        XCTAssertTrue(viewportImpl.states.contains { $0 === state })
    }

    func testTransitionToStateFromNilUsingNonDefaultTransition() throws {
        let state = MockViewportState()
        viewportImpl.addState(state)
        let transition = MockViewportTransition()
        viewportImpl.setTransition(transition, from: nil, to: state)

        try verifyTransition(from: nil, to: state, expectedTransition: transition)
    }

    func testTransitionToStateThatHasNotBeenAddedFromNilUsingNonDefaultTransition() throws {
        let state = MockViewportState()
        let transition = MockViewportTransition()
        viewportImpl.setTransition(transition, from: nil, to: state)

        try verifyTransition(from: nil, to: state, expectedTransition: transition)
        XCTAssertTrue(viewportImpl.states.contains { $0 === state })
    }

    func testTransitionToStateFromStateUsingDefaultTransition() throws {
        let fromState = MockViewportState()
        try setUp(withCurrentState: fromState)
        let toState = MockViewportState()
        viewportImpl.addState(toState)

        try verifyTransition(from: fromState, to: toState, expectedTransition: defaultTransition)
    }

    func testTransitionToStateThatHasNotBeenAddedFromStateUsingDefaultTransition() throws {
        let fromState = MockViewportState()
        try setUp(withCurrentState: fromState)
        let toState = MockViewportState()

        try verifyTransition(from: fromState, to: toState, expectedTransition: defaultTransition)
        XCTAssertTrue(viewportImpl.states.contains { $0 === toState })
    }

    func testTransitionToStateFromStateUsingNonDefaultTransition() throws {
        let fromState = MockViewportState()
        try setUp(withCurrentState: fromState)
        let toState = MockViewportState()
        viewportImpl.addState(toState)
        let transition = MockViewportTransition()
        viewportImpl.setTransition(transition, from: fromState, to: toState)

        try verifyTransition(from: fromState, to: toState, expectedTransition: transition)
    }

    func testTransitionToStateThatHasNotBeenAddedFromStateUsingNonDefaultTransition() throws {
        let fromState = MockViewportState()
        try setUp(withCurrentState: fromState)
        let toState = MockViewportState()
        let transition = MockViewportTransition()
        viewportImpl.setTransition(transition, from: fromState, to: toState)

        try verifyTransition(from: fromState, to: toState, expectedTransition: transition)
        XCTAssertTrue(viewportImpl.states.contains { $0 === toState })
    }

    func testTransitionThatInvokesItsCompletionBlockSynchronouslyDoesNotClobberTheToStatesCancelable() throws {
        let state = MockViewportState()
        viewportImpl.addState(state)
        // create a mock transition that will invoke its completion block synchronously
        let transition = MockViewportTransition()
        transition.runStub.defaultSideEffect = { invocation in
            invocation.parameters.completion()
        }
        viewportImpl.setTransition(transition, from: nil, to: state)

        let completionStub = Stub<Bool, Void>()
        viewportImpl.transition(to: state, completion: completionStub.call(with:))

        // completion block should have been invoked synchronously
        XCTAssertEqual(completionStub.invocations.map(\.parameters), [true])

        // idle to cancel the current cancelable
        viewportImpl.idle()

        // verify that the transition cancelable was not invoked
        let runInvocation = try XCTUnwrap(transition.runStub.invocations.first)
        let transitionCancelable = try XCTUnwrap(runInvocation.returnValue as? MockCancelable)
        XCTAssertTrue(transitionCancelable.cancelStub.invocations.isEmpty)

        // verify state's stopUpdatingCamera was invoked
        XCTAssertEqual(state.stopUpdatingCameraStub.invocations.count, 1)
    }

    func testIdleFromNonNilState() throws {
        let fromState = MockViewportState()
        try setUp(withCurrentState: fromState)

        viewportImpl.idle()

        XCTAssertEqual(fromState.stopUpdatingCameraStub.invocations.count, 1)
        XCTAssertEqual(viewportImpl.status, .state(nil))
    }

    func testIdleFromNilState() {
        viewportImpl.idle()

        XCTAssertEqual(viewportImpl.status, .state(nil))
    }

    func testTransitionToStateFromSameState() throws {
        let fromState = MockViewportState()
        try setUp(withCurrentState: fromState)

        let completionStub = Stub<Bool, Void>()
        viewportImpl.transition(to: fromState) { finished in
            XCTAssertEqual(self.viewportImpl.status, .state(fromState))
            completionStub.call(with: finished)
        }

        // no additional startUpdatingCamera invocation
        XCTAssertEqual(fromState.startUpdatingCameraStub.invocations.count, 1)
        XCTAssertTrue(fromState.stopUpdatingCameraStub.invocations.isEmpty)
        XCTAssertEqual(completionStub.invocations.map(\.parameters), [true])
    }

    func testInterruptingTransitionToStateWithSecondTransitionToSameState() throws {
        let state = MockViewportState()
        viewportImpl.addState(state)
        // ensure that each run invocation gets a unique cancelable
        defaultTransition.runStub.returnValueQueue = [MockCancelable(), MockCancelable()]

        let firstTransitionCompletionStub = Stub<Bool, Void>()
        viewportImpl.transition(to: state, completion: firstTransitionCompletionStub.call(with:))

        XCTAssertEqual(defaultTransition.runStub.invocations.count, 1)
        let runInvocation = try XCTUnwrap(defaultTransition.runStub.invocations.first)
        let runCancelable = try XCTUnwrap(runInvocation.returnValue as? MockCancelable)

        let secondTransitionCompletionStub = Stub<Bool, Void>()
        viewportImpl.transition(to: state, completion: secondTransitionCompletionStub.call(with:))

        // no further transition is run
        XCTAssertEqual(defaultTransition.runStub.invocations.count, 1)

        // the current transition is not canceled or completed
        XCTAssertTrue(runCancelable.cancelStub.invocations.isEmpty)
        XCTAssertTrue(firstTransitionCompletionStub.invocations.isEmpty)

        // the second call to transition(to:) completes immediately with finished == false
        XCTAssertEqual(secondTransitionCompletionStub.invocations.map(\.parameters), [false])
    }

    func testInterruptingTransitionToStateAWithTransitionToStateB() throws {
        let stateA = MockViewportState()
        viewportImpl.addState(stateA)
        let stateB = MockViewportState()
        viewportImpl.addState(stateB)
        let transitionToACompletionStub = Stub<Bool, Void>()
        // ensure that each run invocation gets a unique cancelable
        defaultTransition.runStub.returnValueQueue = [MockCancelable(), MockCancelable()]
        viewportImpl.transition(to: stateA, completion: transitionToACompletionStub.call(with:))

        let transitionToBCompletionStub = Stub<Bool, Void>()
        viewportImpl.transition(to: stateB, completion: transitionToBCompletionStub.call(with:))

        XCTAssertEqual(defaultTransition.runStub.invocations.count, 2)
        let transitionToARunInvocation = try XCTUnwrap(defaultTransition.runStub.invocations.first)
        let transitionToARunCancelable = try XCTUnwrap(transitionToARunInvocation.returnValue as? MockCancelable)
        let transitionToBRunInvocation = try XCTUnwrap(defaultTransition.runStub.invocations.last)
        let transitionToBRunCancelable = try XCTUnwrap(transitionToBRunInvocation.returnValue as? MockCancelable)

        XCTAssertEqual(transitionToACompletionStub.invocations.map(\.parameters), [false])
        XCTAssertEqual(transitionToARunCancelable.cancelStub.invocations.count, 1)
        XCTAssertEqual(viewportImpl.status, .transition(defaultTransition, fromState: stateA, toState: stateB))

        // idle to ensure that the correct final cancelable was stored
        viewportImpl.idle()

        XCTAssertEqual(transitionToBCompletionStub.invocations.map(\.parameters), [false])
        XCTAssertEqual(transitionToBRunCancelable.cancelStub.invocations.count, 1)
    }

    func testInterruptingTransitionToStateWithIdle() throws {
        let stateA = MockViewportState()
        viewportImpl.addState(stateA)
        let transitionToACompletionStub = Stub<Bool, Void>()
        viewportImpl.transition(to: stateA, completion: transitionToACompletionStub.call(with:))

        viewportImpl.idle()

        XCTAssertEqual(defaultTransition.runStub.invocations.count, 1)
        let transitionToARunInvocation = try XCTUnwrap(defaultTransition.runStub.invocations.first)
        let transitionToARunCancelable = try XCTUnwrap(transitionToARunInvocation.returnValue as? MockCancelable)

        XCTAssertEqual(transitionToACompletionStub.invocations.map(\.parameters), [false])
        XCTAssertEqual(transitionToARunCancelable.cancelStub.invocations.count, 1)
        XCTAssertEqual(viewportImpl.status, .state(nil))
    }

    func testDefaultTransitionInitialization() {
        XCTAssertTrue(viewportImpl.defaultTransition === defaultTransition)
    }

    func testSetGetRemoveTransitionInvolvingNil() {
        let transition = MockViewportTransition()
        let state = MockViewportState()

        viewportImpl.setTransition(transition, from: nil, to: state)

        XCTAssertTrue(viewportImpl.getTransition(from: nil, to: state) === transition)

        viewportImpl.removeTransition(from: nil, to: state)

        XCTAssertNil(viewportImpl.getTransition(from: nil, to: state))
    }

    func testSetGetRemoveTransitionBetweenNonNilStates() {
        let transition = MockViewportTransition()
        let stateA = MockViewportState()
        let stateB = MockViewportState()

        viewportImpl.setTransition(transition, from: stateA, to: stateB)

        XCTAssertTrue(viewportImpl.getTransition(from: stateA, to: stateB) === transition)

        viewportImpl.removeTransition(from: stateA, to: stateB)

        XCTAssertNil(viewportImpl.getTransition(from: stateA, to: stateB))
    }

    func testReplaceTransition() {
        let transitionA = MockViewportTransition()
        let transitionB = MockViewportTransition()
        let stateA = MockViewportState()
        let stateB = MockViewportState()
        viewportImpl.setTransition(transitionA, from: stateA, to: stateB)

        viewportImpl.setTransition(transitionB, from: stateA, to: stateB)

        XCTAssertTrue(viewportImpl.getTransition(from: stateA, to: stateB) === transitionB)
    }
}
