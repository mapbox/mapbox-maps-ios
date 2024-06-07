import XCTest
import UIKit
@testable import MapboxMaps

final class CameraAnimationsManagerTests: XCTestCase {

    var impl: MockCameraAnimationsManager!
    var cameraAnimationsManager: CameraAnimationsManager!
    var cancelables: Set<AnyCancelable> = []

    override func setUp() {
        super.setUp()
        impl = MockCameraAnimationsManager()
        cameraAnimationsManager = CameraAnimationsManager(impl: impl)
    }

    override func tearDown() {
        cameraAnimationsManager = nil
        impl = nil
        cancelables = []
        super.tearDown()
    }

    func testCameraAnimators() {
        impl.cameraAnimators = [
            MockCameraAnimator(), MockCameraAnimator(), MockCameraAnimator()
        ]

        XCTAssertEqual(cameraAnimationsManager.cameraAnimators.count, impl.cameraAnimators.count)
        XCTAssertTrue(zip(cameraAnimationsManager.cameraAnimators, impl.cameraAnimators).allSatisfy(===))
    }

    func testCancelAnimations() {
        cameraAnimationsManager.cancelAnimations()

        XCTAssertEqual(impl.cancelAnimationsStub.invocations.count, 1)
    }

    func testFlyTo() throws {
        let cameraOptions = CameraOptions.testConstantValue()
        let duration = 5.9
        let completion = Stub<UIViewAnimatingPosition, Void>()

        let cancelable = cameraAnimationsManager.fly(
            to: cameraOptions,
            duration: duration,
            completion: completion.call(with:))

        XCTAssertEqual(impl.flyToStub.invocations.count, 1)
        let invocation = try XCTUnwrap(impl.flyToStub.invocations.first)
        XCTAssertEqual(invocation.parameters.to, cameraOptions)
        XCTAssertEqual(invocation.parameters.duration, duration)
        XCTAssertIdentical(cancelable, invocation.returnValue)

        let position = UIViewAnimatingPosition.start
        invocation.parameters.completion?(position)
        XCTAssertEqual(completion.invocations.map(\.parameters), [position])
    }

    func testFlyToWithDefaultArguments() {
        cameraAnimationsManager.fly(
            to: .testConstantValue())

        XCTAssertEqual(impl.flyToStub.invocations.count, 1)
        XCTAssertNil(impl.flyToStub.invocations.first?.parameters.duration)
        XCTAssertNil(impl.flyToStub.invocations.first?.parameters.completion)
    }

    func testEaseTo() throws {
        let cameraOptions = CameraOptions.testConstantValue()
        let duration = 1.9
        let curve = UIView.AnimationCurve.easeIn
        let completion = Stub<UIViewAnimatingPosition, Void>()

        let cancelable = cameraAnimationsManager.ease(
            to: cameraOptions,
            duration: duration,
            curve: curve,
            completion: completion.call(with:))

        XCTAssertEqual(impl.easeToStub.invocations.count, 1)
        let invocation = try XCTUnwrap(impl.easeToStub.invocations.first)
        XCTAssertEqual(invocation.parameters.to, cameraOptions)
        XCTAssertEqual(invocation.parameters.duration, duration)
        XCTAssertEqual(invocation.parameters.curve, curve)
        XCTAssertIdentical(cancelable, invocation.returnValue)

        let position = UIViewAnimatingPosition.end
        invocation.parameters.completion?(position)
        XCTAssertEqual(completion.invocations.map(\.parameters), [position])
    }

    func testEaseToWithDefaultArguments() {
        cameraAnimationsManager.ease(
            to: .testConstantValue(),
            duration: 8.3)

        XCTAssertEqual(impl.easeToStub.invocations.count, 1)
        XCTAssertEqual(impl.easeToStub.invocations.first?.parameters.curve, .easeOut)
        XCTAssertNil(impl.easeToStub.invocations.first?.parameters.completion)
    }

