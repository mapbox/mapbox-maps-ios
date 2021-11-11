import XCTest
@testable import MapboxMaps

let cameraOptionsTestValue = CameraOptions(
    center: CLLocationCoordinate2D(latitude: 10, longitude: 10),
    padding: .init(top: 10, left: 10, bottom: 10, right: 10),
    anchor: .init(x: 10.0, y: 10.0),
    zoom: 10,
    bearing: 10,
    pitch: 10)

let cameraStateTestValue = CameraState(
    MapboxCoreMaps.CameraState(
        center: .init(
            latitude: 10,
            longitude: 10),
        padding: .init(
            top: 10,
            left: 10,
            bottom: 10,
            right: 10),
        zoom: 10,
        bearing: 10,
        pitch: 10))

final class BasicCameraAnimatorTests: XCTestCase {

    var propertyAnimator: MockPropertyAnimator!
    var cameraView: CameraViewMock!
    var mapboxMap: MockMapboxMap!
    // swiftlint:disable:next weak_delegate
    var delegate: MockCameraAnimatorDelegate!
    var timerProvider: Stub<TimerProviderParams, TimerProtocol>!
    var animator: BasicCameraAnimator!

    override func setUp() {
        super.setUp()
        propertyAnimator = MockPropertyAnimator()
        cameraView = CameraViewMock()
        mapboxMap = MockMapboxMap()
        delegate = MockCameraAnimatorDelegate()
        timerProvider = Stub(defaultReturnValue: MockTimer())
        animator = BasicCameraAnimator(
            propertyAnimator: propertyAnimator,
            owner: .unspecified,
            mapboxMap: mapboxMap,
            cameraView: cameraView,
            delegate: delegate,
            timerProvider: timerProvider.stubTimerProvider(_:_:_:))
    }

    override func tearDown() {
        animator = nil
        delegate = nil
        mapboxMap = nil
        cameraView = nil
        propertyAnimator = nil
        super.tearDown()
    }

    func testDeinit() {
        animator = nil
        XCTAssertEqual(cameraView.removeFromSuperviewStub.invocations.count, 1)
        XCTAssertEqual(propertyAnimator.stopAnimationStub.parameters, [true])
        XCTAssertTrue(propertyAnimator.finishAnimationStub.invocations.isEmpty)
    }

    func testIsReversed() {
        animator.isReversed = true

        XCTAssertEqual(propertyAnimator.setIsReversedStub.parameters, [true])

        animator.isReversed = false

        XCTAssertEqual(propertyAnimator.setIsReversedStub.parameters, [true, false])
    }

    func testStartAndStopAnimation() {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }

        animator.startAnimation()

        XCTAssertEqual(propertyAnimator.startAnimationStub.invocations.count, 1)
        XCTAssertEqual(propertyAnimator.addAnimationsStub.invocations.count, 1)
        XCTAssertEqual(propertyAnimator.addCompletionStub.invocations.count, 1)
        XCTAssertNotNil(animator?.transition)
        XCTAssertEqual(animator?.transition?.toCameraOptions.zoom, 10)
        XCTAssertEqual(delegate.cameraAnimatorDidStartRunningStub.invocations.count, 1)
        XCTAssertTrue(delegate.cameraAnimatorDidStartRunningStub.parameters.first === animator)

