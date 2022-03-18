import XCTest
@testable import MapboxMaps

final class CameraAnimationsManagerImplTests: XCTestCase {

    var factory: MockCameraAnimatorsFactory!
    var runner: MockCameraAnimatorsRunner!
    var impl: CameraAnimationsManagerImpl!

    override func setUp() {
        super.setUp()
        factory = MockCameraAnimatorsFactory()
        runner = MockCameraAnimatorsRunner()
        impl = CameraAnimationsManagerImpl(
            factory: factory,
            runner: runner)
    }

    override func tearDown() {
        impl = nil
        runner = nil
        factory = nil
        super.tearDown()
    }

    func testCameraAnimators() {
        runner.cameraAnimators = .random(
            withLength: .random(in: 0...10),
            generator: MockCameraAnimator.init)

        XCTAssertEqual(impl.cameraAnimators.count, runner.cameraAnimators.count)
        XCTAssertTrue(
            zip(impl.cameraAnimators, runner.cameraAnimators).allSatisfy(===))
    }

    func testCancelAnimations() {
        impl.cancelAnimations()

        XCTAssertEqual(runner.cancelAnimationsStub.invocations.count, 1)
    }

    func testFlyTo() throws {
        let camera = CameraOptions.random()
        let duration = TimeInterval?.random(.random(in: 0...10))
        let completion = Stub<UIViewAnimatingPosition, Void>()

        let cancelable = impl.fly(
            to: camera,
            duration: duration,
            completion: completion.call(with:))

        // cancels any existing high-level animator (identified based on the owner)
        XCTAssertEqual(
            runner.cancelAnimationsWithOwnersStub.invocations.map(\.parameters),
            [[.cameraAnimationsManager]])

        // creates the new animator
        XCTAssertEqual(factory.makeFlyToAnimatorStub.invocations.count, 1)
        let factoryInvocation = try XCTUnwrap(factory.makeFlyToAnimatorStub.invocations.first)
        XCTAssertEqual(factoryInvocation.parameters.toCamera, camera)
        XCTAssertEqual(factoryInvocation.parameters.animationOwner, .cameraAnimationsManager)
        XCTAssertEqual(factoryInvocation.parameters.duration, duration)
        let animator = try XCTUnwrap(factoryInvocation.returnValue as? MockCameraAnimator)

        // adds the completion block to the animator (exercise it to verify)
        XCTAssertEqual(animator.addCompletionStub.invocations.count, 1)
        let addedCompletion = try XCTUnwrap(animator.addCompletionStub.invocations.first?.parameters)
        let position = UIViewAnimatingPosition.random()
        addedCompletion(position)
        XCTAssertEqual(completion.invocations.map(\.parameters), [position])

        // adds the animator to the runner and starts it
        XCTAssertEqual(runner.addStub.invocations.count, 1)
        XCTAssertIdentical(runner.addStub.invocations.first?.parameters, animator)
        XCTAssertEqual(animator.startAnimationStub.invocations.count, 1)

        // the returned cancelable is the animator
        XCTAssertIdentical(cancelable, animator)
    }

    func testFlyToWithNilCompletion() throws {
        impl.fly(to: .random(), duration: nil, completion: nil)

        // creates the new animator
        XCTAssertEqual(factory.makeFlyToAnimatorStub.invocations.count, 1)
        let animator = try XCTUnwrap(factory.makeFlyToAnimatorStub.invocations.first?.returnValue as? MockCameraAnimator)

        // no completion block to add
        XCTAssertEqual(animator.addCompletionStub.invocations.count, 0)
    }

