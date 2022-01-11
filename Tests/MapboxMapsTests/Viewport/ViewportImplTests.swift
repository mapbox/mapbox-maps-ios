import XCTest
@testable import MapboxMaps

final class ViewportImplTests: XCTestCase {

    var mainQueue: MockMainQueue!
    var defaultTransition: MockViewportTransition!
    var viewportImpl: ViewportImpl!
    var statusObserver: MockViewportStatusObserver!

    override func setUp() {
        super.setUp()
        mainQueue = MockMainQueue()
        defaultTransition = MockViewportTransition()
        viewportImpl = ViewportImpl(
            mainQueue: mainQueue,
            defaultTransition: defaultTransition)
        statusObserver = MockViewportStatusObserver()
        viewportImpl.addStatusObserver(statusObserver)
    }

    override func tearDown() {
        statusObserver = nil
        viewportImpl = nil
        defaultTransition = nil
        mainQueue = nil
        super.tearDown()
    }

    func setUp(withCurrentState currentState: MockViewportState) throws {
        viewportImpl.transition(to: currentState, completion: nil)
        XCTAssertEqual(defaultTransition.runStub.invocations.count, 1)
        let runInvocation = try XCTUnwrap(defaultTransition.runStub.invocations.first)
        runInvocation.parameters.completion()
        defaultTransition.runStub.reset()
        statusObserver.viewportStatusDidChangeStub.reset()
        mainQueue.asyncStub.reset()
    }

    func drainMainQueue() {
        while !mainQueue.asyncStub.invocations.isEmpty {
            let blocks = mainQueue.asyncStub.invocations.map(\.parameters)
            mainQueue.asyncStub.reset()
            for block in blocks {
                block()
            }
        }
    }

    func transitionAndNotify(withToState toState: ViewportState, completion: ((Bool) -> Void)?) {
        viewportImpl.transition(to: toState, completion: completion)
        drainMainQueue()
    }

    func idleAndNotify() {
        viewportImpl.idle()
        drainMainQueue()
    }

    func testStatusDefaultsToNilState() {
        XCTAssertEqual(viewportImpl.status, .state(nil))
    }

    func testAddAndRemoveMultipleObservers() {
        let statusObserver2 = MockViewportStatusObserver()

        transitionAndNotify(withToState: MockViewportState(), completion: nil)

        viewportImpl.addStatusObserver(statusObserver2)
        viewportImpl.addStatusObserver(statusObserver2) // second add should have no effect

        XCTAssertEqual(statusObserver.viewportStatusDidChangeStub.invocations.count, 1)
        XCTAssertTrue(statusObserver2.viewportStatusDidChangeStub.invocations.isEmpty)

        transitionAndNotify(withToState: MockViewportState(), completion: nil)

        XCTAssertEqual(statusObserver.viewportStatusDidChangeStub.invocations.count, 2)
        XCTAssertEqual(statusObserver2.viewportStatusDidChangeStub.invocations.count, 1)

        viewportImpl.removeStatusObserver(statusObserver2)
        viewportImpl.removeStatusObserver(statusObserver2) // second remove should have no effect

        transitionAndNotify(withToState: MockViewportState(), completion: nil)

        XCTAssertEqual(statusObserver.viewportStatusDidChangeStub.invocations.count, 3)
        XCTAssertEqual(statusObserver2.viewportStatusDidChangeStub.invocations.count, 1)

        viewportImpl.removeStatusObserver(statusObserver)

        transitionAndNotify(withToState: MockViewportState(), completion: nil)

        XCTAssertEqual(statusObserver.viewportStatusDidChangeStub.invocations.count, 3)
        XCTAssertEqual(statusObserver2.viewportStatusDidChangeStub.invocations.count, 1)
    }