    func testMakeAnimatorWithTimingParameters() throws {
        let duration = 9.3
        let timingParameters = MockTimingCurveProvider()
        let animationOwner = AnimationOwner.init(rawValue: UUID().uuidString)
        let animations = Stub<CameraTransition, Void>()

        let animator = cameraAnimationsManager.makeAnimator(
            duration: duration,
            timingParameters: timingParameters,
            animationOwner: animationOwner,
            animations: { animations.call(with: $0) })

        XCTAssertEqual(impl.makeAnimatorWithTimingParametersStub.invocations.count, 1)
        let invocation = try XCTUnwrap(impl.makeAnimatorWithTimingParametersStub.invocations.first)
        XCTAssertEqual(invocation.parameters.duration, duration)
        XCTAssertIdentical(invocation.parameters.timingParameters, timingParameters)
        XCTAssertEqual(invocation.parameters.animationOwner, animationOwner)
        XCTAssertIdentical(animator, invocation.returnValue)

        var cameraTransition = CameraTransition(cameraState: .testConstantValue(), initialAnchor: .init(x: 83, y: 74))
        invocation.parameters.animations(&cameraTransition)
        XCTAssertEqual(animations.invocations.map(\.parameters), [cameraTransition])
    }

    func testMakeAnimatorWithTimingParametersWithDefaultArguments() {
        _ = cameraAnimationsManager.makeAnimator(
            duration: 2.9,
            timingParameters: MockTimingCurveProvider(),
            animations: { _ in })

        XCTAssertEqual(impl.makeAnimatorWithTimingParametersStub.invocations.count, 1)
        XCTAssertEqual(impl.makeAnimatorWithTimingParametersStub.invocations.first?.parameters.animationOwner, .unspecified)
    }

    func testMakeAnimatorWithCurve() throws {
        let duration = 8.2
        let curve = UIView.AnimationCurve.easeInOut
        let animationOwner = AnimationOwner.init(rawValue: UUID().uuidString)
        let animations = Stub<CameraTransition, Void>()

        let animator = cameraAnimationsManager.makeAnimator(
            duration: duration,
            curve: curve,
            animationOwner: animationOwner,
            animations: { animations.call(with: $0) })

        XCTAssertEqual(impl.makeAnimatorWithCurveStub.invocations.count, 1)
        let invocation = try XCTUnwrap(impl.makeAnimatorWithCurveStub.invocations.first)
        XCTAssertEqual(invocation.parameters.duration, duration)
        XCTAssertEqual(invocation.parameters.curve, curve)
        XCTAssertEqual(invocation.parameters.animationOwner, animationOwner)
        XCTAssertIdentical(animator, invocation.returnValue)

        var cameraTransition = CameraTransition(cameraState: .testConstantValue(), initialAnchor: .init(x: -38, y: 74))
        invocation.parameters.animations(&cameraTransition)
        XCTAssertEqual(animations.invocations.map(\.parameters), [cameraTransition])
    }

    func testMakeAnimatorWithCurveWithDefaultArguments() {
        _ = cameraAnimationsManager.makeAnimator(
            duration: 3.1,
            curve: .easeOut,
            animations: { _ in })

        XCTAssertEqual(impl.makeAnimatorWithCurveStub.invocations.count, 1)
        XCTAssertEqual(impl.makeAnimatorWithCurveStub.invocations.first?.parameters.animationOwner, .unspecified)
    }

    func testMakeAnimatorWithControlPoints() throws {
        let duration = 8.2
        let controlPoint1 = CGPoint.init(x: 0, y: 1)
        let controlPoint2 = CGPoint.init(x: 1, y: 0.75)
        let animationOwner = AnimationOwner.init(rawValue: UUID().uuidString)
        let animations = Stub<CameraTransition, Void>()

        let animator = cameraAnimationsManager.makeAnimator(
            duration: duration,
            controlPoint1: controlPoint1,
            controlPoint2: controlPoint2,
            animationOwner: animationOwner,
            animations: { animations.call(with: $0) })

        XCTAssertEqual(impl.makeAnimatorWithControlPointsStub.invocations.count, 1)
        let invocation = try XCTUnwrap(impl.makeAnimatorWithControlPointsStub.invocations.first)
        XCTAssertEqual(invocation.parameters.duration, duration)
        XCTAssertEqual(invocation.parameters.controlPoint1, controlPoint1)
        XCTAssertEqual(invocation.parameters.controlPoint2, controlPoint2)
        XCTAssertEqual(invocation.parameters.animationOwner, animationOwner)
        XCTAssertIdentical(animator, invocation.returnValue)

        var cameraTransition = CameraTransition(cameraState: .testConstantValue(), initialAnchor: .init(x: 33, y: -38))
        invocation.parameters.animations(&cameraTransition)
        XCTAssertEqual(animations.invocations.map(\.parameters), [cameraTransition])
    }

