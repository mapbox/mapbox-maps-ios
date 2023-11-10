import XCTest
@testable import MapboxMaps

final class ViewportManagerImplTests: XCTestCase {

    var options: ViewportOptions!
    var mainQueue: MockDispatchQueue!
    var defaultTransition: MockViewportTransition!
    var anyTouchGestureRecognizer: MockGestureRecognizer!
    var doubleTapGestureRecognizer: MockGestureRecognizer!
    var doubleTouchGestureRecognizer: MockGestureRecognizer!
    var viewportImpl: ViewportManagerImpl!
    var statusObserver: MockViewportStatusObserver!
    var mapboxMap: MockMapboxMap!
    @TestSignal var safeAreaInsets: Signal<UIEdgeInsets>
    @TestPublished var isDefaultCameraInitialized = false

    override func setUp() {
        super.setUp()
        options = .random()
        mainQueue = MockDispatchQueue()
        defaultTransition = MockViewportTransition()
        mapboxMap = MockMapboxMap()
        anyTouchGestureRecognizer = MockGestureRecognizer()
        doubleTapGestureRecognizer = MockGestureRecognizer()
        doubleTouchGestureRecognizer = MockGestureRecognizer()
        viewportImpl = ViewportManagerImpl(
            options: options,
            mapboxMap: mapboxMap,
            safeAreaInsets: safeAreaInsets,
            isDefaultCameraInitialized: $isDefaultCameraInitialized,
            mainQueue: mainQueue,
            defaultTransition: defaultTransition,
            anyTouchGestureRecognizer: anyTouchGestureRecognizer,
            doubleTapGestureRecognizer: doubleTapGestureRecognizer,
            doubleTouchGestureRecognizer: doubleTouchGestureRecognizer)
        statusObserver = MockViewportStatusObserver()
        viewportImpl.addStatusObserver(statusObserver)
    }

    override func tearDown() {
        mapboxMap = nil
        statusObserver = nil
        viewportImpl = nil
        doubleTouchGestureRecognizer = nil
        doubleTapGestureRecognizer = nil
        anyTouchGestureRecognizer = nil
        defaultTransition = nil
        mainQueue = nil
        options = nil
        super.tearDown()
    }

    func setUp(withCurrentState currentState: MockViewportState) throws {
        viewportImpl.transition(to: currentState, transition: nil, completion: nil)
        XCTAssertEqual(defaultTransition.runStub.invocations.count, 1)
        let runInvocation = try XCTUnwrap(defaultTransition.runStub.invocations.first)
        runInvocation.parameters.completion(true)
        defaultTransition.runStub.reset()
        statusObserver.viewportStatusDidChangeStub.reset()
        mainQueue.asyncClosureStub.reset()
    }

    func drainMainQueue() {
        while !mainQueue.asyncClosureStub.invocations.isEmpty {
            let blocks = mainQueue.asyncClosureStub.invocations.map(\.parameters.work)
            mainQueue.asyncClosureStub.reset()
            for block in blocks {
                block()
            }
        }
    }

    func transitionAndNotify(withToState toState: ViewportState, transition: ViewportTransition? = nil, completion: ((Bool) -> Void)?) {
        viewportImpl.transition(to: toState, transition: transition, completion: completion)
        drainMainQueue()
    }

    func idleAndNotify() {
        viewportImpl.idle()
        drainMainQueue()
    }