    func testEaseToWithNonNilAnchor() throws {
        var camera = CameraOptions.random()
        camera.anchor = .random()
        let duration = TimeInterval.random(in: 0...10)
        let curve = UIView.AnimationCurve.random()
        let completion = Stub<UIViewAnimatingPosition, Void>()

        let cancelable = impl.ease(
            to: camera,
            duration: duration,
            curve: curve,
            completion: completion.call(with:))

        // cancels any existing high-level animator (identified based on the owner)
        XCTAssertEqual(
            runner.cancelAnimationsWithOwnersStub.invocations.map(\.parameters),
            [[.cameraAnimationsManager]])

        // creates the new animator
        XCTAssertEqual(factory.makeBasicCameraAnimatorWithCurveStub.invocations.count, 1)
        let factoryInvocation = try XCTUnwrap(factory.makeBasicCameraAnimatorWithCurveStub.invocations.first)
        XCTAssertEqual(factoryInvocation.parameters.duration, duration)
        XCTAssertEqual(factoryInvocation.parameters.curve, curve)
        XCTAssertEqual(factoryInvocation.parameters.animationOwner, .cameraAnimationsManager)
        let animatorImpl = try XCTUnwrap(factoryInvocation.returnValue as? MockBasicCameraAnimator)

        // configures the transition in the animations block
        let cameraState = CameraState.random()
        let initialAnchor = CGPoint.random()
        var transition = CameraTransition(cameraState: cameraState, initialAnchor: initialAnchor)
        factoryInvocation.parameters.animations(&transition)
        XCTAssertEqual(transition.center.fromValue, cameraState.center)
        XCTAssertEqual(transition.center.toValue, camera.center)
        XCTAssertEqual(transition.padding.fromValue, cameraState.padding)
        XCTAssertEqual(transition.padding.toValue, camera.padding)
        XCTAssertEqual(transition.anchor.fromValue, camera.anchor)
        XCTAssertEqual(transition.anchor.toValue, camera.anchor)
        XCTAssertEqual(transition.zoom.fromValue, cameraState.zoom)
        XCTAssertEqual(transition.zoom.toValue, camera.zoom)
        XCTAssertEqual(transition.bearing.fromValue, cameraState.bearing)
        XCTAssertEqual(transition.bearing.toValue, camera.bearing)
        XCTAssertEqual(transition.pitch.fromValue, cameraState.pitch)
        XCTAssertEqual(transition.pitch.toValue, camera.pitch)
        XCTAssertTrue(transition.shouldOptimizeBearingPath)

        // adds the completion block to the animator (exercise it to verify)
        XCTAssertEqual(animatorImpl.addCompletionStub.invocations.count, 1)
        let addedCompletion = try XCTUnwrap(animatorImpl.addCompletionStub.invocations.first?.parameters)
        let position = UIViewAnimatingPosition.random()
        addedCompletion(position)
        XCTAssertEqual(completion.invocations.map(\.parameters), [position])

        // adds the animator to the runner and starts it; since the added
        // animator is a wrapper around animatorImpl, verify indirectly
        XCTAssertEqual(runner.addStub.invocations.count, 1)
        let addedAnimator = try XCTUnwrap(runner.addStub.invocations.first?.parameters)
        animatorImpl.owner = .random()
        XCTAssertEqual(addedAnimator.owner, animatorImpl.owner)
        XCTAssertEqual(animatorImpl.startAnimationStub.invocations.count, 1)

        // the returned cancelable is the added animator
        XCTAssertIdentical(cancelable, addedAnimator)
    }

    func testEaseToWithNilAnchorAndNilCompletion() throws {
        var camera = CameraOptions.random()
        camera.anchor = nil

        impl.ease(
            to: camera,
            duration: .random(in: 0...10),
            curve: .random(),
            completion: nil)

        // creates the new animator
        XCTAssertEqual(factory.makeBasicCameraAnimatorWithCurveStub.invocations.count, 1)
        let factoryInvocation = try XCTUnwrap(factory.makeBasicCameraAnimatorWithCurveStub.invocations.first)

        // does not modify the transition's anchor to/from
        let initialAnchor = CGPoint.random()
        var transition = CameraTransition(cameraState: .random(), initialAnchor: initialAnchor)
        factoryInvocation.parameters.animations(&transition)
        XCTAssertEqual(transition.anchor.fromValue, initialAnchor)
        XCTAssertNil(transition.anchor.toValue)

        // no completion block to add
        let animatorImpl = try XCTUnwrap(factoryInvocation.returnValue as? MockBasicCameraAnimator)
        XCTAssertEqual(animatorImpl.addCompletionStub.invocations.count, 0)
    }

