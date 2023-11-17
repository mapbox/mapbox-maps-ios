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
    CoreCameraState(
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

final class BasicCameraAnimatorImplTests: XCTestCase {

    var propertyAnimator: MockPropertyAnimator!
    var owner: AnimationOwner!
    var cameraView: MockCameraView!
    var mapboxMap: MockMapboxMap!
    var mainQueue: MockMainQueue!
    var animator: BasicCameraAnimatorImpl!
    // swiftlint:disable:next weak_delegate
    var delegate: MockBasicCameraAnimatorDelegate!

    var animationImpl: BasicCameraAnimatorImpl.Animation?

    override func setUp() {
        super.setUp()
        propertyAnimator = MockPropertyAnimator()
        owner = .random()
        cameraView = MockCameraView()
        mapboxMap = MockMapboxMap()
        mainQueue = MockMainQueue()
        animator = BasicCameraAnimatorImpl(
            propertyAnimator: propertyAnimator,
            owner: owner,
            mapboxMap: mapboxMap,
            mainQueue: mainQueue,
            cameraView: cameraView,
            animation: { transition in
                self.animationImpl?(&transition)
            })
        delegate = MockBasicCameraAnimatorDelegate()
        animator.delegate = delegate
    }

    override func tearDown() {
        delegate = nil
        animator = nil
        animationImpl = nil
        mainQueue = nil
        mapboxMap = nil
        cameraView = nil
        owner = nil
        propertyAnimator = nil
        super.tearDown()
    }

    func testOwner() {
        XCTAssertEqual(animator.owner, owner)
    }

    func testDeinit() {
        animator = nil
        XCTAssertEqual(cameraView.removeFromSuperviewStub.invocations.count, 1)
        XCTAssertEqual(propertyAnimator.stopAnimationStub.invocations.map(\.parameters), [true])
        XCTAssertTrue(propertyAnimator.finishAnimationStub.invocations.isEmpty)
    }

    func testIsReversed() {
        animator.isReversed = true

        XCTAssertEqual(propertyAnimator.setIsReversedStub.invocations.map(\.parameters), [true])

        animator.isReversed = false

        XCTAssertEqual(propertyAnimator.setIsReversedStub.invocations.map(\.parameters), [true, false])
    }

    func testStartAndStopAnimation() {
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }

        animator.startAnimation()

        XCTAssertEqual(propertyAnimator.startAnimationStub.invocations.count, 1)
        XCTAssertEqual(propertyAnimator.addAnimationsStub.invocations.count, 1)
        XCTAssertEqual(propertyAnimator.addCompletionStub.invocations.count, 1)
        XCTAssertNotNil(animator?.transition)
        XCTAssertEqual(animator?.transition?.toCameraOptions.zoom, 10)
        XCTAssertEqual(delegate.basicCameraAnimatorDidStartRunningStub.invocations.count, 1)
        XCTAssertTrue(delegate.basicCameraAnimatorDidStartRunningStub.invocations.first?.parameters === animator)

        animator.stopAnimation()
        XCTAssertEqual(propertyAnimator.stopAnimationStub.invocations.count, 1)
        XCTAssertEqual(propertyAnimator.finishAnimationStub.invocations.count, 1)
        XCTAssertEqual(propertyAnimator.finishAnimationStub.invocations.first?.parameters, .current)
        XCTAssertEqual(delegate.basicCameraAnimatorDidStopRunningStub.invocations.count, 1)
        XCTAssertTrue(delegate.basicCameraAnimatorDidStopRunningStub.invocations.first?.parameters === animator)
    }

    func testStartAndStopAnimationAfterDelay() throws {
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }
        let randomInterval: TimeInterval = .random(in: 0...10)
        animator.startAnimation(afterDelay: randomInterval)

        XCTAssertEqual(self.propertyAnimator.startAnimationStub.invocations.count, 1)
        XCTAssertEqual(self.propertyAnimator.addAnimationsStub.invocations.count, 1)
        XCTAssertEqual(self.propertyAnimator.addCompletionStub.invocations.count, 1)

        self.animator.stopAnimation()

        XCTAssertEqual(self.propertyAnimator.stopAnimationStub.invocations.count, 1)
        XCTAssertEqual(self.propertyAnimator.finishAnimationStub.invocations.count, 1)
        XCTAssertEqual(self.propertyAnimator.finishAnimationStub.invocations.first?.parameters, .current)
    }

    func testCompletionBlockCalledForStartAndStopAfterDelay() {
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }

        let completion = Stub<UIViewAnimatingPosition, Void>()
        animator.addCompletion(completion.call(with:))

        let randomInterval: TimeInterval = .random(in: 1...10)
        animator.startAnimation(afterDelay: randomInterval)

        animator.stopAnimation()

        XCTAssertEqual(completion.invocations.map(\.parameters), [.current])
    }

    func testAddCompletionToRunningAnimator() {
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }
        animator.startAnimation()

        let completion = Stub<UIViewAnimatingPosition, Void>()
        animator.addCompletion(completion.call(with:))

        animator.stopAnimation()

        XCTAssertEqual(completion.invocations.map(\.parameters), [.current])
    }

    func testAddCompletionToPausedAnimator() {
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }
        animator.startAnimation()
        animator.pauseAnimation()

        let completion = Stub<UIViewAnimatingPosition, Void>()
        animator.addCompletion(completion.call(with:))

        animator.stopAnimation()

        XCTAssertEqual(completion.invocations.map(\.parameters), [.current])
    }

    func testAddCompletionToCanceledAnimator() throws {
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }
        animator.startAnimation()
        animator.stopAnimation()

        let completion = Stub<UIViewAnimatingPosition, Void>()
        animator.addCompletion(completion.call(with:))

        XCTAssertEqual(mainQueue.asyncClosureStub.invocations.count, 1)
        let closure = try XCTUnwrap(mainQueue.asyncClosureStub.invocations.first?.parameters.work)

        closure()

        XCTAssertEqual(completion.invocations.map(\.parameters), [.current])
    }

    func testAddCompletionToCompletedAnimator() throws {
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }
        animator.startAnimation()
        let propertyAnimatorCompletion = try XCTUnwrap(propertyAnimator.addCompletionStub.invocations.first?.parameters)
        propertyAnimatorCompletion(.end)

        let completion = Stub<UIViewAnimatingPosition, Void>()
        animator.addCompletion(completion.call(with:))

        XCTAssertEqual(mainQueue.asyncClosureStub.invocations.count, 1)
        let closure = try XCTUnwrap(mainQueue.asyncClosureStub.invocations.first?.parameters.work)

        closure()

        XCTAssertEqual(completion.invocations.map(\.parameters), [.end])
    }

    func testStopAnimationWithoutStarting() {
        let completion = Stub<UIViewAnimatingPosition, Void>()
        animator.addCompletion(completion.call(with:))

        animator.stopAnimation()

        XCTAssertEqual(propertyAnimator.stopAnimationStub.invocations.count, 0)
        XCTAssertEqual(propertyAnimator.finishAnimationStub.invocations.count, 0)
        XCTAssertEqual(delegate.basicCameraAnimatorDidStopRunningStub.invocations.count, 0)
        XCTAssertEqual(completion.invocations.map(\.parameters), [.current])
    }

    func testStopAndStartAnimation() {
        animator.stopAnimation()

        animator.startAnimation()

        XCTAssertEqual(propertyAnimator.startAnimationStub.invocations.count, 0)
        XCTAssertEqual(propertyAnimator.addAnimationsStub.invocations.count, 0)
        XCTAssertEqual(propertyAnimator.addCompletionStub.invocations.count, 0)
        XCTAssertNil(animator.transition)
        XCTAssertEqual(delegate.basicCameraAnimatorDidStartRunningStub.invocations.count, 0)
    }

    func testStopAndStartAnimationAfterDelay() {
        animator.stopAnimation()

        animator.startAnimation(afterDelay: .random(in: 0...10))

        XCTAssertEqual(propertyAnimator.startAnimationAfterDelayStub.invocations.count, 0)
        XCTAssertEqual(propertyAnimator.addAnimationsStub.invocations.count, 0)
        XCTAssertEqual(propertyAnimator.addCompletionStub.invocations.count, 0)
        XCTAssertNil(animator.transition)
        XCTAssertEqual(delegate.basicCameraAnimatorDidStartRunningStub.invocations.count, 0)
    }

    func testStartAndStartAnimationAfterDelay() {
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.startAnimation()
        propertyAnimator.addAnimationsStub.reset()
        propertyAnimator.addCompletionStub.reset()
        delegate.basicCameraAnimatorDidStartRunningStub.reset()

        animator.startAnimation(afterDelay: .random(in: 0...10))

        XCTAssertEqual(propertyAnimator.startAnimationAfterDelayStub.invocations.count, 0)
        XCTAssertEqual(propertyAnimator.addAnimationsStub.invocations.count, 0)
        XCTAssertEqual(propertyAnimator.addCompletionStub.invocations.count, 0)
        XCTAssertEqual(delegate.basicCameraAnimatorDidStartRunningStub.invocations.count, 0)
    }

    func testStopAndPauseAnimation() {
        animator.stopAnimation()

        animator.pauseAnimation()

        XCTAssertEqual(propertyAnimator.pauseAnimationStub.invocations.count, 0)
        XCTAssertEqual(propertyAnimator.addAnimationsStub.invocations.count, 0)
        XCTAssertEqual(propertyAnimator.addCompletionStub.invocations.count, 0)
    }

    func testStartandPauseAnimationAfterDelay() throws {
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }

        animator.startAnimation(afterDelay: 1)

        animator.pauseAnimation()

        XCTAssertEqual(propertyAnimator.pauseAnimationStub.invocations.count, 1)
        XCTAssertEqual(propertyAnimator.stopAnimationStub.invocations.count, 0)
    }

    func testStartAnimationAfterDelayIsRunning() {
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }
        XCTAssertFalse(propertyAnimator.isRunning)

        animator.startAnimation(afterDelay: 1)
        XCTAssertTrue(animator.isRunning)
    }

    func testStartAndPauseAnimationAfterDelayIsNotRunning() {
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }
        XCTAssertFalse(propertyAnimator.isRunning)

        animator.startAnimation(afterDelay: 1)
        XCTAssertTrue(animator.isRunning)

        animator.pauseAnimation()
        XCTAssertFalse(animator.isRunning)
    }

    func testStartAndStopAnimationAfterDelayIsNotRunning() {
        animationImpl = { (transition) in
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
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }
        XCTAssertEqual(animator.state, .inactive, "The animator's state should be inactive (0) since it hasn't started. Got \(animator.state.NSNumber).")

        animator.startAnimation(afterDelay: 1)
        XCTAssertEqual(animator.state, .active, "The animator's state should be active (1) since it is delayed. Got \(animator.state.NSNumber).")
    }

    func testStartAndPauseAnimationAfterDelayStateActive() {
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }
        animator.startAnimation(afterDelay: 1)
        animator.pauseAnimation()
        XCTAssertEqual(propertyAnimator.state, .active)
        XCTAssertEqual(animator.state, .active, "The animator's state should be active (1). Got \(animator.state.rawValue).")
    }

    func testStartAndStopAnimationAfterDelayStateInactive() {
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }
        animator.startAnimation(afterDelay: 1)
        animator.stopAnimation()
        XCTAssertEqual(propertyAnimator.state, .inactive)
        XCTAssertEqual(animator.state, .inactive, "The animator's state should be inactive (0). Got \(animator.state.rawValue).")
    }

    func testStartAnimationAfterDelayTransitionNotNil() {
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }
        animator.startAnimation(afterDelay: 1)
        XCTAssertNotNil(animator.transition, "The transition should not be nil while the animation is delayed. Got \(animator.transition.debugDescription)")
    }

    func testStartandPauseAnimationAfterDelayTransitionNotNil() {
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }
        animator.startAnimation(afterDelay: 1)
        animator.pauseAnimation()

        XCTAssertNotNil(animator.transition, "The animator's transition property should not be nil after pausing the animation.")
    }

    func testInformsDelegateWhenPausingAndStarting() {
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.pauseAnimation()
        XCTAssertEqual(delegate.basicCameraAnimatorDidStartRunningStub.invocations.count, 0)

        animator.startAnimation()
        XCTAssertEqual(delegate.basicCameraAnimatorDidStartRunningStub.invocations.count, 1)
        XCTAssertTrue(delegate.basicCameraAnimatorDidStartRunningStub.invocations.first?.parameters === animator)
    }

    func testInformsDelegateWhenStartingAfterDelay() {
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.startAnimation(afterDelay: 1)
        XCTAssertEqual(delegate.basicCameraAnimatorDidStartRunningStub.invocations.count, 1)
        XCTAssertTrue(delegate.basicCameraAnimatorDidStartRunningStub.invocations.first?.parameters === animator)
    }

    func testInformsDelegateWhenStartingPausingAndStarting() {
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.startAnimation()
        XCTAssertEqual(delegate.basicCameraAnimatorDidStartRunningStub.invocations.count, 1)
        XCTAssertTrue(delegate.basicCameraAnimatorDidStartRunningStub.invocations.first?.parameters === animator)

        animator.pauseAnimation()
        XCTAssertEqual(delegate.basicCameraAnimatorDidStopRunningStub.invocations.count, 1)
        XCTAssertTrue(delegate.basicCameraAnimatorDidStopRunningStub.invocations.first?.parameters === animator)

        animator.startAnimation()
        XCTAssertEqual(delegate.basicCameraAnimatorDidStartRunningStub.invocations.count, 2)
        XCTAssertTrue(delegate.basicCameraAnimatorDidStartRunningStub.invocations.last?.parameters === animator)
    }

    func testInformsDelegateWhenPausingAndContinuing() {
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.pauseAnimation()
        XCTAssertEqual(delegate.basicCameraAnimatorDidStartRunningStub.invocations.count, 0)

        animator.continueAnimation(withTimingParameters: nil, durationFactor: 1)
        XCTAssertEqual(delegate.basicCameraAnimatorDidStartRunningStub.invocations.count, 1)
        XCTAssertTrue(delegate.basicCameraAnimatorDidStartRunningStub.invocations.first?.parameters === animator)
    }

    func testInformsDelegateWhenStartingPausingAndContinuing() {
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.startAnimation()
        XCTAssertEqual(delegate.basicCameraAnimatorDidStartRunningStub.invocations.count, 1)
        XCTAssertTrue(delegate.basicCameraAnimatorDidStartRunningStub.invocations.first?.parameters === animator)

        animator.pauseAnimation()
        XCTAssertEqual(delegate.basicCameraAnimatorDidStopRunningStub.invocations.count, 1)
        XCTAssertTrue(delegate.basicCameraAnimatorDidStopRunningStub.invocations.first?.parameters === animator)

        animator.continueAnimation(withTimingParameters: nil, durationFactor: 1)
        XCTAssertEqual(delegate.basicCameraAnimatorDidStartRunningStub.invocations.count, 2)
        XCTAssertTrue(delegate.basicCameraAnimatorDidStartRunningStub.invocations.last?.parameters === animator)
    }

    func testInformsDelegateWhenPausingAndStopping() {
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.pauseAnimation()
        XCTAssertEqual(delegate.basicCameraAnimatorDidStartRunningStub.invocations.count, 0)
        XCTAssertEqual(delegate.basicCameraAnimatorDidStopRunningStub.invocations.count, 0)

        animator.stopAnimation()
        XCTAssertEqual(delegate.basicCameraAnimatorDidStartRunningStub.invocations.count, 0)
        XCTAssertEqual(delegate.basicCameraAnimatorDidStopRunningStub.invocations.count, 0)
    }

    func testAnimatorCompletionUpdatesCameraIfAnimationCompletedAtEnd() throws {
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.startAnimation()
        let completion = try XCTUnwrap(propertyAnimator.addCompletionStub.invocations.first?.parameters)

        completion(.end)

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 1)
    }

    func testAnimatorCompletionUpdatesCameraIfAnimationCompletedAtStart() throws {
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.startAnimation()
        let completion = try XCTUnwrap(propertyAnimator.addCompletionStub.invocations.first?.parameters)

        completion(.start)

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 1)
    }

    func testAnimatorCompletionDoesNotUpdateCameraIfAnimationCompletedAtCurrent() throws {
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.startAnimation()
        let completion = try XCTUnwrap(propertyAnimator.addCompletionStub.invocations.first?.parameters)

        completion(.current)

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 0)
    }

    func testAnimatorCompletionInformsDelegate() throws {
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.startAnimation()
        let completion = try XCTUnwrap(propertyAnimator.addCompletionStub.invocations.first?.parameters)

        completion(.current)

        XCTAssertEqual(delegate.basicCameraAnimatorDidStopRunningStub.invocations.count, 1)
        XCTAssertTrue(delegate.basicCameraAnimatorDidStopRunningStub.invocations.first?.parameters === animator)
    }
}