    func verifyTransition(from fromState: MockViewportState?,
                          to toState: MockViewportState,
                          expectedTransition: MockViewportTransition) throws {
        let completionStub = Stub<Bool, Void>()
        transitionAndNotify(withToState: toState) { finished in
            // verifies that status is updated by the time the completion block is called
            XCTAssertEqual(self.viewportImpl.status, .state(toState))
            completionStub.call(with: finished)
        }

        if let fromState = fromState {
            XCTAssertEqual(fromState.stopUpdatingCameraStub.invocations.count, 1)
        }
        let transitionStatus = ViewportStatus.transition(expectedTransition, fromState: fromState, toState: toState)
        XCTAssertEqual(viewportImpl.status, transitionStatus)
        XCTAssertEqual(
            statusObserver.viewportStatusDidChangeStub.invocations.map(\.parameters),
            [.init(fromStatus: .state(fromState), toStatus: viewportImpl.status, reason: .programmatic)])
        statusObserver.viewportStatusDidChangeStub.reset()
        XCTAssertEqual(expectedTransition.runStub.invocations.count, 1)
        let runInvocation = try XCTUnwrap(expectedTransition.runStub.invocations.first)
        XCTAssertTrue(runInvocation.parameters.fromState === fromState)
        XCTAssertTrue(runInvocation.parameters.toState === toState)
        let transitionCompletion = try XCTUnwrap(runInvocation.parameters.completion)
        let transitionCancelable = try XCTUnwrap(runInvocation.returnValue as? MockCancelable)

        transitionCompletion()
        drainMainQueue()

        XCTAssertEqual(toState.startUpdatingCameraStub.invocations.count, 1)
        XCTAssertEqual(completionStub.invocations.map(\.parameters), [true])
        XCTAssertTrue(transitionCancelable.cancelStub.invocations.isEmpty)
        XCTAssertTrue(toState.stopUpdatingCameraStub.invocations.isEmpty)
        XCTAssertEqual(viewportImpl.status, .state(toState))
        XCTAssertEqual(
            statusObserver.viewportStatusDidChangeStub.invocations.map(\.parameters),
            [.init(fromStatus: transitionStatus, toStatus: .state(toState), reason: .programmatic)])
    }

    func testTransitionToStateFromNilUsingDefaultTransition() throws {
        try verifyTransition(from: nil, to: MockViewportState(), expectedTransition: defaultTransition)
    }

    func testTransitionToStateFromNilUsingNonDefaultTransition() throws {
        let state = MockViewportState()
        let transition = MockViewportTransition()
        viewportImpl.setTransition(transition, from: nil, to: state)

        try verifyTransition(from: nil, to: state, expectedTransition: transition)
    }

    func testTransitionToStateFromStateUsingDefaultTransition() throws {
        let fromState = MockViewportState()
        try setUp(withCurrentState: fromState)
        let toState = MockViewportState()

        try verifyTransition(from: fromState, to: toState, expectedTransition: defaultTransition)
    }

    func testTransitionToStateFromStateUsingNonDefaultTransition() throws {
        let fromState = MockViewportState()
        try setUp(withCurrentState: fromState)
        let toState = MockViewportState()
        let transition = MockViewportTransition()
        viewportImpl.setTransition(transition, from: fromState, to: toState)

        try verifyTransition(from: fromState, to: toState, expectedTransition: transition)
    }

