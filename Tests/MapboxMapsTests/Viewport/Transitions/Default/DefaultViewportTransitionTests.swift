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

        XCTAssertEqual(toState.observeDataSourceStub.invocations.count, 1)
        let observeInvocation = try XCTUnwrap(toState.observeDataSourceStub.invocations.first)
        let observeHandler = observeInvocation.parameters
        let observeCancelable = try XCTUnwrap(observeInvocation.returnValue as? MockCancelable)

        let cameraOptions = CameraOptions.random()
        let result = observeHandler(cameraOptions)

        // the handler returns true because it wants continual updates
        XCTAssertTrue(result)

        // verify that makeAnimation was invoked as expected
        XCTAssertEqual(animationHelper.makeAnimationStub.invocations.count, 1)
        let makeAnimationInvocation = try XCTUnwrap(animationHelper.makeAnimationStub.invocations.first)
        XCTAssertEqual(makeAnimationInvocation.parameters.cameraOptions, cameraOptions)
        XCTAssertEqual(makeAnimationInvocation.parameters.maxDuration, options.maxDuration)
        let animation = try XCTUnwrap(makeAnimationInvocation.returnValue as? MockDefaultViewportTransitionAnimation)

        // verify that the returned animation was started
        XCTAssertEqual(animation.startStub.invocations.count, 1)
        let animateCompletion = try XCTUnwrap(animation.startStub.invocations.first?.parameters)

        // invoke the observe handler again to verify that updateTargetCamera is called
        let cameraOptions2 = CameraOptions.random()
        XCTAssertTrue(observeHandler(cameraOptions2))

        XCTAssertEqual(animation.updateTargetCameraStub.invocations.count, 1)
        XCTAssertEqual(animation.updateTargetCameraStub.invocations.first?.parameters, cameraOptions2)

        // exercise the animation completion
        animateCompletion(true) // true means the animation wasn't canceled

        XCTAssertEqual(completionStub.invocations.map(\.parameters), [true])
        XCTAssertEqual(animation.cancelStub.invocations.count, 1)
        XCTAssertEqual(observeCancelable.cancelStub.invocations.count, 1)
    }

    func testRunAnimationCanceled() throws {
        let toState = MockViewportState()
        let completionStub = Stub<Bool, Void>()

        _ = transition.run(
            to: toState,
            completion: completionStub.call(with:))

        XCTAssertEqual(toState.observeDataSourceStub.invocations.count, 1)
        let observeInvocation = try XCTUnwrap(toState.observeDataSourceStub.invocations.first)
        let observeHandler = observeInvocation.parameters
        let observeCancelable = try XCTUnwrap(observeInvocation.returnValue as? MockCancelable)

        let cameraOptions = CameraOptions.random()
        let result = observeHandler(cameraOptions)

        // the handler returns true because it wants continual updates
        XCTAssertTrue(result)

        // verify that makeAnimation was invoked as expected
        XCTAssertEqual(animationHelper.makeAnimationStub.invocations.count, 1)
        let makeAnimationInvocation = try XCTUnwrap(animationHelper.makeAnimationStub.invocations.first)
        XCTAssertEqual(makeAnimationInvocation.parameters.cameraOptions, cameraOptions)
        XCTAssertEqual(makeAnimationInvocation.parameters.maxDuration, options.maxDuration)
        let animation = try XCTUnwrap(makeAnimationInvocation.returnValue as? MockDefaultViewportTransitionAnimation)

        // verify that the returned animation was started
        XCTAssertEqual(animation.startStub.invocations.count, 1)
        let animateCompletion = try XCTUnwrap(animation.startStub.invocations.first?.parameters)

        // exercise the animation completion
        animateCompletion(false) // false means the animation was canceled

        XCTAssertEqual(completionStub.invocations.map(\.parameters), [false])
        XCTAssertEqual(animation.cancelStub.invocations.count, 1)
        XCTAssertEqual(observeCancelable.cancelStub.invocations.count, 1)
    }

    func testRunAndCancelAfterAnimationStarts() throws {
        let toState = MockViewportState()

        let cancelable = transition.run(
            to: toState,
            completion: { _ in })

        XCTAssertEqual(toState.observeDataSourceStub.invocations.count, 1)
        let observeInvocation = try XCTUnwrap(toState.observeDataSourceStub.invocations.first)
        let observeHandler = observeInvocation.parameters
        let observeCancelable = try XCTUnwrap(observeInvocation.returnValue as? MockCancelable)

        let cameraOptions = CameraOptions.random()
        let result = observeHandler(cameraOptions)

        // the handler returns true because it wants continual updates
        XCTAssertTrue(result)

        // verify that makeAnimation was invoked as expected
        XCTAssertEqual(animationHelper.makeAnimationStub.invocations.count, 1)
        let makeAnimationInvocation = try XCTUnwrap(animationHelper.makeAnimationStub.invocations.first)
        XCTAssertEqual(makeAnimationInvocation.parameters.cameraOptions, cameraOptions)
        XCTAssertEqual(makeAnimationInvocation.parameters.maxDuration, options.maxDuration)
        let animation = try XCTUnwrap(makeAnimationInvocation.returnValue as? MockDefaultViewportTransitionAnimation)

        cancelable.cancel()

        XCTAssertEqual(observeCancelable.cancelStub.invocations.count, 1)
        XCTAssertEqual(animation.cancelStub.invocations.count, 1)
    }

    func testRunAndCancelBeforeAnimationStarts() throws {
        let toState = MockViewportState()

        let cancelable = transition.run(
            to: toState,
            completion: { _ in })

        XCTAssertEqual(toState.observeDataSourceStub.invocations.count, 1)
        let observeInvocation = try XCTUnwrap(toState.observeDataSourceStub.invocations.first)
        let observeCancelable = try XCTUnwrap(observeInvocation.returnValue as? MockCancelable)

        cancelable.cancel()

        XCTAssertEqual(observeCancelable.cancelStub.invocations.count, 1)
    }
}
