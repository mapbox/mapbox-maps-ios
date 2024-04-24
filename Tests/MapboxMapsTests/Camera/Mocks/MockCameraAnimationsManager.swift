import UIKit
@testable import MapboxMaps

final class MockCameraAnimationsManager: CameraAnimationsManagerProtocol {

    @Stubbed var cameraAnimators: [CameraAnimator] = []
    @TestSignal var onCameraAnimatorStatusChanged: Signal<CameraAnimatorStatusPayload>

    let cancelAnimationsStub = Stub<Void, Void>()
    func cancelAnimations() {
        cancelAnimationsStub.call()
    }

    let cancelAnimationsOwnersTypesStub = Stub<(owners: [AnimationOwner], types: [AnimationType]), Void>()
    func cancelAnimations(withOwners owners: [AnimationOwner], andTypes types: [AnimationType]) {
        cancelAnimationsOwnersTypesStub.call(with: (owners: owners, types: types))
    }

    struct FlyToParams {
        var to: CameraOptions
        var duration: TimeInterval?
        var curve: TimingCurve
        var completion: AnimationCompletion?
    }
    let flyToStub = Stub<FlyToParams, Cancelable>(defaultReturnValue: MockCancelable())
    func fly(to: CameraOptions,
             duration: TimeInterval?,
             curve: TimingCurve,
             completion: AnimationCompletion?) -> Cancelable {
        flyToStub.call(
            with: FlyToParams(
                to: to,
                duration: duration,
                curve: curve,
                completion: completion))
    }

   struct EaseToParams {
       let to: CameraOptions
       let duration: TimeInterval
       let curve: UIView.AnimationCurve
       let animationOwner: AnimationOwner
       let completion: AnimationCompletion?
    }
    let easeToStub = Stub<EaseToParams, Cancelable>(defaultReturnValue: MockCancelable())
    func ease(to: CameraOptions,
              duration: TimeInterval,
              curve: UIView.AnimationCurve,
              animationOwner: AnimationOwner,
              completion: AnimationCompletion?) -> Cancelable {
        easeToStub.call(
            with: EaseToParams(
                to: to,
                duration: duration,
                curve: curve,
                animationOwner: animationOwner,
                completion: completion))
    }

    struct DecelerateParams {
        var location: CGPoint
        var velocity: CGPoint
        var decelerationFactor: CGFloat
        var locationChangeHandler: (_ fromLocation: CGPoint, _ toLocation: CGPoint) -> Void
        var completion: AnimationCompletion?
    }
    let decelerateStub = Stub<DecelerateParams, Void>()
    func decelerate(location: CGPoint,
                    velocity: CGPoint,
                    decelerationFactor: CGFloat,
                    locationChangeHandler: @escaping (_ fromLocation: CGPoint, _ toLocation: CGPoint) -> Void,
                    completion: AnimationCompletion?) {
        decelerateStub.call(
            with: DecelerateParams(
                location: location,
                velocity: velocity,
                decelerationFactor: decelerationFactor,
                locationChangeHandler: locationChangeHandler,
                completion: completion))
    }

    struct MakeAnimatorWithTimingParametersParams {
        var duration: TimeInterval
        var timingParameters: UITimingCurveProvider
        var animationOwner: AnimationOwner
        var animations: (inout CameraTransition) -> Void
    }
    let makeAnimatorWithTimingParametersStub = Stub<MakeAnimatorWithTimingParametersParams, BasicCameraAnimator>(
        defaultReturnValue: BasicCameraAnimator(impl: MockBasicCameraAnimator()))
    func makeAnimator(duration: TimeInterval,
                      timingParameters: UITimingCurveProvider,
                      animationOwner: AnimationOwner,
                      animations: @escaping (inout CameraTransition) -> Void) -> BasicCameraAnimator {
        makeAnimatorWithTimingParametersStub.call(with: .init(
            duration: duration,
            timingParameters: timingParameters,
            animationOwner: animationOwner,
            animations: animations))
    }

    struct MakeAnimatorWithCurveParams {
        var duration: TimeInterval
        var curve: UIView.AnimationCurve
        var animationOwner: AnimationOwner
        var animations: (inout CameraTransition) -> Void
    }
    let makeAnimatorWithCurveStub = Stub<MakeAnimatorWithCurveParams, BasicCameraAnimator>(
        defaultReturnValue: BasicCameraAnimator(impl: MockBasicCameraAnimator()))
    func makeAnimator(duration: TimeInterval,
                      curve: UIView.AnimationCurve,
                      animationOwner: AnimationOwner,
                      animations: @escaping (inout CameraTransition) -> Void) -> BasicCameraAnimator {
        makeAnimatorWithCurveStub.call(with: .init(
            duration: duration,
            curve: curve,
            animationOwner: animationOwner,
            animations: animations))
    }

    struct MakeAnimatorWithControlPointsParams {
        var duration: TimeInterval
        var controlPoint1: CGPoint
        var controlPoint2: CGPoint
        var animationOwner: AnimationOwner
        var animations: (inout CameraTransition) -> Void
    }
    let makeAnimatorWithControlPointsStub = Stub<MakeAnimatorWithControlPointsParams, BasicCameraAnimator>(
        defaultReturnValue: BasicCameraAnimator(impl: MockBasicCameraAnimator()))
    func makeAnimator(duration: TimeInterval,
                      controlPoint1: CGPoint,
                      controlPoint2: CGPoint,
                      animationOwner: AnimationOwner,
                      animations: @escaping (inout CameraTransition) -> Void) -> BasicCameraAnimator {
        makeAnimatorWithControlPointsStub.call(with: .init(
            duration: duration,
            controlPoint1: controlPoint1,
            controlPoint2: controlPoint2,
            animationOwner: animationOwner,
            animations: animations))
    }

    struct MakeAnimatorWithDampingRatioParams {
        var duration: TimeInterval
        var dampingRatio: CGFloat
        var animationOwner: AnimationOwner
        var animations: (inout CameraTransition) -> Void
    }
    let makeAnimatorWithDampingRatioStub = Stub<MakeAnimatorWithDampingRatioParams, BasicCameraAnimator>(
        defaultReturnValue: BasicCameraAnimator(impl: MockBasicCameraAnimator()))
    func makeAnimator(duration: TimeInterval,
                      dampingRatio: CGFloat,
                      animationOwner: AnimationOwner,
                      animations: @escaping (inout CameraTransition) -> Void) -> BasicCameraAnimator {
        makeAnimatorWithDampingRatioStub.call(with: .init(
            duration: duration,
            dampingRatio: dampingRatio,
            animationOwner: animationOwner,
            animations: animations))
    }

    struct MakeSimpleCameraAnimatorParams {
        var from: CameraOptions
        var to: CameraOptions
        var duration: TimeInterval
        var curve: TimingCurve
        var owner: AnimationOwner
    }
    let makeSimpleCameraAnimatorStub = Stub<
        MakeSimpleCameraAnimatorParams,
        SimpleCameraAnimatorProtocol>(
            defaultReturnValue: MockSimpleCameraAnimator())
    func makeSimpleCameraAnimator(from: CameraOptions,
                                  to: CameraOptions,
                                  duration: TimeInterval,
                                  curve: TimingCurve,
                                  owner: AnimationOwner) -> SimpleCameraAnimatorProtocol {
        makeSimpleCameraAnimatorStub.call(with: .init(
            from: from,
            to: to,
            duration: duration,
            curve: curve,
            owner: owner))
    }
}