    func testDecelerate() throws {
        let location = CGPoint.random()
        let velocity = CGPoint.random()
        let decelerationFactor = CGFloat.random(in: 0..<1)
        let locationChangeHander = Stub<(CGPoint, CGPoint), Void>()
        let completion = Stub<UIViewAnimatingPosition, Void>()

        impl.decelerate(
            location: location,
            velocity: velocity,
            decelerationFactor: decelerationFactor,
            locationChangeHandler: { locationChangeHander.call(with: ($0, $1)) },
            completion: completion.call(with:))

        // cancels any existing high-level animator (identified based on the owner)
        XCTAssertEqual(
            runner.cancelAnimationsWithOwnersStub.invocations.map(\.parameters),
            [[.cameraAnimationsManager]])

        // creates the new animator
        XCTAssertEqual(factory.makeGestureDecelerationCameraAnimatorStub.invocations.count, 1)
        let factoryInvocation = try XCTUnwrap(factory.makeGestureDecelerationCameraAnimatorStub.invocations.first)
        XCTAssertEqual(factoryInvocation.parameters.location, location)
        XCTAssertEqual(factoryInvocation.parameters.velocity, velocity)
        XCTAssertEqual(factoryInvocation.parameters.decelerationFactor, decelerationFactor)
        XCTAssertEqual(factoryInvocation.parameters.animationOwner, .cameraAnimationsManager)

        // verify the location change handler is passed through by invoking it
        let fromLocation = CGPoint.random()
        let toLocation = CGPoint.random()
        factoryInvocation.parameters.locationChangeHandler(fromLocation, toLocation)
        XCTAssertEqual(locationChangeHander.invocations.map(\.parameters.0), [fromLocation])
        XCTAssertEqual(locationChangeHander.invocations.map(\.parameters.1), [toLocation])

        let animator = try XCTUnwrap(factoryInvocation.returnValue as? MockCameraAnimator)

        // adds the completion block to the animator (exercise it to verify)
        XCTAssertEqual(animator.addCompletionStub.invocations.count, 1)
        let addedCompletion = try XCTUnwrap(animator.addCompletionStub.invocations.first?.parameters)
        let position = UIViewAnimatingPosition.random()
        addedCompletion(position)
        XCTAssertEqual(completion.invocations.map(\.parameters), [position])

        // adds the animator to the runner and starts it
        XCTAssertEqual(runner.addStub.invocations.count, 1)
        XCTAssertIdentical(runner.addStub.invocations.first?.parameters, animator)
        XCTAssertEqual(animator.startAnimationStub.invocations.count, 1)
    }

    func testDecelerateWithNilCompletion() throws {
        impl.decelerate(
            location: .random(),
            velocity: .random(),
            decelerationFactor: .random(in: 0..<1),
            locationChangeHandler: { _, _ in },
            completion: nil)

        // creates the new animator
        XCTAssertEqual(factory.makeGestureDecelerationCameraAnimatorStub.invocations.count, 1)
        let animator = try XCTUnwrap(factory.makeGestureDecelerationCameraAnimatorStub.invocations.first?.returnValue as? MockCameraAnimator)

        // no completion block to add
        XCTAssertEqual(animator.addCompletionStub.invocations.count, 0)
    }

