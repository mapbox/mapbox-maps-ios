import XCTest
@testable import MapboxMaps

final class DefaultViewportTransitionTests: XCTestCase {

    var options: DefaultViewportTransitionOptions!
    var animationHelper: MockDefaultViewportTransitionAnimationHelper!
    var transition: DefaultViewportTransition!

    override func setUp() {
        super.setUp()
        options = .random()
        animationHelper = MockDefaultViewportTransitionAnimationHelper()
        transition = DefaultViewportTransition(
            options: options,
            animationHelper: animationHelper)
    }

    override func tearDown() {
        transition = nil
        animationHelper = nil
        options = nil
        super.tearDown()
    }

    func testRunToCompletion() throws {
        let fromState = MockViewportState()
        let toState = MockViewportState()
        let completionStub = Stub<Void, Void>()

        _ = transition.run(
            from: fromState,
            to: toState,
            completion: completionStub.call)

        XCTAssertEqual(toState.observeDataSourceStub.invocations.count, 1)
        let observeInvocation = try XCTUnwrap(toState.observeDataSourceStub.invocations.first)
        let observeHandler = observeInvocation.parameters

        let cameraOptions = CameraOptions.random()
        let result = observeHandler(cameraOptions)

        // the handler returns false because it only wants one update
        XCTAssertFalse(result)

        // verify that animate was invoked as expected
        XCTAssertEqual(animationHelper.animateStub.invocations.count, 1)
        let animateInvocation = try XCTUnwrap(animationHelper.animateStub.invocations.first)
        XCTAssertEqual(animateInvocation.parameters.cameraOptions, cameraOptions)
        XCTAssertEqual(animateInvocation.parameters.maxDuration, options.maxDuration)

        let animateCompletion = animateInvocation.parameters.completion

        // exercise the animation completion
        animateCompletion(true) // true means the animation wasn't canceled

        XCTAssertEqual(completionStub.invocations.count, 1)
    }

    func testRunAnimationCanceled() throws {
        let fromState = MockViewportState()
        let toState = MockViewportState()
        let completionStub = Stub<Void, Void>()

        _ = transition.run(
            from: fromState,
            to: toState,
            completion: completionStub.call)

        XCTAssertEqual(toState.observeDataSourceStub.invocations.count, 1)
        let observeInvocation = try XCTUnwrap(toState.observeDataSourceStub.invocations.first)
        let observeHandler = observeInvocation.parameters

        let cameraOptions = CameraOptions.random()
        let result = observeHandler(cameraOptions)

        // the handler returns false because it only wants one update
        XCTAssertFalse(result)

        // verify that animate was invoked as expected
        XCTAssertEqual(animationHelper.animateStub.invocations.count, 1)
        let animateInvocation = try XCTUnwrap(animationHelper.animateStub.invocations.first)
        XCTAssertEqual(animateInvocation.parameters.cameraOptions, cameraOptions)
        XCTAssertEqual(animateInvocation.parameters.maxDuration, options.maxDuration)

        let animateCompletion = animateInvocation.parameters.completion

        // exercise the animation completion
        animateCompletion(false) // false means the animation was canceled

        XCTAssertTrue(completionStub.invocations.isEmpty)
    }

    func testRunAndCancelAfterAnimationStarts() throws {
        let fromState = MockViewportState()
        let toState = MockViewportState()
        let completionStub = Stub<Void, Void>()

        let cancelable = transition.run(
            from: fromState,
            to: toState,
            completion: completionStub.call)

        XCTAssertEqual(toState.observeDataSourceStub.invocations.count, 1)
        let observeInvocation = try XCTUnwrap(toState.observeDataSourceStub.invocations.first)
        let observeHandler = observeInvocation.parameters
        let observeCancelable = try XCTUnwrap(observeInvocation.returnValue as? MockCancelable)

        let cameraOptions = CameraOptions.random()
        let result = observeHandler(cameraOptions)

        // the handler returns false because it only wants one update
        XCTAssertFalse(result)

        // verify that animate was invoked as expected
        XCTAssertEqual(animationHelper.animateStub.invocations.count, 1)
        let animateInvocation = try XCTUnwrap(animationHelper.animateStub.invocations.first)
        XCTAssertEqual(animateInvocation.parameters.cameraOptions, cameraOptions)
        XCTAssertEqual(animateInvocation.parameters.maxDuration, options.maxDuration)

        let animateCancelable = try XCTUnwrap(animateInvocation.returnValue as? MockCancelable)

        cancelable.cancel()

        XCTAssertEqual(observeCancelable.cancelStub.invocations.count, 1)
        XCTAssertEqual(animateCancelable.cancelStub.invocations.count, 1)
    }

    func testRunAndCancelBeforeAnimationStarts() throws {
        let fromState = MockViewportState()
        let toState = MockViewportState()
        let completionStub = Stub<Void, Void>()

        let cancelable = transition.run(
            from: fromState,
            to: toState,
            completion: completionStub.call)

        XCTAssertEqual(toState.observeDataSourceStub.invocations.count, 1)
        let observeInvocation = try XCTUnwrap(toState.observeDataSourceStub.invocations.first)
        let observeCancelable = try XCTUnwrap(observeInvocation.returnValue as? MockCancelable)

        cancelable.cancel()

        XCTAssertEqual(observeCancelable.cancelStub.invocations.count, 1)
    }
}