    func testTransitionThatInvokesItsCompletionBlockSynchronouslyDoesNotClobberTheToStatesCancelable() throws {
        let state = MockViewportState()
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

    func testStatusObserverInitiatedTransition() throws {
        let stateA = MockViewportState()
        let stateB = MockViewportState()
        // ensure that each run invocation gets a unique cancelable
        defaultTransition.runStub.returnValueQueue = [MockCancelable(), MockCancelable()]

        let transitionToBCompletionStub = Stub<Bool, Void>()
        statusObserver.viewportStatusDidChangeStub.sideEffectQueue.append({ _ in
            self.viewportImpl.transition(to: stateB, completion: transitionToBCompletionStub.call(with:))
        })

        let transitionToACompletionStub = Stub<Bool, Void>()
        transitionAndNotify(withToState: stateA, completion: transitionToACompletionStub.call(with:))

        XCTAssertEqual(defaultTransition.runStub.invocations.count, 2)
        let transitionToARunInvocation = try XCTUnwrap(defaultTransition.runStub.invocations.first)
        let transitionToARunCancelable = try XCTUnwrap(transitionToARunInvocation.returnValue as? MockCancelable)
        let transitionToBRunInvocation = try XCTUnwrap(defaultTransition.runStub.invocations.last)
        let transitionToBRunCancelable = try XCTUnwrap(transitionToBRunInvocation.returnValue as? MockCancelable)

        XCTAssertEqual(transitionToACompletionStub.invocations.map(\.parameters), [false])
        XCTAssertEqual(transitionToARunCancelable.cancelStub.invocations.count, 1)
        XCTAssertEqual(viewportImpl.status, .transition(defaultTransition, fromState: stateA, toState: stateB))
        XCTAssertEqual(
            statusObserver.viewportStatusDidChangeStub.invocations.map(\.parameters),
            [.init(fromStatus: .state(nil),
                   toStatus: .transition(defaultTransition, fromState: nil, toState: stateA),
                   reason: .programmatic),
             .init(fromStatus: .transition(defaultTransition, fromState: nil, toState: stateA),
                   toStatus: .transition(defaultTransition, fromState: stateA, toState: stateB),
                   reason: .programmatic)])

        // idle to ensure that the correct final cancelable was stored
        idleAndNotify()

        XCTAssertEqual(transitionToBCompletionStub.invocations.map(\.parameters), [false])
        XCTAssertEqual(transitionToBRunCancelable.cancelStub.invocations.count, 1)
    }

    // this test fails if ViewportImpl notifies observers of status changes synchronously
    func testStatusObserverDeliveryOrderMultipleObserversAndObserverInitiatedTransition() {
        let stateA = MockViewportState()
        let stateB = MockViewportState()
        let observer2 = MockViewportStatusObserver()
        viewportImpl.addStatusObserver(observer2)

        let transitionToBCompletionStub = Stub<Bool, Void>()
        statusObserver.viewportStatusDidChangeStub.sideEffectQueue.append({ _ in
            self.viewportImpl.transition(to: stateB, completion: transitionToBCompletionStub.call(with:))
        })

        let transitionToACompletionStub = Stub<Bool, Void>()
        transitionAndNotify(withToState: stateA, completion: transitionToACompletionStub.call(with:))

        XCTAssertEqual(
            statusObserver.viewportStatusDidChangeStub.invocations.map(\.parameters),
            [.init(fromStatus: .state(nil),
                   toStatus: .transition(defaultTransition, fromState: nil, toState: stateA),
                   reason: .programmatic),
             .init(fromStatus: .transition(defaultTransition, fromState: nil, toState: stateA),
                   toStatus: .transition(defaultTransition, fromState: stateA, toState: stateB),
                   reason: .programmatic)])
        XCTAssertEqual(
            observer2.viewportStatusDidChangeStub.invocations.map(\.parameters),
            [.init(fromStatus: .state(nil),
                   toStatus: .transition(defaultTransition, fromState: nil, toState: stateA),
                   reason: .programmatic),
             .init(fromStatus: .transition(defaultTransition, fromState: nil, toState: stateA),
                   toStatus: .transition(defaultTransition, fromState: stateA, toState: stateB),
                   reason: .programmatic)])
    }

    func testIdleFromNonNilState() throws {
        let fromState = MockViewportState()
        try setUp(withCurrentState: fromState)

        idleAndNotify()

        XCTAssertEqual(fromState.stopUpdatingCameraStub.invocations.count, 1)
        XCTAssertEqual(viewportImpl.status, .state(nil))
        XCTAssertEqual(
            statusObserver.viewportStatusDidChangeStub.invocations.map(\.parameters),
            [.init(fromStatus: .state(fromState), toStatus: .state(nil), reason: .programmatic)])
    }

    func testIdleFromNilState() {
        idleAndNotify()

        XCTAssertEqual(viewportImpl.status, .state(nil))
        XCTAssertTrue(statusObserver.viewportStatusDidChangeStub.invocations.isEmpty)
    }

    func testTransitionToStateFromSameState() throws {
        let fromState = MockViewportState()
        try setUp(withCurrentState: fromState)

        let completionStub = Stub<Bool, Void>()
        transitionAndNotify(withToState: fromState) { finished in
            XCTAssertEqual(self.viewportImpl.status, .state(fromState))
            completionStub.call(with: finished)
        }

        // no additional startUpdatingCamera invocation
        XCTAssertEqual(fromState.startUpdatingCameraStub.invocations.count, 1)
        XCTAssertTrue(fromState.stopUpdatingCameraStub.invocations.isEmpty)
        XCTAssertEqual(completionStub.invocations.map(\.parameters), [true])
        XCTAssertTrue(statusObserver.viewportStatusDidChangeStub.invocations.isEmpty)
    }

    func testInterruptingTransitionToStateWithSecondTransitionToSameState() throws {
        let state = MockViewportState()
        // ensure that each run invocation gets a unique cancelable
        defaultTransition.runStub.returnValueQueue = [MockCancelable(), MockCancelable()]

        let firstTransitionCompletionStub = Stub<Bool, Void>()
        transitionAndNotify(withToState: state, completion: firstTransitionCompletionStub.call(with:))

        XCTAssertEqual(defaultTransition.runStub.invocations.count, 1)
        XCTAssertEqual(statusObserver.viewportStatusDidChangeStub.invocations.count, 1)
        let runInvocation = try XCTUnwrap(defaultTransition.runStub.invocations.first)
        let runCancelable = try XCTUnwrap(runInvocation.returnValue as? MockCancelable)

        let secondTransitionCompletionStub = Stub<Bool, Void>()
        transitionAndNotify(withToState: state, completion: secondTransitionCompletionStub.call(with:))

        // no further transition is run and no futher notification is delivered
        XCTAssertEqual(defaultTransition.runStub.invocations.count, 1)
        XCTAssertEqual(statusObserver.viewportStatusDidChangeStub.invocations.count, 1)

        // the current transition is not canceled or completed
        XCTAssertTrue(runCancelable.cancelStub.invocations.isEmpty)
        XCTAssertTrue(firstTransitionCompletionStub.invocations.isEmpty)

        // the second call to transition(to:) completes immediately with finished == false
        XCTAssertEqual(secondTransitionCompletionStub.invocations.map(\.parameters), [false])
    }

    func testInterruptingTransitionToStateAWithTransitionToStateB() throws {
        let stateA = MockViewportState()
        let stateB = MockViewportState()
        let transitionToACompletionStub = Stub<Bool, Void>()
        // ensure that each run invocation gets a unique cancelable
        defaultTransition.runStub.returnValueQueue = [MockCancelable(), MockCancelable()]
        transitionAndNotify(withToState: stateA, completion: transitionToACompletionStub.call(with:))

        let transitionToBCompletionStub = Stub<Bool, Void>()
        transitionAndNotify(withToState: stateB, completion: transitionToBCompletionStub.call(with:))

        XCTAssertEqual(defaultTransition.runStub.invocations.count, 2)
        let transitionToARunInvocation = try XCTUnwrap(defaultTransition.runStub.invocations.first)
        let transitionToARunCancelable = try XCTUnwrap(transitionToARunInvocation.returnValue as? MockCancelable)
        let transitionToBRunInvocation = try XCTUnwrap(defaultTransition.runStub.invocations.last)
        let transitionToBRunCancelable = try XCTUnwrap(transitionToBRunInvocation.returnValue as? MockCancelable)

        XCTAssertEqual(transitionToACompletionStub.invocations.map(\.parameters), [false])
        XCTAssertEqual(transitionToARunCancelable.cancelStub.invocations.count, 1)
        XCTAssertEqual(viewportImpl.status, .transition(defaultTransition, fromState: stateA, toState: stateB))
        XCTAssertEqual(
            statusObserver.viewportStatusDidChangeStub.invocations.map(\.parameters),
            [.init(fromStatus: .state(nil),
                   toStatus: .transition(defaultTransition, fromState: nil, toState: stateA),
                   reason: .programmatic),
             .init(fromStatus: .transition(defaultTransition, fromState: nil, toState: stateA),
                   toStatus: .transition(defaultTransition, fromState: stateA, toState: stateB),
                   reason: .programmatic)])

        // idle to ensure that the correct final cancelable was stored
        viewportImpl.idle()

        XCTAssertEqual(transitionToBCompletionStub.invocations.map(\.parameters), [false])
        XCTAssertEqual(transitionToBRunCancelable.cancelStub.invocations.count, 1)
    }

    func testInterruptingTransitionToStateWithIdle() throws {
        let stateA = MockViewportState()
        let transitionToACompletionStub = Stub<Bool, Void>()
        transitionAndNotify(withToState: stateA, completion: transitionToACompletionStub.call(with:))

        idleAndNotify()

        XCTAssertEqual(defaultTransition.runStub.invocations.count, 1)
        let transitionToARunInvocation = try XCTUnwrap(defaultTransition.runStub.invocations.first)
        let transitionToARunCancelable = try XCTUnwrap(transitionToARunInvocation.returnValue as? MockCancelable)

        XCTAssertEqual(transitionToACompletionStub.invocations.map(\.parameters), [false])
        XCTAssertEqual(transitionToARunCancelable.cancelStub.invocations.count, 1)
        XCTAssertEqual(viewportImpl.status, .state(nil))
        XCTAssertEqual(
            statusObserver.viewportStatusDidChangeStub.invocations.map(\.parameters),
            [.init(fromStatus: .state(nil),
                   toStatus: .transition(defaultTransition, fromState: nil, toState: stateA),
                   reason: .programmatic),
             .init(fromStatus: .transition(defaultTransition, fromState: nil, toState: stateA),
                   toStatus: .state(nil),
                   reason: .programmatic)])
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
