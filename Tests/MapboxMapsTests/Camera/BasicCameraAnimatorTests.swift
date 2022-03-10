import XCTest
@testable import MapboxMaps

final class BasicCameraAnimatorTests: XCTestCase {

    var impl: MockBasicCameraAnimator!
    var animator: BasicCameraAnimator!
    var delegate: MockCameraAnimatorDelegate!

    override func setUp() {
        super.setUp()
        impl = MockBasicCameraAnimator()
        animator = BasicCameraAnimator(impl: impl)
        delegate = MockCameraAnimatorDelegate()
        animator.delegate = delegate
    }

    override func tearDown() {
        delegate = nil
        animator = nil
        impl = nil
        super.tearDown()
    }

    func testOwner() {
        impl.owner = .random()

        XCTAssertEqual(animator.owner, impl.owner)
    }

    func testTransition() {
        impl.transition = .random(CameraTransition(cameraState: .random(), initialAnchor: .random()))

        XCTAssertEqual(animator.transition, impl.transition)
    }

    func testState() {
        impl.state = .random()

        XCTAssertEqual(animator.state, impl.state)
    }

    func testIsRunning() {
        impl.isRunning = .random()

        XCTAssertEqual(animator.isRunning, impl.isRunning)
    }

    func testIsReversed() {
        let value = Bool.random()

        animator.isReversed = value

        XCTAssertEqual(impl.$isReversed.setStub.invocations.map(\.parameters), [value])

        impl.isReversed = .random()

        XCTAssertEqual(animator.isReversed, impl.isReversed)
    }

    func testPausesOnCompletion() {
        let value = Bool.random()

        animator.pausesOnCompletion = value

        XCTAssertEqual(impl.$pausesOnCompletion.setStub.invocations.map(\.parameters), [value])

        impl.pausesOnCompletion = .random()

        XCTAssertEqual(animator.pausesOnCompletion, impl.pausesOnCompletion)
    }

    func testFractionComplete() {
        let value = Double.random(in: 0...1)

        animator.fractionComplete = value

        XCTAssertEqual(impl.$fractionComplete.setStub.invocations.map(\.parameters), [value])

        impl.fractionComplete = .random(in: 0...1)

        XCTAssertEqual(animator.fractionComplete, impl.fractionComplete)
    }

    func testStartAnimation() {
        animator.startAnimation()

        XCTAssertEqual(impl.startAnimationStub.invocations.count, 1)
    }

    func testStartAnimationAfterDelay() {
        let delay = TimeInterval.random(in: 0...10)

        animator.startAnimation(afterDelay: delay)

        XCTAssertEqual(impl.startAnimationAfterDelayStub.invocations.map(\.parameters), [delay])
    }

    func testPauseAnimation() {
        animator.pauseAnimation()

        XCTAssertEqual(impl.pauseAnimationStub.invocations.count, 1)
    }

    func testStopAnimation() {
        animator.stopAnimation()

        XCTAssertEqual(impl.stopAnimationStub.invocations.count, 1)
    }

    func testAddCompletion() {
        let completion = Stub<UIViewAnimatingPosition, Void>()

        animator.addCompletion(completion.call(with:))

        guard impl.addCompletionStub.invocations.count == 1 else {
            XCTFail("impl not invoked")
            return
        }

        let position = UIViewAnimatingPosition.random()

        impl.addCompletionStub.invocations[0].parameters(position)

        XCTAssertEqual(completion.invocations.map(\.parameters), [position])
    }

    func testContinueAnimation() {
        let timingParameters: UITimingCurveProvider? = .random(MockTimingCurveProvider())
        let durationFactor = Double.random(in: 0...10)

        animator.continueAnimation(
            withTimingParameters: timingParameters,
            durationFactor: durationFactor)

        XCTAssertEqual(impl.continueAnimationStub.invocations.count, 1)
        XCTAssertIdentical(impl.continueAnimationStub.invocations.first?.parameters.timingParameters, timingParameters)
        XCTAssertEqual(impl.continueAnimationStub.invocations.first?.parameters.durationFactor, durationFactor)
    }

    func testCancel() {
        animator.cancel()

        XCTAssertEqual(impl.stopAnimationStub.invocations.count, 1)
    }

    func testUpdate() {
        animator.update()

        XCTAssertEqual(impl.updateStub.invocations.count, 1)
    }

    func testBasicCameraAnimatorDidStartRunning() {
        animator.basicCameraAnimatorDidStartRunning(impl)

        XCTAssertEqual(delegate.cameraAnimatorDidStartRunningStub.invocations.count, 1)
        XCTAssertIdentical(delegate.cameraAnimatorDidStartRunningStub.invocations.first?.parameters, animator)
    }

    func testBasicCameraAnimatorDidStopRunning() {
        animator.basicCameraAnimatorDidStopRunning(impl)

        XCTAssertEqual(delegate.cameraAnimatorDidStopRunningStub.invocations.count, 1)
        XCTAssertIdentical(delegate.cameraAnimatorDidStopRunningStub.invocations.first?.parameters, animator)
    }
}
