import Foundation
@testable import MapboxMaps

final class MockCameraAnimationsManager: CameraAnimationsManagerProtocol {

    struct EaseToCameraParameters {
        var camera: CameraOptions
        var duration: TimeInterval
        var curve: UIView.AnimationCurve
        var completion: AnimationCompletion?
    }
    let easeToStub = Stub<EaseToCameraParameters, Cancelable?>(defaultReturnValue: MockCancelable())
    func ease(to camera: CameraOptions,
              duration: TimeInterval,
              curve: UIView.AnimationCurve,
              completion: AnimationCompletion?) -> Cancelable? {
        return easeToStub.call(
            with: EaseToCameraParameters(
                camera: camera,
                duration: duration,
                curve: curve,
                completion: completion))
    }

    let cancelAnimationsStub = Stub<Void, Void>()
    func cancelAnimations() {
        cancelAnimationsStub.call()
    }

    var animationsEnabled: Bool = true

    struct DecelerateParameters {
        var location: CGPoint
        var velocity: CGPoint
        var decelerationFactor: CGFloat
        var locationChangeHandler: (_ fromLocation: CGPoint, _ toLocation: CGPoint) -> Void
        var completion: () -> Void
    }
    let decelerateStub = Stub<DecelerateParameters, Void>()
    func decelerate(location: CGPoint,
                    velocity: CGPoint,
                    decelerationFactor: CGFloat,
                    locationChangeHandler: @escaping (_ fromLocation: CGPoint, _ toLocation: CGPoint) -> Void,
                    completion: @escaping () -> Void) {

        return decelerateStub.call(
            with: DecelerateParameters(
                location: location,
                velocity: velocity,
                decelerationFactor: decelerationFactor,
                locationChangeHandler: locationChangeHandler,
                completion: completion))
    }

    struct MakeAnimatorParams {
        var duration: TimeInterval
        var curve: UIView.AnimationCurve
        var animationOwner: AnimationOwner
        var animations: (inout CameraTransition) -> Void
    }
    // TODO: refactor CameraAnimationsManager to use internal Impl and make internal components depend on the impl protocol
    let makeAnimatorStub = Stub<MakeAnimatorParams, BasicCameraAnimator>(
        defaultReturnValue: BasicCameraAnimator(
            propertyAnimator: MockPropertyAnimator(),
            owner: .unspecified,
            mapboxMap: MockMapboxMap(),
            cameraView: MockCameraView(),
            delegate: MockCameraAnimatorDelegate()))
    func makeAnimator(duration: TimeInterval,
                      curve: UIView.AnimationCurve,
                      animationOwner: AnimationOwner,
                      animations: @escaping (inout CameraTransition) -> Void) -> BasicCameraAnimator {
        makeAnimatorStub.call(with: .init(
            duration: duration,
            curve: curve,
            animationOwner: animationOwner,
            animations: animations))
    }
}
