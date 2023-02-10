@testable import MapboxMaps
import XCTest

final class SimpleCameraAnimatorTests: XCTestCase {

    var from: CameraOptions!
    var to: CameraOptions!
    var duration: TimeInterval!
    var curve: TimingCurve!
    var owner: AnimationOwner!
    var mapboxMap: MockMapboxMap!
    var mainQueue: MockMainQueue!
    var cameraOptionsInterpolator: MockCameraOptionsInterpolator!
    var dateProvider: MockDateProvider!
    var animator: SimpleCameraAnimator!
    var delegate: MockCameraAnimatorDelegate!

    override func setUp() {
        super.setUp()
        from = .random()
        to = .random()
        duration = .random(in: 1...10)
        curve = .random()
        owner = .random()
        mapboxMap = MockMapboxMap()
        mainQueue = MockMainQueue()
        cameraOptionsInterpolator = MockCameraOptionsInterpolator()
        dateProvider = MockDateProvider()
        animator = SimpleCameraAnimator(
            from: from,
            to: to,
            duration: duration,
            curve: curve,
            owner: owner,
            mapboxMap: mapboxMap,
            mainQueue: mainQueue,
            cameraOptionsInterpolator: cameraOptionsInterpolator,
            dateProvider: dateProvider)
        delegate = MockCameraAnimatorDelegate()
        animator.delegate = delegate
    }

    override func tearDown() {
        delegate = nil
        animator = nil
        dateProvider = nil
        cameraOptionsInterpolator = nil
        mainQueue = nil
        mapboxMap = nil
        owner = nil
        curve = nil
        duration = nil
        to = nil
        from = nil
        super.tearDown()
    }

    func recreateAnimator() {
        animator = SimpleCameraAnimator(
            from: from,
            to: to,
            duration: duration,
            curve: curve,
            owner: owner,
            mapboxMap: mapboxMap,
            mainQueue: mainQueue,
            cameraOptionsInterpolator: cameraOptionsInterpolator,
            dateProvider: dateProvider)
        animator.delegate = delegate
    }

    func testOwner() {
        XCTAssertEqual(animator.owner, owner)
    }

    func testTo() {
        XCTAssertEqual(animator.to, to)
    }

    func testInitialState() {
        XCTAssertEqual(animator.state, .inactive)
    }

    func testStartAnimationSetsStateToActive() {
        animator.startAnimation()

        XCTAssertEqual(animator.state, .active)
    }

    func testStartAnimationCallsDelegate() {
        animator.startAnimation()

        XCTAssertEqual(delegate.cameraAnimatorDidStartRunningStub.invocations.count, 1)
        XCTAssertIdentical(delegate.cameraAnimatorDidStartRunningStub.invocations.first?.parameters, animator)
    }

    func testStartAnimationAgainWhileItIsRunningDoesNotChangeTheUpdateFraction() {
        curve = TimingCurve(p1: .zero, p2: .init(x: 1, y: 1))
        recreateAnimator()
        animator.startAnimation()

        // set time to half way and start again
        dateProvider.nowStub.defaultReturnValue += duration / 2
        animator.startAnimation()

        // now update — the fraction should be 0.5
        animator.update()

        XCTAssertEqual(cameraOptionsInterpolator.interpolateStub.invocations.count, 1)
        XCTAssertEqual(cameraOptionsInterpolator.interpolateStub.invocations.first?.parameters.fraction, 0.5)
    }

    func testStartAnimationWhileItIsCompleteDoesNotChangeTheState() {
        animator.startAnimation()
        animator.cancel()

        animator.startAnimation()

        XCTAssertEqual(animator.state, .inactive)
    }

    func testStartAnimationAfterDelaySetsStateToActive() {
        animator.startAnimation(afterDelay: .random(in: 0...10))

        XCTAssertEqual(animator.state, .active)
    }

    func testStartAnimationAfterDelayCallsDelegate() {
        animator.startAnimation(afterDelay: .random(in: 0...10))

        XCTAssertEqual(delegate.cameraAnimatorDidStartRunningStub.invocations.count, 1)
        XCTAssertIdentical(delegate.cameraAnimatorDidStartRunningStub.invocations.first?.parameters, animator)
    }

    func testStartAnimationAfterDelayAgainWhileItIsRunningDoesNotChangeTheUpdateFraction() {
        curve = TimingCurve(p1: .zero, p2: .init(x: 1, y: 1))
        recreateAnimator()
        animator.startAnimation()

        // set time to half way and start again
        dateProvider.nowStub.defaultReturnValue += duration / 2
        animator.startAnimation(afterDelay: .random(in: 1...10))

        // now update — the fraction should be 0.5
        animator.update()

        XCTAssertEqual(cameraOptionsInterpolator.interpolateStub.invocations.count, 1)
        XCTAssertEqual(cameraOptionsInterpolator.interpolateStub.invocations.first?.parameters.fraction, 0.5)
    }