    func testStatusDefaultsToNilState() {
        XCTAssertEqual(viewportImpl.status, .idle)
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
                          transition: MockViewportTransition?) throws {
        let completionStub = Stub<Bool, Void>()
        transitionAndNotify(withToState: toState, transition: transition) { finished in
            // verifies that status is updated by the time the completion block is called
            XCTAssertEqual(self.viewportImpl.status, .state(toState))
            completionStub.call(with: finished)
        }

        if let fromState = fromState {
            XCTAssertEqual(fromState.stopUpdatingCameraStub.invocations.count, 1)
        }
        let expectedTransition = transition ?? defaultTransition!
        let transitionStatus = ViewportStatus.transition(expectedTransition, toState: toState)
        XCTAssertEqual(viewportImpl.status, transitionStatus)
        XCTAssertEqual(
            statusObserver.viewportStatusDidChangeStub.invocations.map(\.parameters),
            [.init(fromStatus: fromState.map(ViewportStatus.state) ?? .idle, toStatus: viewportImpl.status, reason: .transitionStarted)])
        statusObserver.viewportStatusDidChangeStub.reset()
        XCTAssertEqual(expectedTransition.runStub.invocations.count, 1)
        let runInvocation = try XCTUnwrap(expectedTransition.runStub.invocations.first)
        XCTAssertTrue(runInvocation.parameters.toState === toState)
        let transitionCompletion = try XCTUnwrap(runInvocation.parameters.completion)
        let transitionCancelable = try XCTUnwrap(runInvocation.returnValue as? MockCancelable)

        transitionCompletion(true)
        drainMainQueue()

        XCTAssertEqual(toState.startUpdatingCameraStub.invocations.count, 1)
        XCTAssertEqual(completionStub.invocations.map(\.parameters), [true])
        XCTAssertTrue(transitionCancelable.cancelStub.invocations.isEmpty)
        XCTAssertTrue(toState.stopUpdatingCameraStub.invocations.isEmpty)
        XCTAssertEqual(viewportImpl.status, .state(toState))
        XCTAssertEqual(
            statusObserver.viewportStatusDidChangeStub.invocations.map(\.parameters),
            [.init(fromStatus: transitionStatus, toStatus: .state(toState), reason: .transitionSucceeded)])
    }

    func testTransitionToStateFromNilUsingDefaultTransition() throws {
        try verifyTransition(from: nil, to: MockViewportState(), transition: nil)
    }

    func testTransitionToStateFromNilUsingNonDefaultTransition() throws {
        let state = MockViewportState()
        let transition = MockViewportTransition()

        try verifyTransition(from: nil, to: state, transition: transition)
    }

    func testTransitionToStateFromStateUsingDefaultTransition() throws {
        let fromState = MockViewportState()
        try setUp(withCurrentState: fromState)
        let toState = MockViewportState()

        try verifyTransition(from: fromState, to: toState, transition: defaultTransition)
    }

    func testTransitionToStateFromStateUsingNonDefaultTransition() throws {
        let fromState = MockViewportState()
        try setUp(withCurrentState: fromState)
        let toState = MockViewportState()
        let transition = MockViewportTransition()

        try verifyTransition(from: fromState, to: toState, transition: transition)
    }

    func testTransitionThatInvokesItsCompletionBlockSynchronouslyDoesNotClobberTheToStatesCancelable() throws {
        let state = MockViewportState()
        // create a mock transition that will invoke its completion block synchronously
        let transition = MockViewportTransition()
        transition.runStub.defaultSideEffect = { invocation in
            invocation.parameters.completion(true)
        }

        let completionStub = Stub<Bool, Void>()
        viewportImpl.transition(to: state, transition: transition, completion: completionStub.call(with:))

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
            self.viewportImpl.transition(to: stateB, transition: nil, completion: transitionToBCompletionStub.call(with:))
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
        XCTAssertEqual(viewportImpl.status, .transition(defaultTransition, toState: stateB))
        XCTAssertEqual(
            statusObserver.viewportStatusDidChangeStub.invocations.map(\.parameters),
            [.init(fromStatus: .idle,
                   toStatus: .transition(defaultTransition, toState: stateA),
                   reason: .transitionStarted),
             .init(fromStatus: .transition(defaultTransition, toState: stateA),
                   toStatus: .transition(defaultTransition, toState: stateB),
                   reason: .transitionStarted)])

        // idle to ensure that the correct final cancelable was stored
        idleAndNotify()

        XCTAssertEqual(transitionToBCompletionStub.invocations.map(\.parameters), [false])
        XCTAssertEqual(transitionToBRunCancelable.cancelStub.invocations.count, 1)
    }

