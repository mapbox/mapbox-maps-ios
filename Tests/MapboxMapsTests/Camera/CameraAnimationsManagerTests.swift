import XCTest
@testable import MapboxMaps

final class CameraAnimationsManagerTests: XCTestCase {

    var impl: MockCameraAnimationsManager!
    var cameraAnimationsManager: CameraAnimationsManager!

    override func setUp() {
        super.setUp()
        impl = MockCameraAnimationsManager()
        cameraAnimationsManager = CameraAnimationsManager(impl: impl)
    }

    override func tearDown() {
        cameraAnimationsManager = nil
        impl = nil
        super.tearDown()
    }

    func testCameraAnimators() {
        impl.cameraAnimators = .random(withLength: .random(in: 0...10), generator: MockCameraAnimator.init)

        XCTAssertEqual(cameraAnimationsManager.cameraAnimators.count, impl.cameraAnimators.count)
        XCTAssertTrue(zip(cameraAnimationsManager.cameraAnimators, impl.cameraAnimators).allSatisfy(===))
    }

    func testFlyTo() throws {
        let cameraOptions = CameraOptions.random()
        let duration = TimeInterval?.random(.random(in: 0...10))
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

        let position = UIViewAnimatingPosition.random()
        invocation.parameters.completion?(position)
        XCTAssertEqual(completion.invocations.map(\.parameters), [position])
    }

    func testFlyToWithDefaultArguments() {
        cameraAnimationsManager.fly(
            to: .random())

        XCTAssertEqual(impl.flyToStub.invocations.count, 1)
        XCTAssertNil(impl.flyToStub.invocations.first?.parameters.duration)
        XCTAssertNil(impl.flyToStub.invocations.first?.parameters.completion)
    }

    func testEaseTo() throws {
        let cameraOptions = CameraOptions.random()
        let duration = TimeInterval.random(in: 0...10)
        let curve = UIView.AnimationCurve.random()
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

        let position = UIViewAnimatingPosition.random()
        invocation.parameters.completion?(position)
        XCTAssertEqual(completion.invocations.map(\.parameters), [position])
    }

    func testEaseToWithDefaultArguments() {
        cameraAnimationsManager.ease(
            to: .random(),
            duration: .random(in: 0...10))

        XCTAssertEqual(impl.easeToStub.invocations.count, 1)
        XCTAssertEqual(impl.easeToStub.invocations.first?.parameters.curve, .easeOut)
        XCTAssertNil(impl.easeToStub.invocations.first?.parameters.completion)
    }

    func testMakeAnimatorWithTimingParameters() throws {
        let duration = TimeInterval.random(in: 0...10)
        let timingParameters = MockTimingCurveProvider()
        let animationOwner = AnimationOwner.random()
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

        var cameraTransition = CameraTransition(cameraState: .random(), initialAnchor: .random())
        invocation.parameters.animations(&cameraTransition)
        XCTAssertEqual(animations.invocations.map(\.parameters), [cameraTransition])
    }

    func testMakeAnimatorWithTimingParametersWithDefaultArguments() {
        _ = cameraAnimationsManager.makeAnimator(
            duration: .random(in: 0...10),
            timingParameters: MockTimingCurveProvider(),
            animations: { _ in })

        XCTAssertEqual(impl.makeAnimatorWithTimingParametersStub.invocations.count, 1)
        XCTAssertEqual(impl.makeAnimatorWithTimingParametersStub.invocations.first?.parameters.animationOwner, .unspecified)
    }

    func testMakeAnimatorWithCurve() throws {
        let duration = TimeInterval.random(in: 0...10)
        let curve = UIView.AnimationCurve.random()
        let animationOwner = AnimationOwner.random()
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

        var cameraTransition = CameraTransition(cameraState: .random(), initialAnchor: .random())
        invocation.parameters.animations(&cameraTransition)
        XCTAssertEqual(animations.invocations.map(\.parameters), [cameraTransition])
    }

    func testMakeAnimatorWithCurveWithDefaultArguments() {
        _ = cameraAnimationsManager.makeAnimator(
            duration: .random(in: 0...10),
            curve: .random(),
            animations: { _ in })

        XCTAssertEqual(impl.makeAnimatorWithCurveStub.invocations.count, 1)
        XCTAssertEqual(impl.makeAnimatorWithCurveStub.invocations.first?.parameters.animationOwner, .unspecified)
    }

    func testMakeAnimatorWithControlPoints() throws {
        let duration = TimeInterval.random(in: 0...10)
        let controlPoint1 = CGPoint.random()
        let controlPoint2 = CGPoint.random()
        let animationOwner = AnimationOwner.random()
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

        var cameraTransition = CameraTransition(cameraState: .random(), initialAnchor: .random())
        invocation.parameters.animations(&cameraTransition)
        XCTAssertEqual(animations.invocations.map(\.parameters), [cameraTransition])
    }

    func testMakeAnimatorWithControlPointsWithDefaultArguments() {
        _ = cameraAnimationsManager.makeAnimator(
            duration: .random(in: 0...10),
            controlPoint1: .random(),
            controlPoint2: .random(),
            animations: { _ in })

        XCTAssertEqual(impl.makeAnimatorWithControlPointsStub.invocations.count, 1)
        XCTAssertEqual(impl.makeAnimatorWithControlPointsStub.invocations.first?.parameters.animationOwner, .unspecified)
    }

    func testMakeAnimatorWithDampingRatio() throws {
        let duration = TimeInterval.random(in: 0...10)
        let dampingRatio = CGFloat.random(in: 0...10)
        let animationOwner = AnimationOwner.random()
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

        var cameraTransition = CameraTransition(cameraState: .random(), initialAnchor: .random())
        invocation.parameters.animations(&cameraTransition)
        XCTAssertEqual(animations.invocations.map(\.parameters), [cameraTransition])
    }

    func testMakeAnimatorWithDampingRatioWithDefaultArguments() {
        _ = cameraAnimationsManager.makeAnimator(
            duration: .random(in: 0...10),
            dampingRatio: .random(in: 0...10),
            animations: { _ in })

        XCTAssertEqual(impl.makeAnimatorWithDampingRatioStub.invocations.count, 1)
        XCTAssertEqual(impl.makeAnimatorWithDampingRatioStub.invocations.first?.parameters.animationOwner, .unspecified)
    }
}
