import XCTest
import UIKit
@testable import MapboxMaps

final class BasicCameraAnimatorTests: XCTestCase {

    var impl: MockBasicCameraAnimator!
    var animator: BasicCameraAnimator!

    override func setUp() {
        super.setUp()
        impl = MockBasicCameraAnimator()
        animator = BasicCameraAnimator(impl: impl)
    }

    override func tearDown() {
        animator = nil
        impl = nil
        super.tearDown()
    }

    func testOwner() {
        impl.owner = .init(rawValue: UUID().uuidString)

        XCTAssertEqual(animator.owner, impl.owner)
    }

    func testAnimationType() {
        impl.animationType = .unspecified

        XCTAssertEqual(animator.animationType, impl.animationType)
    }

    func testTransition() {
        impl.transition = CameraTransition(
            cameraState: CameraState(
                center: .init(latitude: 34, longitude: 82),
                padding: .init(top: 38, left: 28, bottom: 64, right: 29),
                zoom: 17,
                bearing: 348,
                pitch: 50
            ),
            initialAnchor: .init(x: -27, y: -83)
        )

        XCTAssertEqual(animator.transition, impl.transition)
    }

    func testState() {
        let states: [UIViewAnimatingState] = [.active, .inactive, .stopped]
        for state in states {
            impl.state = state
            XCTAssertEqual(impl.state, state)
            XCTAssertEqual(animator.state, impl.state)
        }
    }

    func testIsRunning() {
        impl.isRunning = true
        XCTAssertEqual(true, impl.isRunning)
        XCTAssertEqual(animator.isRunning, impl.isRunning)

        impl.isRunning = false
        XCTAssertEqual(false, impl.isRunning)
        XCTAssertEqual(animator.isRunning, impl.isRunning)
    }

    func testIsReversed() {
        animator.isReversed = true

        XCTAssertEqual(impl.$isReversed.setStub.invocations.map(\.parameters), [true])

        impl.isReversed = false

        XCTAssertEqual(animator.isReversed, impl.isReversed)
    }

    func testOnCameraAnimatorStatusChanged() {
        var expectedStatus: CameraAnimatorStatus?
        let cancelable = animator.onCameraAnimatorStatusChanged.observe { status in
            expectedStatus = status
        }

        impl.$onCameraAnimatorStatusChanged.send(.started)
        XCTAssertEqual(expectedStatus, .started)

        impl.$onCameraAnimatorStatusChanged.send(.stopped(reason: .finished))
        XCTAssertEqual(expectedStatus, .stopped(reason: .finished))

        expectedStatus = nil
        cancelable.cancel()
        impl.$onCameraAnimatorStatusChanged.send(.stopped(reason: .finished))
        XCTAssertNil(expectedStatus)
    }

    func testPausesOnCompletion() {
        animator.pausesOnCompletion = true

        XCTAssertEqual(impl.$pausesOnCompletion.setStub.invocations.map(\.parameters), [true])

        impl.pausesOnCompletion = false

        XCTAssertEqual(animator.pausesOnCompletion, impl.pausesOnCompletion)
    }

    func testFractionComplete() {
        animator.fractionComplete = 0.75

        XCTAssertEqual(impl.$fractionComplete.setStub.invocations.map(\.parameters), [0.75])

        impl.fractionComplete = 0.33

        XCTAssertEqual(animator.fractionComplete, impl.fractionComplete)
    }

    func testStartAnimation() {
        animator.startAnimation()

        XCTAssertEqual(impl.startAnimationStub.invocations.count, 1)
    }

    func testStartAnimationAfterDelay() {
        animator.startAnimation(afterDelay: 3)

        XCTAssertEqual(impl.startAnimationAfterDelayStub.invocations.map(\.parameters), [3])
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

        let position = UIViewAnimatingPosition.end

        impl.addCompletionStub.invocations[0].parameters(position)

        XCTAssertEqual(completion.invocations.map(\.parameters), [position])
    }

    func testContinueAnimation() {
        let timingParameters: UITimingCurveProvider? = MockTimingCurveProvider()
        let durationFactor = 2.0

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

    func testOnStarted() {
        var isStarted = false
        var cancelables = Set<AnyCancelable>()
        animator.onStarted.observe {
            isStarted = true
        }.store(in: &cancelables)

        impl.$onCameraAnimatorStatusChanged.send(.started)
        XCTAssertTrue(isStarted)
    }

    func testOnFinished() {
        var isFinished = false
        var cancelables = Set<AnyCancelable>()
        animator.onFinished.observe {
            isFinished = true
        }.store(in: &cancelables)
        animator.onCancelled.observe {
            XCTFail("animator is not cancelled")
        }.store(in: &cancelables)

        impl.$onCameraAnimatorStatusChanged.send(.stopped(reason: .finished))
        XCTAssertTrue(isFinished)
    }

    func testOnCancelled() {
        var isCancelled = false
        var cancelables = Set<AnyCancelable>()
        animator.onFinished.observe {
            XCTFail("animator is not finished")
        }.store(in: &cancelables)
        animator.onCancelled.observe {
            isCancelled = true
        }.store(in: &cancelables)

        impl.$onCameraAnimatorStatusChanged.send(.stopped(reason: .cancelled))
        XCTAssertTrue(isCancelled)
    }
}