    // this test fails if ViewportManagerImpl notifies observers of status changes synchronously
    func testStatusObserverDeliveryOrderMultipleObserversAndObserverInitiatedTransition() {
        let stateA = MockViewportState()
        let stateB = MockViewportState()
        let observer2 = MockViewportStatusObserver()
        viewportImpl.addStatusObserver(observer2)

        let transitionToBCompletionStub = Stub<Bool, Void>()
        statusObserver.viewportStatusDidChangeStub.sideEffectQueue.append({ _ in
            self.viewportImpl.transition(to: stateB, transition: nil, completion: transitionToBCompletionStub.call(with:))
        })

        let transitionToACompletionStub = Stub<Bool, Void>()
        transitionAndNotify(withToState: stateA, completion: transitionToACompletionStub.call(with:))

        XCTAssertEqual(
            statusObserver.viewportStatusDidChangeStub.invocations.map(\.parameters),
            [.init(fromStatus: .idle,
                   toStatus: .transition(defaultTransition, toState: stateA),
                   reason: .transitionStarted),
             .init(fromStatus: .transition(defaultTransition, toState: stateA),
                   toStatus: .transition(defaultTransition, toState: stateB),
                   reason: .transitionStarted)])
        XCTAssertEqual(
            observer2.viewportStatusDidChangeStub.invocations.map(\.parameters),
            [.init(fromStatus: .idle,
                   toStatus: .transition(defaultTransition, toState: stateA),
                   reason: .transitionStarted),
             .init(fromStatus: .transition(defaultTransition, toState: stateA),
                   toStatus: .transition(defaultTransition, toState: stateB),
                   reason: .transitionStarted)])
    }

    func testIdleFromNonNilState() throws {
        let fromState = MockViewportState()
        try setUp(withCurrentState: fromState)

        idleAndNotify()

        XCTAssertEqual(fromState.stopUpdatingCameraStub.invocations.count, 1)
        XCTAssertEqual(viewportImpl.status, .idle)
        XCTAssertEqual(
            statusObserver.viewportStatusDidChangeStub.invocations.map(\.parameters),
            [.init(fromStatus: .state(fromState), toStatus: .idle, reason: .idleRequested)])
    }

    func testIdleFromNilState() {
        idleAndNotify()

        XCTAssertEqual(viewportImpl.status, .idle)
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
        XCTAssertEqual(viewportImpl.status, .transition(defaultTransition, toState: stateB))
        XCTAssertEqual(
            statusObserver.viewportStatusDidChangeStub.invocations.map(\.parameters),
            [.init(fromStatus: .idle,
                   toStatus: .transition(defaultTransition, toState: stateA),
                   reason: .transitionStarted),
             .init(fromStatus: .transition(defaultTransition, toState: stateA),
                   toStatus: .transition(defaultTransition, toState: stateB),
                   reason: .transitionStarted)])

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
        XCTAssertEqual(viewportImpl.status, .idle)
        XCTAssertEqual(
            statusObserver.viewportStatusDidChangeStub.invocations.map(\.parameters),
            [.init(fromStatus: .idle,
                   toStatus: .transition(defaultTransition, toState: stateA),
                   reason: .transitionStarted),
             .init(fromStatus: .transition(defaultTransition, toState: stateA),
                   toStatus: .idle,
                   reason: .idleRequested)])
    }

    func testIgnoresViewportTransitionRunCompletionBlockInvocationIfCanceledBySecondTransition() throws {
        let stateA = MockViewportState()
        let stateB = MockViewportState()
        // configure the first run invocation so that if its returned cancelable
        // is canceled, it will invoke its completion block with false
        let transition1Cancelable = MockCancelable()
        defaultTransition.runStub.sideEffectQueue.append({ invocation in
            transition1Cancelable.cancelStub.sideEffectQueue.append({ _ in
                invocation.parameters.completion(false)
            })
        })
        defaultTransition.runStub.returnValueQueue = [transition1Cancelable, MockCancelable()]
        let transitionToACompletionStub = Stub<Bool, Void>()
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
        XCTAssertEqual(viewportImpl.status, .transition(defaultTransition, toState: stateB))
        XCTAssertEqual(
            statusObserver.viewportStatusDidChangeStub.invocations.map(\.parameters),
            [.init(fromStatus: .idle,
                   toStatus: .transition(defaultTransition, toState: stateA),
                   reason: .transitionStarted),
             .init(fromStatus: .transition(defaultTransition, toState: stateA),
                   toStatus: .transition(defaultTransition, toState: stateB),
                   reason: .transitionStarted)])

        // idle to ensure that the correct final cancelable was stored
        viewportImpl.idle()

        XCTAssertEqual(transitionToBCompletionStub.invocations.map(\.parameters), [false])
        XCTAssertEqual(transitionToBRunCancelable.cancelStub.invocations.count, 1)
    }

