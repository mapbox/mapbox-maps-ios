import Foundation
@testable import MapboxMaps

final class MockCameraAnimationsManager: CameraAnimationsManagerProtocol {

    @Stubbed var cameraAnimators: [CameraAnimator] = []

    let cancelAnimationsStub = Stub<Void, Void>()
    func cancelAnimations() {
        cancelAnimationsStub.call()
    }

    struct FlyToParams {
        var to: CameraOptions
        var duration: TimeInterval?
        var completion: AnimationCompletion?
    }
    let flyToStub = Stub<FlyToParams, Cancelable>(defaultReturnValue: MockCancelable())
    func fly(to: CameraOptions,
             duration: TimeInterval?,
             completion: AnimationCompletion?) -> Cancelable {
        flyToStub.call(with: .init(to: to, duration: duration, completion: completion))
    }

   struct EaseToParams {
        var to: CameraOptions
        var duration: TimeInterval
        var curve: UIView.AnimationCurve
        var completion: AnimationCompletion?
    }
    let easeToStub = Stub<EaseToParams, Cancelable>(defaultReturnValue: MockCancelable())
    func ease(to: CameraOptions,
              duration: TimeInterval,
              curve: UIView.AnimationCurve,
              completion: AnimationCompletion?) -> Cancelable {
        easeToStub.call(
            with: EaseToParams(
                to: to,
                duration: duration,
                curve: curve,
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

    struct DecelerateParameters {
        var location: CGPoint
        var velocity: CGPoint
        var decelerationFactor: CGFloat
        var locationChangeHandler: (_ fromLocation: CGPoint, _ toLocation: CGPoint) -> Void
        var completion: AnimationCompletion?
    }
    let decelerateStub = Stub<DecelerateParameters, Void>()
    func decelerate(location: CGPoint,
                    velocity: CGPoint,
                    decelerationFactor: CGFloat,
                    locationChangeHandler: @escaping (_ fromLocation: CGPoint, _ toLocation: CGPoint) -> Void,
                    completion: AnimationCompletion?) {
        decelerateStub.call(
            with: DecelerateParameters(
                location: location,
                velocity: velocity,
                decelerationFactor: decelerationFactor,
                locationChangeHandler: locationChangeHandler,
                completion: completion))
    }
}