    func verifyMakeAnimator(animationsClosure: (inout CameraTransition) -> Void,
                            animationsStub: Stub<CameraTransition, Void>,
                            animatorImpl: MockBasicCameraAnimator,
                            returnedAnimator: BasicCameraAnimator) throws {
        // invoke the animations block to verify that it was passed through
        var cameraTransition = CameraTransition(cameraState: .random(), initialAnchor: .random())
        animationsClosure(&cameraTransition)
        XCTAssertEqual(animationsStub.invocations.map(\.parameters), [cameraTransition])

        // adds the animator to the runner; since the added
        // animator is a wrapper around animatorImpl, verify indirectly
        XCTAssertEqual(runner.addStub.invocations.count, 1)
        let addedAnimator = try XCTUnwrap(runner.addStub.invocations.first?.parameters)
        animatorImpl.owner = .random()
        XCTAssertEqual(addedAnimator.owner, animatorImpl.owner)

        // does not start the animator
        XCTAssertEqual(animatorImpl.startAnimationStub.invocations.count, 0)

        // the returned animator is the one that was added to the runner
        XCTAssertIdentical(returnedAnimator, addedAnimator)
    }

    func testMakeAnimatorWithTimingParameters() throws {
        let duration = TimeInterval.random(in: 0...10)
        let timingParameters = MockTimingCurveProvider()
        let animationOwner = AnimationOwner.random()
        let animations = Stub<CameraTransition, Void>()

        let animator = impl.makeAnimator(
            duration: duration,
            timingParameters: timingParameters,
            animationOwner: animationOwner,
            animations: { animations.call(with: $0) })

        // creates the new animator
        XCTAssertEqual(factory.makeBasicCameraAnimatorWithTimingParametersStub.invocations.count, 1)
        let factoryInvocation = try XCTUnwrap(factory.makeBasicCameraAnimatorWithTimingParametersStub.invocations.first)
        XCTAssertEqual(factoryInvocation.parameters.duration, duration)
        XCTAssertIdentical(factoryInvocation.parameters.timingParameters, timingParameters)
        XCTAssertEqual(factoryInvocation.parameters.animationOwner, animationOwner)
        let animatorImpl = try XCTUnwrap(factoryInvocation.returnValue as? MockBasicCameraAnimator)

        try verifyMakeAnimator(
            animationsClosure: factoryInvocation.parameters.animations,
            animationsStub: animations,
            animatorImpl: animatorImpl,
            returnedAnimator: animator)
    }

    func testMakeAnimatorWithCurve() throws {
        let duration = TimeInterval.random(in: 0...10)
        let curve = UIView.AnimationCurve.random()
        let animationOwner = AnimationOwner.random()
        let animations = Stub<CameraTransition, Void>()

        let animator = impl.makeAnimator(
            duration: duration,
            curve: curve,
            animationOwner: animationOwner,
            animations: { animations.call(with: $0) })

        // creates the new animator
        XCTAssertEqual(factory.makeBasicCameraAnimatorWithCurveStub.invocations.count, 1)
        let factoryInvocation = try XCTUnwrap(factory.makeBasicCameraAnimatorWithCurveStub.invocations.first)
        XCTAssertEqual(factoryInvocation.parameters.duration, duration)
        XCTAssertEqual(factoryInvocation.parameters.curve, curve)
        XCTAssertEqual(factoryInvocation.parameters.animationOwner, animationOwner)
        let animatorImpl = try XCTUnwrap(factoryInvocation.returnValue as? MockBasicCameraAnimator)

        try verifyMakeAnimator(
            animationsClosure: factoryInvocation.parameters.animations,
            animationsStub: animations,
            animatorImpl: animatorImpl,
            returnedAnimator: animator)
    }