    func testIgnoresViewportTransitionRunCompletionBlockInvocationIfCanceledByIdle() throws {
        let state = MockViewportState()

        // configure the run invocation so that if its returned cancelable
        // is canceled, it will invoke its completion block with false
        let transitionCancelable = MockCancelable()
        defaultTransition.runStub.sideEffectQueue.append({ invocation in
            transitionCancelable.cancelStub.sideEffectQueue.append({ _ in
                invocation.parameters.completion(false)
            })
        })
        defaultTransition.runStub.returnValueQueue = [transitionCancelable]
        let completionStub = Stub<Bool, Void>()
        transitionAndNotify(withToState: state, completion: completionStub.call(with:))

        idleAndNotify()

        XCTAssertEqual(defaultTransition.runStub.invocations.count, 1)
        let runInvocation = try XCTUnwrap(defaultTransition.runStub.invocations.first)
        let runCancelable = try XCTUnwrap(runInvocation.returnValue as? MockCancelable)

        XCTAssertEqual(completionStub.invocations.map(\.parameters), [false])
        XCTAssertEqual(runCancelable.cancelStub.invocations.count, 1)
        XCTAssertEqual(viewportImpl.status, .idle)
        XCTAssertEqual(
            statusObserver.viewportStatusDidChangeStub.invocations.map(\.parameters),
            [.init(fromStatus: .idle,
                   toStatus: .transition(defaultTransition, toState: state),
                   reason: .transitionStarted),
             .init(fromStatus: .transition(defaultTransition, toState: state),
                   toStatus: .idle,
                   reason: .idleRequested)])
    }

    func testViewportTransitionRunFailureResultsInIdleStatus() throws {
        let state = MockViewportState()

        let completionStub = Stub<Bool, Void>()
        transitionAndNotify(withToState: state, completion: completionStub.call(with:))

        XCTAssertEqual(defaultTransition.runStub.invocations.count, 1)
        let runInvocation = try XCTUnwrap(defaultTransition.runStub.invocations.first)
        let runCancelable = try XCTUnwrap(runInvocation.returnValue as? MockCancelable)

        runInvocation.parameters.completion(false)
        drainMainQueue()

        XCTAssertEqual(completionStub.invocations.map(\.parameters), [false])
        XCTAssertEqual(runCancelable.cancelStub.invocations.count, 0)
        XCTAssertEqual(viewportImpl.status, .idle)
        XCTAssertEqual(
            statusObserver.viewportStatusDidChangeStub.invocations.map(\.parameters),
            [.init(fromStatus: .idle,
                   toStatus: .transition(defaultTransition, toState: state),
                   reason: .transitionStarted),
             .init(fromStatus: .transition(defaultTransition, toState: state),
                   toStatus: .idle,
                   reason: .transitionFailed)])
    }

    func testDefaultTransitionInitialization() {
        XCTAssertTrue(viewportImpl.defaultTransition === defaultTransition)
    }

    func testOptionsTransitionsToIdleUponUserInteraction() {
        // anyTouchGestureRecognizer.isEnabled is source of truth
        XCTAssertEqual(anyTouchGestureRecognizer.isEnabled, options.transitionsToIdleUponUserInteraction)
        XCTAssertEqual(viewportImpl.options.transitionsToIdleUponUserInteraction, anyTouchGestureRecognizer.isEnabled)

        viewportImpl.options.transitionsToIdleUponUserInteraction.toggle()

        XCTAssertEqual(viewportImpl.options.transitionsToIdleUponUserInteraction, anyTouchGestureRecognizer.isEnabled)

        anyTouchGestureRecognizer.isEnabled.toggle()

        XCTAssertEqual(viewportImpl.options.transitionsToIdleUponUserInteraction, anyTouchGestureRecognizer.isEnabled)
    }

