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
    var cameraView: MockCameraView!
    var mapboxMap: MockMapboxMap!
    // swiftlint:disable:next weak_delegate
    var delegate: MockCameraAnimatorDelegate!
    var animator: BasicCameraAnimator!

    override func setUp() {
        super.setUp()
        propertyAnimator = MockPropertyAnimator()
        cameraView = MockCameraView()
        mapboxMap = MockMapboxMap()
        delegate = MockCameraAnimatorDelegate()
        animator = BasicCameraAnimator(
            propertyAnimator: propertyAnimator,
            owner: .unspecified,
            mapboxMap: mapboxMap,
            cameraView: cameraView,
            delegate: delegate)
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
        assertMethodCall(cameraView.removeFromSuperviewStub)
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

        assertMethodCall(propertyAnimator.startAnimationStub)
        assertMethodCall(propertyAnimator.addAnimationsStub)
        assertMethodCall(propertyAnimator.addCompletionStub)
        XCTAssertNotNil(animator?.transition)
        XCTAssertEqual(animator?.transition?.toCameraOptions.zoom, 10)
        assertMethodCall(delegate.cameraAnimatorDidStartRunningStub)
        XCTAssertTrue(delegate.cameraAnimatorDidStartRunningStub.parameters.first === animator)

        animator.stopAnimation()
        assertMethodCall(propertyAnimator.stopAnimationStub)
        assertMethodCall(propertyAnimator.finishAnimationStub)
        XCTAssertEqual(propertyAnimator.finishAnimationStub.invocations.first?.parameters, .current)
        assertMethodCall(delegate.cameraAnimatorDidStopRunningStub)
        XCTAssertTrue(delegate.cameraAnimatorDidStopRunningStub.parameters.first === animator)
    }

    func testStartAndStopAnimationAfterDelay() throws {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }
        let randomInterval: TimeInterval = .random(in: 0...10)
        animator.startAnimation(afterDelay: randomInterval)

        assertMethodCall(self.propertyAnimator.startAnimationStub)
        assertMethodCall(self.propertyAnimator.addAnimationsStub)
        assertMethodCall(self.propertyAnimator.addCompletionStub)

        self.animator.stopAnimation()

        assertMethodCall(self.propertyAnimator.stopAnimationStub)
        assertMethodCall(self.propertyAnimator.finishAnimationStub)
        XCTAssertEqual(self.propertyAnimator.finishAnimationStub.invocations.first?.parameters, .current)
    }

    func testCompletionBlockCalledForStartAndStopAfterDelay() {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }

        let expectation = XCTestExpectation(description: "The completion for the animator should be called when the animation is stopped.")

        let completion: AnimationCompletion = { _ in
            expectation.fulfill()
        }
        animator.addCompletion(completion)

        let randomInterval: TimeInterval = .random(in: 1...10)
        animator.startAnimation(afterDelay: randomInterval)

        animator.stopAnimation()

        wait(for: [expectation], timeout: 15)
    }

    func testStartandPauseAnimationAfterDelay() throws {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }

        animator.startAnimation(afterDelay: 1)

        animator.pauseAnimation()

        assertMethodCall(propertyAnimator.pauseAnimationStub)
        assertMethodNotCall(propertyAnimator.stopAnimationStub)
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
        XCTAssertEqual(animator.state, .active, "The animator's state should be active (1). Got \(animator.state.rawValue).")
    }

    func testStartAndStopAnimationAfterDelayStateInactive() {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }
        animator.startAnimation(afterDelay: 1)
        animator.stopAnimation()
        XCTAssertEqual(propertyAnimator.state, .inactive)
        XCTAssertEqual(animator.state, .inactive, "The animator's state should be inactive (0). Got \(animator.state.rawValue).")
    }

    func testStartAnimationAfterDelayTransitionNotNil() {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }
        animator.startAnimation(afterDelay: 1)
        XCTAssertNotNil(animator.transition, "The transition should not be nil while the animation is delayed. Got \(animator.transition.debugDescription)")
    }

    func testPauseAndStartAnimationAfterDelayError() throws {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }
        animator.pauseAnimation()
        expectFatalError(expectedMessage: "startAnimation(afterDelay:) cannot be called on already-delayed, paused, running, or completed animators.") {
            self.animator.startAnimation(afterDelay: 0)
        }
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
        assertMethodNotCall(delegate.cameraAnimatorDidStartRunningStub)

        animator.startAnimation()
        assertMethodCall(delegate.cameraAnimatorDidStartRunningStub)
        XCTAssertTrue(delegate.cameraAnimatorDidStartRunningStub.parameters.first === animator)
    }

    func testInformsDelegateWhenStartingAfterDelay() {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.startAnimation(afterDelay: 1)
        assertMethodCall(delegate.cameraAnimatorDidStartRunningStub)
        XCTAssertTrue(delegate.cameraAnimatorDidStartRunningStub.parameters.first === animator)
    }

    func testInformsDelegateWhenStartingPausingAndStarting() {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.startAnimation()
        assertMethodCall(delegate.cameraAnimatorDidStartRunningStub)
        XCTAssertTrue(delegate.cameraAnimatorDidStartRunningStub.parameters.first === animator)

        animator.pauseAnimation()
        assertMethodCall(delegate.cameraAnimatorDidStopRunningStub)
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
        assertMethodNotCall(delegate.cameraAnimatorDidStartRunningStub)

        animator.continueAnimation(withTimingParameters: nil, durationFactor: 1)
        assertMethodCall(delegate.cameraAnimatorDidStartRunningStub)
        XCTAssertTrue(delegate.cameraAnimatorDidStartRunningStub.parameters.first === animator)
    }

    func testInformsDelegateWhenStartingPausingAndContinuing() {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.startAnimation()
        assertMethodCall(delegate.cameraAnimatorDidStartRunningStub)
        XCTAssertTrue(delegate.cameraAnimatorDidStartRunningStub.parameters.first === animator)

        animator.pauseAnimation()
        assertMethodCall(delegate.cameraAnimatorDidStopRunningStub)
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
        assertMethodNotCall(delegate.cameraAnimatorDidStartRunningStub)
        assertMethodNotCall(delegate.cameraAnimatorDidStopRunningStub)

        animator.stopAnimation()
        assertMethodNotCall(delegate.cameraAnimatorDidStartRunningStub)
        assertMethodNotCall(delegate.cameraAnimatorDidStopRunningStub)
    }

    func testAnimatorCompletionUpdatesCameraIfAnimationCompletedAtEnd() throws {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.startAnimation()
        let completion = try XCTUnwrap(propertyAnimator.addCompletionStub.parameters.first)

        completion(.end)

        assertMethodCall(mapboxMap.setCameraStub)
    }

    func testAnimatorCompletionUpdatesCameraIfAnimationCompletedAtStart() throws {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.startAnimation()
        let completion = try XCTUnwrap(propertyAnimator.addCompletionStub.parameters.first)

        completion(.start)

        assertMethodCall(mapboxMap.setCameraStub)
    }

    func testAnimatorCompletionDoesNotUpdateCameraIfAnimationCompletedAtCurrent() throws {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.startAnimation()
        let completion = try XCTUnwrap(propertyAnimator.addCompletionStub.parameters.first)

        completion(.current)

        assertMethodNotCall(mapboxMap.setCameraStub)
    }

    func testAnimatorCompletionInformsDelegate() throws {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.startAnimation()
        let completion = try XCTUnwrap(propertyAnimator.addCompletionStub.parameters.first)

        completion(.current)

        assertMethodCall(delegate.cameraAnimatorDidStopRunningStub)
        XCTAssertTrue(delegate.cameraAnimatorDidStopRunningStub.parameters.first === animator)
    }
}
