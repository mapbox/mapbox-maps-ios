import XCTest
@testable import MapboxMaps

final class MapAnimatorImplTests: XCTestCase {
    var mainQueue: MockMainQueue!
    var coordinator: MockDisplayLinkCoordinator!
    var timeProvider: MockTimeProvider!
    var animation: Stub<Double, Void>!
    var completion: Stub<UIViewAnimatingPosition, Void>!
    var animator: MapAnimatorImpl!

    override func setUp() {
        super.setUp()

        mainQueue = MockMainQueue()
        timeProvider = MockTimeProvider()
        coordinator = MockDisplayLinkCoordinator()
        animation = Stub()
        completion = Stub()
        animator = MapAnimatorImpl(
            duration: .random(in: 0.3...3),
            curve: .random(),
            owner: .random(),
            mainQueue: mainQueue,
            timeProvider: timeProvider,
            displayLinkCoordinator: coordinator
        )
    }

    override func tearDown() {
        super.tearDown()

        mainQueue = nil
        timeProvider = nil
        coordinator = nil
        animation = nil
        completion = nil
        animator = nil
    }

    func testInitialState() {
        // given
        let duration: TimeInterval = 3
        let curve = TimingCurve.random()
        let owner = AnimationOwner.random()

        // when
        animator = MapAnimatorImpl(
            duration: duration,
            curve: curve,
            owner: owner,
            mainQueue: mainQueue,
            displayLinkCoordinator: coordinator
        )

        // then
        XCTAssertEqual(animator.duration, duration)
        XCTAssertEqual(animator.timingCurve, curve)
        XCTAssertEqual(animator.owner, owner)
        XCTAssertEqual(animator.internalState, .initial)
        XCTAssertFalse(animator.isRunning)
        XCTAssertTrue(animator.scrubsLinearly)
        XCTAssertEqual(animator.fractionComplete, 0)
        XCTAssertEqual(animator.repeatCount, 0)
        XCTAssertFalse(animator.autoreverses)
    }

    func testStartAnimationFromInitial() {
        // when
        animator.startAnimation()

        // then
        XCTAssertEqual(animator.internalState, .running(timeProvider.current))
        XCTAssertEqual(coordinator.addStub.invocations.count, 1)
    }

    func testStartAnimationFromRunning() {
        // given
        let originalTime: TimeInterval = 10
        timeProvider.currentStub.defaultReturnValue = originalTime
        animator.startAnimation() // sets the state to `running`
        coordinator.addStub.reset()

        // when
        timeProvider.currentStub.defaultReturnValue = 11
        animator.startAnimation()

        // then
        XCTAssertEqual(animator.internalState, .running(originalTime), "the second call should be ignored")
        XCTAssertEqual(coordinator.addStub.invocations.count, 0)
    }

    func testStartAnimationFromPaused() {
        // given
        let time: TimeInterval = 10
        timeProvider.currentStub.defaultReturnValue = time
        animator.pauseAnimation()
        coordinator.addStub.reset()

        // when
        animator.startAnimation()

        // then
        XCTAssertEqual(animator.internalState, .running(time))
        XCTAssertEqual(coordinator.addStub.invocations.count, 1)
    }

    func testStartAnimationFromFinal() {
        // given
        animator.stopAnimation()

        // when
        animator.startAnimation()

        // then
        XCTAssertEqual(animator.internalState, .final(.current))
    }

    func testStartAfterDelayFromInitial() {
        // given
        let time: TimeInterval = .random(in: 0...100)
        let delay: TimeInterval = .random(in: 1...10)
        timeProvider.currentStub.defaultReturnValue = time

        // when
        animator.startAnimation(afterDelay: delay)

        XCTAssertEqual(animator.internalState, .running(time + delay))
        XCTAssertEqual(coordinator.addStub.invocations.count, 1)
    }

    func testStartAfterDelayFromRunning() {
        // given
        let originalTime: TimeInterval = 10
        timeProvider.currentStub.defaultReturnValue = originalTime
        animator.startAnimation() // sets the state to `running`
        coordinator.addStub.reset()

        // when
        timeProvider.currentStub.defaultReturnValue = 11
        animator.startAnimation(afterDelay: .random(in: 1...10))

        // then
        XCTAssertEqual(animator.internalState, .running(originalTime), "the second call should be ignored")
        XCTAssertEqual(coordinator.addStub.invocations.count, 0)
    }

    func testStartAfterDelayFromPaused() {
        // given
        let time: TimeInterval = .random(in: 0...100)
        timeProvider.currentStub.defaultReturnValue = time
        animator.pauseAnimation()

        // when
        animator.startAnimation(afterDelay: .random(in: 1...10))

        XCTAssertEqual(animator.internalState, .running(time))
        XCTAssertEqual(coordinator.addStub.invocations.count, 1)
    }

    func testStartAfterDelayFromFinal() {
        // given
        animator.stopAnimation()

        // when
        animator.startAnimation(afterDelay: .random(in: 1...10))

        // then
        XCTAssertEqual(animator.internalState, .final(.current))
    }

