import UIKit
@testable import MapboxMaps

final class MockCameraAnimatorsFactory: CameraAnimatorsFactoryProtocol {
    struct MakeFlyToAnimatorParams {
        var toCamera: CameraOptions
        var animationOwner: AnimationOwner
        var duration: TimeInterval?
    }
    let makeFlyToAnimatorStub = Stub<MakeFlyToAnimatorParams, CameraAnimatorProtocol>(
        defaultReturnValue: MockCameraAnimator())
    func makeFlyToAnimator(toCamera: CameraOptions,
                           duration: TimeInterval?,
                           curve: TimingCurve,
                           animationOwner: AnimationOwner) -> CameraAnimatorProtocol {
        makeFlyToAnimatorStub.call(with: .init(
            toCamera: toCamera,
            animationOwner: animationOwner,
            duration: duration))
    }

    struct MakeBasicCameraAnimatorWithTimingParametersParams {
        var duration: TimeInterval
        var timingParameters: UITimingCurveProvider
        var animationOwner: AnimationOwner
        var animations: (inout CameraTransition) -> Void
    }
    let makeBasicCameraAnimatorWithTimingParametersStub = Stub<
        MakeBasicCameraAnimatorWithTimingParametersParams,
        BasicCameraAnimatorProtocol>(
            defaultReturnValue: MockBasicCameraAnimator())
    func makeBasicCameraAnimator(duration: TimeInterval,
                                 timingParameters: UITimingCurveProvider,
                                 animationOwner: AnimationOwner,
                                 animations: @escaping (inout CameraTransition) -> Void) -> BasicCameraAnimatorProtocol {
        makeBasicCameraAnimatorWithTimingParametersStub.call(with: .init(
            duration: duration,
            timingParameters: timingParameters,
            animationOwner: animationOwner,
            animations: animations))
    }

    struct MakeBasicCameraAnimatorWithCurveParams {
        var duration: TimeInterval
        var curve: UIView.AnimationCurve
        var animationOwner: AnimationOwner
        var animations: (inout CameraTransition) -> Void
    }
    let makeBasicCameraAnimatorWithCurveStub = Stub<
        MakeBasicCameraAnimatorWithCurveParams,
        BasicCameraAnimatorProtocol>(
            defaultReturnValue: MockBasicCameraAnimator())
    func makeBasicCameraAnimator(duration: TimeInterval,
                                 curve: UIView.AnimationCurve,
                                 animationOwner: AnimationOwner,
                                 animations: @escaping (inout CameraTransition) -> Void) -> BasicCameraAnimatorProtocol {
        makeBasicCameraAnimatorWithCurveStub.call(with: .init(
            duration: duration,
            curve: curve,
            animationOwner: animationOwner,
            animations: animations))
    }

    struct MakeBasicCameraAnimatorWithControlPointsParams {
        var duration: TimeInterval
        var controlPoint1: CGPoint
        var controlPoint2: CGPoint
        var animationOwner: AnimationOwner
        var animations: (inout CameraTransition) -> Void
    }
    let makeBasicCameraAnimatorWithControlPointsStub = Stub<
        MakeBasicCameraAnimatorWithControlPointsParams,
        BasicCameraAnimatorProtocol>(
            defaultReturnValue: MockBasicCameraAnimator())
    func makeBasicCameraAnimator(duration: TimeInterval,
                                 controlPoint1: CGPoint,
                                 controlPoint2: CGPoint,
                                 animationOwner: AnimationOwner,
                                 animations: @escaping (inout CameraTransition) -> Void) -> BasicCameraAnimatorProtocol {
        makeBasicCameraAnimatorWithControlPointsStub.call(with: .init(
            duration: duration,
            controlPoint1: controlPoint1,
            controlPoint2: controlPoint2,
            animationOwner: animationOwner,
            animations: animations))
    }

    struct MakeBasicCameraAnimatorWithDampingRatioParams {
        var duration: TimeInterval
        var dampingRatio: CGFloat
        var animationOwner: AnimationOwner
        var animations: (inout CameraTransition) -> Void
    }
    let makeBasicCameraAnimatorWithDampingRatioStub = Stub<
        MakeBasicCameraAnimatorWithDampingRatioParams,
        BasicCameraAnimatorProtocol>(
            defaultReturnValue: MockBasicCameraAnimator())
    func makeBasicCameraAnimator(duration: TimeInterval,
                                 dampingRatio: CGFloat,
                                 animationOwner: AnimationOwner,
                                 animations: @escaping (inout CameraTransition) -> Void) -> BasicCameraAnimatorProtocol {
        makeBasicCameraAnimatorWithDampingRatioStub.call(with: .init(
            duration: duration,
            dampingRatio: dampingRatio,
            animationOwner: animationOwner,
            animations: animations))
    }

    struct MakeGestureDecelerationCameraAnimatorParams {
        var location: CGPoint
        var velocity: CGPoint
        var decelerationFactor: CGFloat
        var animationOwner: AnimationOwner
        var locationChangeHandler: (_ fromLocation: CGPoint, _ toLocation: CGPoint) -> Void
    }
    let makeGestureDecelerationCameraAnimatorStub = Stub<
        MakeGestureDecelerationCameraAnimatorParams,
        CameraAnimatorProtocol>(
            defaultReturnValue: MockCameraAnimator())
    func makeGestureDecelerationCameraAnimator(location: CGPoint,
                                               velocity: CGPoint,
                                               decelerationFactor: CGFloat,
                                               animationOwner: AnimationOwner,
                                               locationChangeHandler: @escaping (_ fromLocation: CGPoint, _ toLocation: CGPoint) -> Void) -> CameraAnimatorProtocol {
        makeGestureDecelerationCameraAnimatorStub.call(with: .init(
            location: location,
            velocity: velocity,
            decelerationFactor: decelerationFactor,
            animationOwner: animationOwner,
            locationChangeHandler: locationChangeHandler))
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