        animator.stopAnimation()
        XCTAssertEqual(propertyAnimator.stopAnimationStub.invocations.count, 1)
        XCTAssertEqual(propertyAnimator.finishAnimationStub.invocations.count, 1)
        XCTAssertEqual(propertyAnimator.finishAnimationStub.invocations.first?.parameters, .current)
        XCTAssertEqual(delegate.cameraAnimatorDidStopRunningStub.invocations.count, 1)
        XCTAssertTrue(delegate.cameraAnimatorDidStopRunningStub.parameters.first === animator)
    }

    func testStartAndStopAnimationAfterDelay() throws {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }
        XCTAssertTrue(timerProvider.invocations.count == 0)

        let randomInterval: TimeInterval = .random(in: 0...10)
        animator.startAnimation(afterDelay: randomInterval)

        XCTAssertEqual(animator.internalState, .delayed, "The animation should be marked as delayed. Got \(animator.internalState)")
        XCTAssertEqual(timerProvider.parameters.count, 1)
        XCTAssertEqual(timerProvider.parameters.first?.interval, randomInterval, "The interval for the first invocation should be \(randomInterval).")
        XCTAssertEqual(timerProvider.parameters.first?.repeats, false)

        let timer = try XCTUnwrap(timerProvider.returnedValues.first as? MockTimer)
        timerProvider.parameters.first?.block(timer)

        XCTAssertEqual(self.propertyAnimator.startAnimationStub.invocations.count, 1)
        XCTAssertEqual(self.propertyAnimator.addAnimationsStub.invocations.count, 1)
        XCTAssertEqual(self.propertyAnimator.addCompletionStub.invocations.count, 1)

        self.animator.stopAnimation()

        XCTAssertEqual(animator.internalState, .final, "The animation should be marked as final. Got \(animator.internalState)")
        XCTAssertEqual(self.propertyAnimator.stopAnimationStub.invocations.count, 1)
        XCTAssertEqual(self.propertyAnimator.finishAnimationStub.invocations.count, 1)
        XCTAssertEqual(self.propertyAnimator.finishAnimationStub.invocations.first?.parameters, .current)
    }

    func testCompletionBlockCalledForStartAndStopAfterDelay() {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }
        XCTAssertTrue(timerProvider.invocations.count == 0)

        let expectation = XCTestExpectation(description: "The completion for the animator should be called when the animation is stopped.")

        let completion: AnimationCompletion = { _ in
            expectation.fulfill()
        }
        animator.addCompletion(completion)

        let randomInterval: TimeInterval = .random(in: 1...10)
        animator.startAnimation(afterDelay: randomInterval)
        XCTAssertEqual(animator.internalState, .delayed)

        animator.stopAnimation()

        wait(for: [expectation], timeout: 15)
    }

    func testStartandPauseAnimationAfterDelay() throws {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }
        XCTAssertTrue(timerProvider.invocations.count == 0)

        animator.startAnimation(afterDelay: 1)

        let timer = try XCTUnwrap(timerProvider.returnedValues.first as? MockTimer)

        animator.pauseAnimation()

        XCTAssertEqual(propertyAnimator.pauseAnimationStub.invocations.count, 1)
        XCTAssertEqual(propertyAnimator.stopAnimationStub.invocations.count, 0)
        XCTAssertEqual(timer.invalidateStub.invocations.count, 1)
    }

    func testStartAnimationAfterDelayIsRunning() {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }
        XCTAssertFalse(propertyAnimator.isRunning)

        animator.startAnimation(afterDelay: 1)
        XCTAssertTrue(animator.isRunning)
    }

    func testStartAndPauseAnimationAfterDelayIsNotRunning() {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }
        XCTAssertFalse(propertyAnimator.isRunning)

        animator.startAnimation(afterDelay: 1)
        XCTAssertTrue(animator.isRunning)

        animator.pauseAnimation()
        XCTAssertFalse(animator.isRunning)
    }

    func testStartAndStopAnimationAfterDelayIsNotRunning() {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }
        XCTAssertFalse(propertyAnimator.isRunning)

        animator.startAnimation(afterDelay: 1)
        XCTAssertTrue(animator.isRunning)

        animator.stopAnimation()
        XCTAssertFalse(propertyAnimator.isRunning)
        XCTAssertFalse(animator.isRunning)
    }

    func testStartAnimationAfterDelayStateActive() {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }
        XCTAssertEqual(animator.state, .inactive, "The animator's state should be inactive (0) since it hasn't started. Got \(animator.state.NSNumber).")

        animator.startAnimation(afterDelay: 1)
        XCTAssertEqual(animator.state, .active, "The animator's state should be active (1) since it is delayed. Got \(animator.state.NSNumber).")
    }

    func testStartAndPauseAnimationAfterDelayStateActive() {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }
        animator.startAnimation(afterDelay: 1)
        animator.pauseAnimation()
        XCTAssertEqual(propertyAnimator.state, .active)
        XCTAssertEqual(animator.state, .active, "The animator's state should be active (1). Got \(animator.state.NSNumber).")
    }

    func testStartAndStopAnimationAfterDelayStateInactive() {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }
        animator.startAnimation(afterDelay: 1)
        animator.stopAnimation()
        XCTAssertEqual(propertyAnimator.state, .inactive)
        XCTAssertEqual(animator.state, .inactive, "The animator's state should be inactive(0). Got \(animator.state.NSNumber).")
    }

    func testStartAnimationAfterDelayTransitionNil() {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }
        animator.startAnimation(afterDelay: 1)
        XCTAssertNil(animator.transition, "The transition should be nil while the animation is delayed. Got \(animator.transition.debugDescription)")
    }

    func testPauseAndStartAnimationAfterDelayError() throws {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }
        animator.pauseAnimation()
        XCTAssertThrowsError(animator.startAnimation(afterDelay: 0), file: "BasicCameraAnimator", line: 149)
    }

    func testStartandPauseAnimationAfterDelayTransitionNotNil() {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }
        animator.startAnimation(afterDelay: 1)
        animator.pauseAnimation()

        XCTAssertNotNil(animator.transition, "The animator's transition property should not be nil after pausing the animation.")
    }

    func testInformsDelegateWhenPausingAndStarting() {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.pauseAnimation()
        XCTAssertEqual(delegate.cameraAnimatorDidStartRunningStub.invocations.count, 0)

        animator.startAnimation()
        XCTAssertEqual(delegate.cameraAnimatorDidStartRunningStub.invocations.count, 1)
        XCTAssertTrue(delegate.cameraAnimatorDidStartRunningStub.parameters.first === animator)
    }

    func testInformsDelegateWhenStartingAfterDelay() {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.startAnimation(afterDelay: 1)
        XCTAssertEqual(delegate.cameraAnimatorDidStartRunningStub.invocations.count, 1)
        XCTAssertTrue(delegate.cameraAnimatorDidStartRunningStub.parameters.first === animator)
    }

    func testInformsDelegateWhenStartingPausingAndStarting() {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.startAnimation()
        XCTAssertEqual(delegate.cameraAnimatorDidStartRunningStub.invocations.count, 1)
        XCTAssertTrue(delegate.cameraAnimatorDidStartRunningStub.parameters.first === animator)

        animator.pauseAnimation()
        XCTAssertEqual(delegate.cameraAnimatorDidStopRunningStub.invocations.count, 1)
        XCTAssertTrue(delegate.cameraAnimatorDidStopRunningStub.parameters.first === animator)

        animator.startAnimation()
        XCTAssertEqual(delegate.cameraAnimatorDidStartRunningStub.invocations.count, 2)
        XCTAssertTrue(delegate.cameraAnimatorDidStartRunningStub.parameters.last === animator)
    }

    func testInformsDelegateWhenPausingAndContinuing() {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.pauseAnimation()
        XCTAssertEqual(delegate.cameraAnimatorDidStartRunningStub.invocations.count, 0)

        animator.continueAnimation(withTimingParameters: nil, durationFactor: 1)
        XCTAssertEqual(delegate.cameraAnimatorDidStartRunningStub.invocations.count, 1)
        XCTAssertTrue(delegate.cameraAnimatorDidStartRunningStub.parameters.first === animator)
    }

    func testInformsDelegateWhenStartingPausingAndContinuing() {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.startAnimation()
        XCTAssertEqual(delegate.cameraAnimatorDidStartRunningStub.invocations.count, 1)
        XCTAssertTrue(delegate.cameraAnimatorDidStartRunningStub.parameters.first === animator)

        animator.pauseAnimation()
        XCTAssertEqual(delegate.cameraAnimatorDidStopRunningStub.invocations.count, 1)
        XCTAssertTrue(delegate.cameraAnimatorDidStopRunningStub.parameters.first === animator)

        animator.continueAnimation(withTimingParameters: nil, durationFactor: 1)
        XCTAssertEqual(delegate.cameraAnimatorDidStartRunningStub.invocations.count, 2)
        XCTAssertTrue(delegate.cameraAnimatorDidStartRunningStub.parameters.last === animator)
    }

    func testInformsDelegateWhenPausingAndStopping() {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.pauseAnimation()
        XCTAssertEqual(delegate.cameraAnimatorDidStartRunningStub.invocations.count, 0)
        XCTAssertEqual(delegate.cameraAnimatorDidStopRunningStub.invocations.count, 0)

        animator.stopAnimation()
        XCTAssertEqual(delegate.cameraAnimatorDidStartRunningStub.invocations.count, 0)
        XCTAssertEqual(delegate.cameraAnimatorDidStopRunningStub.invocations.count, 0)
    }

    func testAnimatorCompletionUpdatesCameraIfAnimationCompletedAtEnd() throws {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.startAnimation()
        let completion = try XCTUnwrap(propertyAnimator.addCompletionStub.parameters.first)

        completion(.end)

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 1)
    }

    func testAnimatorCompletionUpdatesCameraIfAnimationCompletedAtStart() throws {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.startAnimation()
        let completion = try XCTUnwrap(propertyAnimator.addCompletionStub.parameters.first)

        completion(.start)

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 1)
    }

    func testAnimatorCompletionDoesNotUpdateCameraIfAnimationCompletedAtCurrent() throws {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.startAnimation()
        let completion = try XCTUnwrap(propertyAnimator.addCompletionStub.parameters.first)

        completion(.current)

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 0)
    }

    func testAnimatorCompletionInformsDelegate() throws {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.startAnimation()
        let completion = try XCTUnwrap(propertyAnimator.addCompletionStub.parameters.first)

        completion(.current)

        XCTAssertEqual(delegate.cameraAnimatorDidStopRunningStub.invocations.count, 1)
        XCTAssertTrue(delegate.cameraAnimatorDidStopRunningStub.parameters.first === animator)
    }
}

struct TimerProviderParams {
    var interval: TimeInterval
    var repeats: Bool
    var block: (TimerProtocol) -> Void
}

final class MockTimer: TimerProtocol {
    let invalidateStub = Stub<Void, Void>()
    func invalidate() {
        invalidateStub.call()
    }
}

extension Stub where ParametersType == TimerProviderParams, ReturnType == TimerProtocol {
    func stubTimerProvider(_ interval: TimeInterval, _ repeats: Bool, _ block: @escaping (TimerProtocol) -> Void) -> TimerProtocol {
        call(with: TimerProviderParams(interval: interval, repeats: repeats, block: block))
    }
}