    func testPauseFromInitial() {
        // given
        timeProvider.currentStub.defaultReturnValue = .random(in: 0...100)

        // when
        animator.pauseAnimation()

        // then
        XCTAssertEqual(animator.internalState, .paused(0))
    }

    func testPauseFromRunning() {
        // given
        timeProvider.currentStub.defaultReturnValue = .random(in: 0...100)
        animator.startAnimation()

        // when
        timeProvider.currentStub.defaultReturnValue = .random(in: 100...1000)
        animator.pauseAnimation()

        // then
        XCTAssertEqual(animator.internalState, .paused(0))
        XCTAssertEqual(coordinator.removeStub.invocations.count, 1)
    }

    func testPauseFromPaused() {
        // given
        timeProvider.currentStub.defaultReturnValue = .random(in: 0...100)
        animator.startAnimation()
        animator.pauseAnimation()

        // when
        timeProvider.currentStub.defaultReturnValue = .random(in: 100...1000)
        animator.pauseAnimation()

        // then
        XCTAssertEqual(animator.internalState, .paused(0))
    }

    func testPauseFromFinal() {
        // given
        let originalTime: TimeInterval = .random(in: 0...100)
        timeProvider.currentStub.defaultReturnValue = originalTime
        animator.startAnimation()
        animator.stopAnimation()

        // when
        timeProvider.currentStub.defaultReturnValue = .random(in: 100...1000)
        animator.pauseAnimation()

        // then
        XCTAssertEqual(animator.internalState, .final(.current))
    }

    func testStopFromInitial() {
        // given
        animator.addCompletion(completion.call(with:))

        // when
        animator.stopAnimation()

        // then
        XCTAssertEqual(animator.internalState, .final(.current))
        XCTAssertEqual(completion.invocations.count, 1)
        XCTAssertEqual(completion.invocations.first?.parameters, .current)
    }

    func testStopFromRunning() {
        // given
        animator.addCompletion(completion.call(with:))
        animator.startAnimation()

        // when
        animator.stopAnimation()

        // then
        XCTAssertEqual(animator.internalState, .final(.current))
        XCTAssertEqual(completion.invocations.count, 1)
        XCTAssertEqual(completion.invocations.first?.parameters, .current)
        XCTAssertEqual(coordinator.removeStub.invocations.count, 1)
    }

    func testStopFromPaused() {
        // given
        animator.addCompletion(completion.call(with:))
        animator.pauseAnimation()

        // when
        animator.stopAnimation()

        // then
        XCTAssertEqual(animator.internalState, .final(.current))
        XCTAssertEqual(completion.invocations.count, 1)
        XCTAssertEqual(completion.invocations.first?.parameters, .current)
        XCTAssertEqual(coordinator.removeStub.invocations.count, 1)
    }

    func testStopFromFinal() {
        // given
        animator.addCompletion(completion.call(with:))
        animator.stopAnimation()
        completion.reset()

        // when
        animator.stopAnimation()

        // then
        XCTAssertTrue(completion.invocations.isEmpty)
        XCTAssertEqual(animator.internalState, .final(.current))
    }

    func testAddCompletionFromInitialRunningPaused() {
        // given
        let initialCompletion = Stub<UIViewAnimatingPosition, Void>()
        let runningCompletion = Stub<UIViewAnimatingPosition, Void>()
        let pausedCompletion = Stub<UIViewAnimatingPosition, Void>()

        // when
        animator.addCompletion(initialCompletion.call(with:)) // add completion to initial animator

        animator.startAnimation()
        animator.addCompletion(runningCompletion.call(with:)) // add completion to running animator

        animator.pauseAnimation()
        animator.addCompletion(pausedCompletion.call(with:)) // add completion to paused animator

        animator.stopAnimation()

        // then
        XCTAssertEqual(initialCompletion.invocations.count, 1)
        XCTAssertEqual(runningCompletion.invocations.count, 1)
        XCTAssertEqual(pausedCompletion.invocations.count, 1)
    }

    func testAddCompletionFromFinal() {
        // given
        mainQueue.asyncStub.defaultSideEffect = { $0.parameters() }
        animator.stopAnimation()

        // when
        animator.addCompletion(completion.call(with:))

        // then
        XCTAssertEqual(mainQueue.asyncStub.invocations.count, 1)
        XCTAssertEqual(completion.invocations.count, 1)
    }

    func testUpdateFromInitialPausedFinal() {
        // given
        animator.addAnimations(animation.call(with:))

        // when
        animator.updateWith(targetTime: .random(in: 0...1000)) // update from initial

        animator.pauseAnimation()
        animator.updateWith(targetTime: .random(in: 0...1000)) // update from paused

        animator.stopAnimation()
        animator.updateWith(targetTime: .random(in: 0...1000)) // update from final

        // then
        XCTAssertTrue(animation.invocations.isEmpty)
    }

    func testUpdateWithStartTimestampInFuture() {
        // given
        animator.addAnimations(animation.call(with:))
        animator.addCompletion(completion.call(with:))
        animator.startAnimation(afterDelay: .random(in: 10...100))

        // when
        animator.updateWith(targetTime: 9)

        // then
        XCTAssertTrue(animation.invocations.isEmpty)
        XCTAssertTrue(completion.invocations.isEmpty)
    }

    func test
}