    func testAnyTouchGestureSetsStatusToIdleWhenOptionIsEnabled() throws {
        viewportImpl.options.transitionsToIdleUponUserInteraction = true
        let state = MockViewportState()
        try setUp(withCurrentState: state)

        anyTouchGestureRecognizer.getStateStub.defaultReturnValue = .began
        anyTouchGestureRecognizer.sendActions()
        drainMainQueue()

        XCTAssertEqual(state.stopUpdatingCameraStub.invocations.count, 1)
        XCTAssertEqual(viewportImpl.status, .idle)
        XCTAssertEqual(
            statusObserver.viewportStatusDidChangeStub.invocations.map(\.parameters),
            [.init(fromStatus: .state(state), toStatus: .idle, reason: .userInteraction)])
   }

    func testDoubleTapGestureSetsStatusToIdleWhenOptionIsEnabled() throws {
        viewportImpl.options.transitionsToIdleUponUserInteraction = true
        let state = MockViewportState()
        try setUp(withCurrentState: state)

        doubleTapGestureRecognizer.getStateStub.defaultReturnValue = .recognized
        doubleTapGestureRecognizer.sendActions()
        drainMainQueue()

        XCTAssertEqual(state.stopUpdatingCameraStub.invocations.count, 1)
        XCTAssertEqual(viewportImpl.status, .idle)
        XCTAssertEqual(
            statusObserver.viewportStatusDidChangeStub.invocations.map(\.parameters),
            [.init(fromStatus: .state(state), toStatus: .idle, reason: .userInteraction)])
   }

    func testDoubleTouchGestureSetsStatusToIdleWhenOptionIsEnabled() throws {
        viewportImpl.options.transitionsToIdleUponUserInteraction = true
        let state = MockViewportState()
        try setUp(withCurrentState: state)

        doubleTouchGestureRecognizer.getStateStub.defaultReturnValue = .recognized
        doubleTouchGestureRecognizer.sendActions()
        drainMainQueue()

        XCTAssertEqual(state.stopUpdatingCameraStub.invocations.count, 1)
        XCTAssertEqual(viewportImpl.status, .idle)
        XCTAssertEqual(
            statusObserver.viewportStatusDidChangeStub.invocations.map(\.parameters),
            [.init(fromStatus: .state(state), toStatus: .idle, reason: .userInteraction)])
   }

    func testAnyTouchGestureDoesNotSetStatusToIdleWhenOptionIsDisabled() throws {
        viewportImpl.options.transitionsToIdleUponUserInteraction = false
        let state = MockViewportState()
        try setUp(withCurrentState: state)

        anyTouchGestureRecognizer.getStateStub.defaultReturnValue = .began
        anyTouchGestureRecognizer.sendActions()
        drainMainQueue()

        XCTAssertTrue(state.stopUpdatingCameraStub.invocations.isEmpty)
        XCTAssertEqual(viewportImpl.status, .state(state))
        XCTAssertTrue(statusObserver.viewportStatusDidChangeStub.invocations.isEmpty)
   }

    func testDoubleTapDoesNotSetStatusToIdleWhenOptionIsDisabled() throws {
        viewportImpl.options.transitionsToIdleUponUserInteraction = false
        let state = MockViewportState()
        try setUp(withCurrentState: state)

        doubleTapGestureRecognizer.getStateStub.defaultReturnValue = .recognized
        doubleTapGestureRecognizer.sendActions()
        drainMainQueue()

        XCTAssertTrue(state.stopUpdatingCameraStub.invocations.isEmpty)
        XCTAssertEqual(viewportImpl.status, .state(state))
        XCTAssertTrue(statusObserver.viewportStatusDidChangeStub.invocations.isEmpty)
   }

    func testDoubleTouchDoesNotSetStatusToIdleWhenOptionIsDisabled() throws {
        viewportImpl.options.transitionsToIdleUponUserInteraction = false
        let state = MockViewportState()
        try setUp(withCurrentState: state)

        doubleTouchGestureRecognizer.getStateStub.defaultReturnValue = .recognized
        doubleTouchGestureRecognizer.sendActions()
        drainMainQueue()

        XCTAssertTrue(state.stopUpdatingCameraStub.invocations.isEmpty)
        XCTAssertEqual(viewportImpl.status, .state(state))
        XCTAssertTrue(statusObserver.viewportStatusDidChangeStub.invocations.isEmpty)
   }
}
