import XCTest
@testable @_spi(Experimental) import MapboxMaps

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
        let toState = MockViewportState()
        let completionStub = Stub<Bool, Void>()

        _ = transition.run(
            to: toState,
            completion: completionStub.call(with:))

        assertMethodCall(toState.observeDataSourceStub)
        let observeInvocation = try XCTUnwrap(toState.observeDataSourceStub.invocations.first)
        let observeHandler = observeInvocation.parameters

        let cameraOptions = CameraOptions.random()
        let result = observeHandler(cameraOptions)

        // the handler returns false because it only wants one update
        XCTAssertFalse(result)

        // verify that animate was invoked as expected
        assertMethodCall(animationHelper.animateStub)
        let animateInvocation = try XCTUnwrap(animationHelper.animateStub.invocations.first)
        XCTAssertEqual(animateInvocation.parameters.cameraOptions, cameraOptions)
        XCTAssertEqual(animateInvocation.parameters.maxDuration, options.maxDuration)

        let animateCompletion = animateInvocation.parameters.completion

        // exercise the animation completion
        animateCompletion(true) // true means the animation wasn't canceled

        XCTAssertEqual(completionStub.invocations.map(\.parameters), [true])
    }

    func testRunAnimationCanceled() throws {
        let toState = MockViewportState()
        let completionStub = Stub<Bool, Void>()

        _ = transition.run(
            to: toState,
            completion: completionStub.call(with:))

        assertMethodCall(toState.observeDataSourceStub)
        let observeInvocation = try XCTUnwrap(toState.observeDataSourceStub.invocations.first)
        let observeHandler = observeInvocation.parameters

        let cameraOptions = CameraOptions.random()
        let result = observeHandler(cameraOptions)

        // the handler returns false because it only wants one update
        XCTAssertFalse(result)

        // verify that animate was invoked as expected
        assertMethodCall(animationHelper.animateStub)
        let animateInvocation = try XCTUnwrap(animationHelper.animateStub.invocations.first)
        XCTAssertEqual(animateInvocation.parameters.cameraOptions, cameraOptions)
        XCTAssertEqual(animateInvocation.parameters.maxDuration, options.maxDuration)

        let animateCompletion = animateInvocation.parameters.completion

        // exercise the animation completion
        animateCompletion(false) // false means the animation was canceled

        XCTAssertEqual(completionStub.invocations.map(\.parameters), [false])
    }

    func testRunAndCancelAfterAnimationStarts() throws {
        let toState = MockViewportState()

        let cancelable = transition.run(
            to: toState,
            completion: { _ in })

        assertMethodCall(toState.observeDataSourceStub)
        let observeInvocation = try XCTUnwrap(toState.observeDataSourceStub.invocations.first)
        let observeHandler = observeInvocation.parameters
        let observeCancelable = try XCTUnwrap(observeInvocation.returnValue as? MockCancelable)

        let cameraOptions = CameraOptions.random()
        let result = observeHandler(cameraOptions)

        // the handler returns false because it only wants one update
        XCTAssertFalse(result)

        // verify that animate was invoked as expected
        assertMethodCall(animationHelper.animateStub)
        let animateInvocation = try XCTUnwrap(animationHelper.animateStub.invocations.first)
        XCTAssertEqual(animateInvocation.parameters.cameraOptions, cameraOptions)
        XCTAssertEqual(animateInvocation.parameters.maxDuration, options.maxDuration)

        let animateCancelable = try XCTUnwrap(animateInvocation.returnValue as? MockCancelable)

        cancelable.cancel()

        assertMethodCall(observeCancelable.cancelStub)
        assertMethodCall(animateCancelable.cancelStub)
    }

    func testRunAndCancelBeforeAnimationStarts() throws {
        let toState = MockViewportState()

        let cancelable = transition.run(
            to: toState,
            completion: { _ in })

        assertMethodCall(toState.observeDataSourceStub)
        let observeInvocation = try XCTUnwrap(toState.observeDataSourceStub.invocations.first)
        let observeCancelable = try XCTUnwrap(observeInvocation.returnValue as? MockCancelable)

        cancelable.cancel()

        assertMethodCall(observeCancelable.cancelStub)
    }
}