    func testStartAnimationAfterDelayWhileItIsCompleteDoesNotChangeTheState() {
        animator.startAnimation()
        animator.cancel()

        animator.startAnimation(afterDelay: .random(in: 1...10))

        XCTAssertEqual(animator.state, .inactive)
    }

    func testUpdateAnimationWhenItHasNotYetStartedDoesNotSetCamera() {
        animator.update()

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 0)
    }

    func testUpdateAnimationBeforeDelayIsOverDoesNotSetCamera() {
        animator.startAnimation(afterDelay: .random(in: 1...10))

        animator.update()

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 0)
    }

    func testUpdateAnimationWhenTimeElapsedIsZeroInvokesInterpolator() {
        animator.startAnimation()

        animator.update()

        XCTAssertEqual(cameraOptionsInterpolator.interpolateStub.invocations.count, 1)
        XCTAssertEqual(cameraOptionsInterpolator.interpolateStub.invocations.first?.parameters.from, from)
        XCTAssertEqual(cameraOptionsInterpolator.interpolateStub.invocations.first?.parameters.to, to)
        XCTAssertEqual(cameraOptionsInterpolator.interpolateStub.invocations.first?.parameters.fraction, 0)
    }

    func testUpdateAnimationWhenTimeElapsedIsZeroSetsCamera() throws {
        animator.startAnimation()

        animator.update()

        let returnedValue = try XCTUnwrap(cameraOptionsInterpolator.interpolateStub.invocations.first?.returnValue)
        XCTAssertEqual(mapboxMap.setCameraStub.invocations.map(\.parameters), [returnedValue])
    }

    func testUpdateAnimationWhenTimeElapsedIsDurationDoesNotInvokeInterpolator() {
        animator.startAnimation()
        dateProvider.nowStub.defaultReturnValue = dateProvider.now + duration

        animator.update()

        XCTAssertEqual(cameraOptionsInterpolator.interpolateStub.invocations.count, 0)
    }

    func testUpdateAnimationWhenTimeElapsedIsDurationSetsCameraToTo() {
        animator.startAnimation()
        dateProvider.nowStub.defaultReturnValue = dateProvider.now + duration

        animator.update()

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.map(\.parameters), [to])
    }

    func testUpdateAnimationWhenTimeElapsedIsDurationCallsDelegate() {
        animator.startAnimation()
        dateProvider.nowStub.defaultReturnValue = dateProvider.now + duration

        animator.update()

        XCTAssertEqual(delegate.cameraAnimatorDidStopRunningStub.invocations.count, 1)
        XCTAssertIdentical(delegate.cameraAnimatorDidStopRunningStub.invocations.first?.parameters, animator)
    }

    func testUpdateAnimationWhenTimeElapsedIsDurationSetsStateToInactive() {
        animator.startAnimation()
        dateProvider.nowStub.defaultReturnValue = dateProvider.now + duration

        animator.update()

        XCTAssertEqual(animator.state, .inactive)
    }

    func testUpdateAnimationWhenTimeElapsedIsDurationInvokesCompletionBlocks() {
        let completionStub = Stub<UIViewAnimatingPosition, Void>()
        animator.addCompletion(completionStub.call(with:))
        animator.startAnimation()
        dateProvider.nowStub.defaultReturnValue = dateProvider.now + duration

        animator.update()

        XCTAssertEqual(completionStub.invocations.map(\.parameters), [.end])
    }

    func testCancelAnimationBeforeItStartsSetsItsStateToInactive() {
        animator.cancel()

        XCTAssertEqual(animator.state, .inactive)
    }

    func testCancelAnimationBeforeItStartsInvokesCompletionBlocks() {
        let completionStub = Stub<UIViewAnimatingPosition, Void>()
        animator.addCompletion(completionStub.call(with:))

        animator.cancel()

        XCTAssertEqual(completionStub.invocations.map(\.parameters), [.current])
    }

    func testCancelAnimationWhileItIsDelayedSetsItsStateToInactive() {
        animator.startAnimation(afterDelay: .random(in: 1...10))

        animator.cancel()

        XCTAssertEqual(animator.state, .inactive)
    }

    func testCancelAnimationWhileItIsDelayedInvokesCompletionBlocks() {
        let completionStub = Stub<UIViewAnimatingPosition, Void>()
        animator.addCompletion(completionStub.call(with:))
        animator.startAnimation(afterDelay: .random(in: 1...10))

        animator.cancel()

        XCTAssertEqual(completionStub.invocations.map(\.parameters), [.current])
    }

    func testCancelAnimationWhileItIsRunningSetsItsStateToInactive() {
        animator.startAnimation()

        animator.cancel()

        XCTAssertEqual(animator.state, .inactive)
    }

    func testCancelAnimationWhileItIsRunningInvokesCompletionBlocks() {
        let completionStub = Stub<UIViewAnimatingPosition, Void>()
        animator.addCompletion(completionStub.call(with:))
        animator.startAnimation()

        animator.cancel()

        XCTAssertEqual(completionStub.invocations.map(\.parameters), [.current])
    }

    func testCancelAnimationWhileItIsAlreadyFinishedDoesNotCallCompletionBlocksAgain() {
        let completionStub = Stub<UIViewAnimatingPosition, Void>()
        animator.addCompletion(completionStub.call(with:))
        animator.startAnimation()
        animator.cancel()
        completionStub.reset()

        animator.cancel()

        XCTAssertEqual(completionStub.invocations.count, 0)
    }

    func testStopAnimationBeforeItStartsSetsItsStateToInactive() {
        animator.stopAnimation()

        XCTAssertEqual(animator.state, .inactive)
    }

    func testStopAnimationBeforeItStartsInvokesCompletionBlocks() {
        let completionStub = Stub<UIViewAnimatingPosition, Void>()
        animator.addCompletion(completionStub.call(with:))

        animator.stopAnimation()

        XCTAssertEqual(completionStub.invocations.map(\.parameters), [.current])
    }

    func testStopAnimationWhileItIsDelayedSetsItsStateToInactive() {
        animator.startAnimation(afterDelay: .random(in: 1...10))

        animator.stopAnimation()

        XCTAssertEqual(animator.state, .inactive)
    }

    func testStopAnimationWhileItIsDelayedInvokesCompletionBlocks() {
        let completionStub = Stub<UIViewAnimatingPosition, Void>()
        animator.addCompletion(completionStub.call(with:))
        animator.startAnimation(afterDelay: .random(in: 1...10))

        animator.stopAnimation()

        XCTAssertEqual(completionStub.invocations.map(\.parameters), [.current])
    }

    func testStopAnimationWhileItIsRunningSetsItsStateToInactive() {
        animator.startAnimation()

        animator.stopAnimation()

        XCTAssertEqual(animator.state, .inactive)
    }

    func testStopAnimationWhileItIsRunningInvokesCompletionBlocks() {
        let completionStub = Stub<UIViewAnimatingPosition, Void>()
        animator.addCompletion(completionStub.call(with:))
        animator.startAnimation()

        animator.stopAnimation()

        XCTAssertEqual(completionStub.invocations.map(\.parameters), [.current])
    }

    func testStopAnimationWhileItIsAlreadyFinishedDoesNotCallCompletionBlocksAgain() {
        let completionStub = Stub<UIViewAnimatingPosition, Void>()
        animator.addCompletion(completionStub.call(with:))
        animator.startAnimation()
        animator.cancel()
        completionStub.reset()

        animator.stopAnimation()

        XCTAssertEqual(completionStub.invocations.count, 0)
    }

    func testAddCompletionWhileTheAnimatorIsRunning() {
        animator.startAnimation()
        let completionStub = Stub<UIViewAnimatingPosition, Void>()

        animator.addCompletion(completionStub.call(with:))

        animator.cancel()
        XCTAssertEqual(completionStub.invocations.map(\.parameters), [.current])
    }

    func testAddCompletionAfterTheAnimatorIsCanceled() throws {
        animator.startAnimation()
        animator.cancel()

        let completionStub = Stub<UIViewAnimatingPosition, Void>()
        animator.addCompletion(completionStub.call(with:))

        XCTAssertEqual(mainQueue.asyncClosureStub.invocations.count, 1)
        let closure = try XCTUnwrap(mainQueue.asyncClosureStub.invocations.first?.parameters.work)

        closure()

        XCTAssertEqual(completionStub.invocations.map(\.parameters), [.current])
    }

    func testAddCompletionAfterTheAnimatorIsStopped() throws {
        animator.startAnimation()
        dateProvider.nowStub.defaultReturnValue = dateProvider.now + duration
        animator.update()

        let completionStub = Stub<UIViewAnimatingPosition, Void>()
        animator.addCompletion(completionStub.call(with:))

        XCTAssertEqual(mainQueue.asyncClosureStub.invocations.count, 1)
        let closure = try XCTUnwrap(mainQueue.asyncClosureStub.invocations.first?.parameters.work)

        closure()

        XCTAssertEqual(completionStub.invocations.map(\.parameters), [.end])
    }

    func testCompletionHandlerAddedInsideOtherCompletionHandlerIsInvokedAsynchronously() throws {
        let completionStub1 = Stub<UIViewAnimatingPosition, Void>()
        let completionStub2 = Stub<UIViewAnimatingPosition, Void>()
        completionStub1.defaultSideEffect = { _ in
            self.animator.addCompletion(completionStub2.call(with:))
        }
        animator.addCompletion(completionStub1.call(with:))

        animator.cancel()

        XCTAssertEqual(completionStub1.invocations.count, 1)
        XCTAssertEqual(completionStub2.invocations.count, 0)
        XCTAssertEqual(mainQueue.asyncClosureStub.invocations.count, 1)
        let closure = try XCTUnwrap(mainQueue.asyncClosureStub.invocations.first?.parameters.work)
        closure()
        XCTAssertEqual(completionStub2.invocations.count, 1)
    }
}