    func testMakeAnimatorWithControlPointsWithDefaultArguments() {
        _ = cameraAnimationsManager.makeAnimator(
            duration: 2.7,
            controlPoint1: .init(x: 0.1, y: 0.1),
            controlPoint2: .init(x: 0.9, y: 0.8),
            animations: { _ in })

        XCTAssertEqual(impl.makeAnimatorWithControlPointsStub.invocations.count, 1)
        XCTAssertEqual(impl.makeAnimatorWithControlPointsStub.invocations.first?.parameters.animationOwner, .unspecified)
    }

    func testMakeAnimatorWithDampingRatio() throws {
        let duration = 8.32
        let dampingRatio = 9.3
        let animationOwner = AnimationOwner.init(rawValue: UUID().uuidString)
        let animations = Stub<CameraTransition, Void>()

        let animator = cameraAnimationsManager.makeAnimator(
            duration: duration,
            dampingRatio: dampingRatio,
            animationOwner: animationOwner,
            animations: { animations.call(with: $0) })

        XCTAssertEqual(impl.makeAnimatorWithDampingRatioStub.invocations.count, 1)
        let invocation = try XCTUnwrap(impl.makeAnimatorWithDampingRatioStub.invocations.first)
        XCTAssertEqual(invocation.parameters.duration, duration)
        XCTAssertEqual(invocation.parameters.dampingRatio, dampingRatio)
        XCTAssertEqual(invocation.parameters.animationOwner, animationOwner)
        XCTAssertIdentical(animator, invocation.returnValue)

        var cameraTransition = CameraTransition(cameraState: .testConstantValue(), initialAnchor: .init(x: 0, y: 84))
        invocation.parameters.animations(&cameraTransition)
        XCTAssertEqual(animations.invocations.map(\.parameters), [cameraTransition])
    }

    func testMakeAnimatorWithDampingRatioWithDefaultArguments() {
        _ = cameraAnimationsManager.makeAnimator(
            duration: 1.9,
            dampingRatio: 0.2,
            animations: { _ in })

        XCTAssertEqual(impl.makeAnimatorWithDampingRatioStub.invocations.count, 1)
        XCTAssertEqual(impl.makeAnimatorWithDampingRatioStub.invocations.first?.parameters.animationOwner, .unspecified)
    }

    func testObservingCameraAnimatorStarted() {
        let mockAnimator = MockCameraAnimator()
        var isStarted = false
        cameraAnimationsManager.onCameraAnimatorStarted.observe { animator in
            XCTAssertIdentical(animator, mockAnimator)
            isStarted = true
        }.store(in: &cancelables)

        impl.$onCameraAnimatorStatusChanged.send((mockAnimator, .started))

        XCTAssertTrue(isStarted)
    }

    func testObservingCameraAnimatorFinished() {
        let mockAnimator = MockCameraAnimator()

        var isFinished = false
        cameraAnimationsManager.onCameraAnimatorFinished.observe { animator in
            XCTAssertIdentical(animator, mockAnimator)
            isFinished = true
        }.store(in: &cancelables)
        cameraAnimationsManager.onCameraAnimatorCancelled.observe { _ in
            XCTFail("Animator is not cancelled")
        }.store(in: &cancelables)

        impl.$onCameraAnimatorStatusChanged.send((mockAnimator, .stopped(reason: .finished)))

        XCTAssertTrue(isFinished)
    }

    func testObservingCameraAnimatorCancelled() {
        let mockAnimator = MockCameraAnimator()

        var isCancelled = false
        cameraAnimationsManager.onCameraAnimatorCancelled.observe { animator in
            XCTAssertIdentical(animator, mockAnimator)
            isCancelled = true
        }.store(in: &cancelables)
        cameraAnimationsManager.onCameraAnimatorFinished.observe { _ in
            XCTFail("Animator is not finished")
        }.store(in: &cancelables)

        impl.$onCameraAnimatorStatusChanged.send((mockAnimator, .stopped(reason: .cancelled)))

        XCTAssertTrue(isCancelled)
    }
}