    func testMakeAnimatorWithControlPoints() throws {
        let duration = TimeInterval.random(in: 0...10)
        let controlPoint1 = CGPoint.random()
        let controlPoint2 = CGPoint.random()
        let animationOwner = AnimationOwner.random()
        let animations = Stub<CameraTransition, Void>()

        let animator = impl.makeAnimator(
            duration: duration,
            controlPoint1: controlPoint1,
            controlPoint2: controlPoint2,
            animationOwner: animationOwner,
            animations: { animations.call(with: $0) })

        // creates the new animator
        XCTAssertEqual(factory.makeBasicCameraAnimatorWithControlPointsStub.invocations.count, 1)
        let factoryInvocation = try XCTUnwrap(factory.makeBasicCameraAnimatorWithControlPointsStub.invocations.first)
        XCTAssertEqual(factoryInvocation.parameters.duration, duration)
        XCTAssertEqual(factoryInvocation.parameters.controlPoint1, controlPoint1)
        XCTAssertEqual(factoryInvocation.parameters.controlPoint2, controlPoint2)
        XCTAssertEqual(factoryInvocation.parameters.animationOwner, animationOwner)
        let animatorImpl = try XCTUnwrap(factoryInvocation.returnValue as? MockBasicCameraAnimator)

        try verifyMakeAnimator(
            animationsClosure: factoryInvocation.parameters.animations,
            animationsStub: animations,
            animatorImpl: animatorImpl,
            returnedAnimator: animator)
    }

    func testMakeAnimatorWithDampingRatio() throws {
        let duration = TimeInterval.random(in: 0...10)
        let dampingRatio = CGFloat.random(in: 0..<1)
        let animationOwner = AnimationOwner.random()
        let animations = Stub<CameraTransition, Void>()

        let animator = impl.makeAnimator(
            duration: duration,
            dampingRatio: dampingRatio,
            animationOwner: animationOwner,
            animations: { animations.call(with: $0) })

        // creates the new animator
        XCTAssertEqual(factory.makeBasicCameraAnimatorWithDampingRatioStub.invocations.count, 1)
        let factoryInvocation = try XCTUnwrap(factory.makeBasicCameraAnimatorWithDampingRatioStub.invocations.first)
        XCTAssertEqual(factoryInvocation.parameters.duration, duration)
        XCTAssertEqual(factoryInvocation.parameters.dampingRatio, dampingRatio)
        XCTAssertEqual(factoryInvocation.parameters.animationOwner, animationOwner)
        let animatorImpl = try XCTUnwrap(factoryInvocation.returnValue as? MockBasicCameraAnimator)

        try verifyMakeAnimator(
            animationsClosure: factoryInvocation.parameters.animations,
            animationsStub: animations,
            animatorImpl: animatorImpl,
            returnedAnimator: animator)
    }

    func testMakeSimpleCameraAnimator() throws {
        let from = CameraOptions.random()
        let to = CameraOptions.random()
        let duration = TimeInterval.random(in: 0...10)
        let curve = TimingCurve.random()
        let owner = AnimationOwner.random()

        let animator = impl.makeSimpleCameraAnimator(
            from: from,
            to: to,
            duration: duration,
            curve: curve,
            owner: owner)

        // creates animator
        XCTAssertEqual(factory.makeSimpleCameraAnimatorStub.invocations.count, 1)
        let factoryInvocation = try XCTUnwrap(factory.makeSimpleCameraAnimatorStub.invocations.first)
        XCTAssertEqual(factoryInvocation.parameters.from, from)
        XCTAssertEqual(factoryInvocation.parameters.to, to)
        XCTAssertEqual(factoryInvocation.parameters.duration, duration)
        XCTAssertEqual(factoryInvocation.parameters.curve, curve)
        XCTAssertEqual(factoryInvocation.parameters.owner, owner)
        let returnedAnimator = try XCTUnwrap(factoryInvocation.returnValue as? MockSimpleCameraAnimator)

        XCTAssertEqual(runner.addStub.invocations.count, 1)
        XCTAssertIdentical(runner.addStub.invocations.first?.parameters, returnedAnimator)
        XCTAssertIdentical(animator, returnedAnimator)
    }
}
