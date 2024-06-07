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
    private var recordedCameraAnimatorStatus: [CameraAnimatorStatus] = []

    var animationImpl: BasicCameraAnimatorImpl.Animation?
    private var cancelables: Set<AnyCancelable> = []

    override func setUp() {
        super.setUp()
        propertyAnimator = MockPropertyAnimator()
        owner = .init(rawValue: UUID().uuidString)
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
        animator.onCameraAnimatorStatusChanged
            .observe { [unowned self] in self.recordedCameraAnimatorStatus.append($0) }
            .store(in: &cancelables)
    }

    override func tearDown() {
        animator = nil
        animationImpl = nil
        mainQueue = nil
        mapboxMap = nil
        cameraView = nil
        owner = nil
        propertyAnimator = nil
        recordedCameraAnimatorStatus = []
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
        XCTAssertEqual(recordedCameraAnimatorStatus, [.started])

        animator.stopAnimation()
        XCTAssertEqual(propertyAnimator.stopAnimationStub.invocations.count, 1)
        XCTAssertEqual(propertyAnimator.finishAnimationStub.invocations.count, 1)
        XCTAssertEqual(propertyAnimator.finishAnimationStub.invocations.first?.parameters, .current)
        XCTAssertEqual(recordedCameraAnimatorStatus, [.started, .stopped(reason: .cancelled)])
    }

    func testStartAndStopAnimationAfterDelay() throws {
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }
        animator.startAnimation(afterDelay: 3)

        XCTAssertEqual(self.propertyAnimator.startAnimationStub.invocations.count, 1)
        XCTAssertEqual(self.propertyAnimator.addAnimationsStub.invocations.count, 1)
        XCTAssertEqual(self.propertyAnimator.addCompletionStub.invocations.count, 1)
        XCTAssertEqual(recordedCameraAnimatorStatus, [.started])

        self.animator.stopAnimation()

        XCTAssertEqual(self.propertyAnimator.stopAnimationStub.invocations.count, 1)
        XCTAssertEqual(self.propertyAnimator.finishAnimationStub.invocations.count, 1)
        XCTAssertEqual(self.propertyAnimator.finishAnimationStub.invocations.first?.parameters, .current)
        XCTAssertEqual(recordedCameraAnimatorStatus, [.started, .stopped(reason: .cancelled)])
    }

    func testCompletionBlockCalledForStartAndStopAfterDelay() {
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }

        let completion = Stub<UIViewAnimatingPosition, Void>()
        animator.addCompletion(completion.call(with:))

        animator.startAnimation(afterDelay: 5)

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
        XCTAssertEqual(completion.invocations.map(\.parameters), [.current])
        XCTAssertTrue(recordedCameraAnimatorStatus.isEmpty)
    }

    func testStopAndStartAnimation() {
        animator.stopAnimation()

        animator.startAnimation()

        XCTAssertEqual(propertyAnimator.startAnimationStub.invocations.count, 0)
        XCTAssertEqual(propertyAnimator.addAnimationsStub.invocations.count, 0)
        XCTAssertEqual(propertyAnimator.addCompletionStub.invocations.count, 0)
        XCTAssertNil(animator.transition)
        XCTAssertTrue(recordedCameraAnimatorStatus.isEmpty)
    }

    func testStopAndStartAnimationAfterDelay() {
        animator.stopAnimation()

        animator.startAnimation(afterDelay: 1)

        XCTAssertEqual(propertyAnimator.startAnimationAfterDelayStub.invocations.count, 0)
        XCTAssertEqual(propertyAnimator.addAnimationsStub.invocations.count, 0)
        XCTAssertEqual(propertyAnimator.addCompletionStub.invocations.count, 0)
        XCTAssertNil(animator.transition)
        XCTAssertTrue(recordedCameraAnimatorStatus.isEmpty)
    }

    func testStartAndStartAnimationAfterDelay() {
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.startAnimation()
        propertyAnimator.addAnimationsStub.reset()
        propertyAnimator.addCompletionStub.reset()

        animator.startAnimation(afterDelay: 2)

        XCTAssertEqual(propertyAnimator.startAnimationAfterDelayStub.invocations.count, 0)
        XCTAssertEqual(propertyAnimator.addAnimationsStub.invocations.count, 0)
        XCTAssertEqual(propertyAnimator.addCompletionStub.invocations.count, 0)

        XCTAssertEqual(recordedCameraAnimatorStatus, [.started])
    }

    func testStopAndPauseAnimation() {
        animator.stopAnimation()

        animator.pauseAnimation()

        XCTAssertEqual(propertyAnimator.pauseAnimationStub.invocations.count, 0)
        XCTAssertEqual(propertyAnimator.addAnimationsStub.invocations.count, 0)
        XCTAssertEqual(propertyAnimator.addCompletionStub.invocations.count, 0)
        XCTAssertTrue(recordedCameraAnimatorStatus.isEmpty)
    }

    func testStartandPauseAnimationAfterDelay() throws {
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraStateTestValue.zoom
        }

        animator.startAnimation(afterDelay: 1)

        animator.pauseAnimation()

        XCTAssertEqual(propertyAnimator.pauseAnimationStub.invocations.count, 1)
        XCTAssertEqual(propertyAnimator.stopAnimationStub.invocations.count, 0)
        XCTAssertEqual(recordedCameraAnimatorStatus, [.started, .paused])
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

    func testSignalWhenPausingAndStarting() {
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.pauseAnimation()
        XCTAssertTrue(recordedCameraAnimatorStatus.isEmpty)

        animator.startAnimation()
        XCTAssertEqual(recordedCameraAnimatorStatus, [.started])
    }

    func testSignalWhenStartingAfterDelay() {
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.startAnimation(afterDelay: 1)
        XCTAssertEqual(recordedCameraAnimatorStatus, [.started])
    }

    func testSignalWhenStartingPausingAndStarting() {
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.startAnimation()
        XCTAssertEqual(recordedCameraAnimatorStatus, [.started])

        animator.pauseAnimation()
        XCTAssertEqual(recordedCameraAnimatorStatus, [.started, .paused])

        animator.startAnimation()
        XCTAssertEqual(recordedCameraAnimatorStatus, [.started, .paused, .started])
    }

    func testSignalWhenPausingAndContinuing() {
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.pauseAnimation()
        XCTAssertTrue(recordedCameraAnimatorStatus.isEmpty)

        animator.continueAnimation(withTimingParameters: nil, durationFactor: 1)
        XCTAssertEqual(recordedCameraAnimatorStatus, [.started])
    }

    func testSignalWhenStartingPausingAndContinuingUntilFinished() throws {
        animationImpl = { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.startAnimation()
        XCTAssertEqual(recordedCameraAnimatorStatus, [.started])

        animator.pauseAnimation()
        XCTAssertEqual(recordedCameraAnimatorStatus, [.started, .paused])

        animator.continueAnimation(withTimingParameters: nil, durationFactor: 1)
        XCTAssertEqual(recordedCameraAnimatorStatus, [.started, .paused, .started])

        let completion = try XCTUnwrap(propertyAnimator.addCompletionStub.invocations.first?.parameters)
        completion(.end)

        XCTAssertEqual(recordedCameraAnimatorStatus, [.started, .paused, .started, .stopped(reason: .finished)])
    }

    func testSignalWhenPausingAndStopping() {
        animator.startAnimation()

        animationImpl = { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.pauseAnimation()
        XCTAssertEqual(recordedCameraAnimatorStatus, [.started, .paused])

        animator.stopAnimation()
        XCTAssertEqual(recordedCameraAnimatorStatus, [.started, .paused, .stopped(reason: .cancelled)])
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
        XCTAssertEqual(recordedCameraAnimatorStatus, [.started])
        let completion = try XCTUnwrap(propertyAnimator.addCompletionStub.invocations.first?.parameters)

        completion(.current)
        XCTAssertEqual(recordedCameraAnimatorStatus, [.started, .stopped(reason: .cancelled)])
    }
}
