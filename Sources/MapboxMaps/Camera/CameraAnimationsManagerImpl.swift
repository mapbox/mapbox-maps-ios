import UIKit
@_implementationOnly import MapboxCommon_Private

internal protocol CameraAnimationsManagerProtocol: AnyObject {

    var cameraAnimators: [CameraAnimator] { get }

    func cancelAnimations()
    func cancelAnimations(withOwners owners: [AnimationOwner], andTypes types: [AnimationType])

    @discardableResult
    func fly(to: CameraOptions,
             duration: TimeInterval?,
             curve: TimingCurve,
             completion: AnimationCompletion?) -> Cancelable

    @discardableResult
    func ease(to: CameraOptions,
              duration: TimeInterval,
              curve: UIView.AnimationCurve,
              animationOwner: AnimationOwner,
              completion: AnimationCompletion?) -> Cancelable

    func decelerate(location: CGPoint,
                    velocity: CGPoint,
                    decelerationFactor: CGFloat,
                    locationChangeHandler: @escaping (_ fromLocation: CGPoint, _ toLocation: CGPoint) -> Void,
                    completion: AnimationCompletion?)

    func makeAnimator(duration: TimeInterval,
                      timingParameters: UITimingCurveProvider,
                      animationOwner: AnimationOwner,
                      animations: @escaping (inout CameraTransition) -> Void) -> BasicCameraAnimator

    func makeAnimator(duration: TimeInterval,
                      curve: UIView.AnimationCurve,
                      animationOwner: AnimationOwner,
                      animations: @escaping (inout CameraTransition) -> Void) -> BasicCameraAnimator

    func makeAnimator(duration: TimeInterval,
                      controlPoint1: CGPoint,
                      controlPoint2: CGPoint,
                      animationOwner: AnimationOwner,
                      animations: @escaping (inout CameraTransition) -> Void) -> BasicCameraAnimator

    func makeAnimator(duration: TimeInterval,
                      dampingRatio: CGFloat,
                      animationOwner: AnimationOwner,
                      animations: @escaping (inout CameraTransition) -> Void) -> BasicCameraAnimator

    func makeSimpleCameraAnimator(from: CameraOptions,
                                  to: CameraOptions,
                                  duration: TimeInterval,
                                  curve: TimingCurve,
                                  owner: AnimationOwner) -> SimpleCameraAnimatorProtocol
    var onCameraAnimatorStatusChanged: Signal<CameraAnimatorStatusPayload> { get }
}

internal final class CameraAnimationsManagerImpl: CameraAnimationsManagerProtocol {

    private let factory: CameraAnimatorsFactoryProtocol
    private let runner: CameraAnimatorsRunnerProtocol

    var onCameraAnimatorStatusChanged: Signal<CameraAnimatorStatusPayload> { runner.onCameraAnimatorStatusChanged }

    /// See ``CameraAnimationsManager/cameraAnimators``.
    internal var cameraAnimators: [CameraAnimator] {
        return runner.cameraAnimators
    }

    internal init(factory: CameraAnimatorsFactoryProtocol,
                  runner: CameraAnimatorsRunnerProtocol) {
        self.factory = factory
        self.runner = runner
    }

    /// See ``CameraAnimationsManager/cancelAnimations()``.
    internal func cancelAnimations() {
        runner.cancelAnimations()
    }

    internal func cancelAnimations(withOwners owners: [AnimationOwner], andTypes types: [AnimationType]) {
        runner.cancelAnimations(withOwners: owners, andTypes: types)
    }

    // MARK: - High-Level Animation APIs

    /// See ``CameraAnimationsManager/fly(to:duration:completion:)``.
    @discardableResult
    internal func fly(to: CameraOptions,
                      duration: TimeInterval?,
                      curve: TimingCurve,
                      completion: AnimationCompletion?) -> Cancelable {
        runner.cancelAnimations(withOwners: [.cameraAnimationsManager])
        let animator = factory.makeFlyToAnimator(
            toCamera: to,
            duration: duration,
            curve: curve,
            animationOwner: .cameraAnimationsManager)
        if let completion = completion {
            animator.addCompletion(completion)
        }
        runner.add(animator)
        animator.startAnimation()
        return animator
    }

    /// See ``CameraAnimationsManager/ease(to:duration:curve:completion:)``.
    @discardableResult
    func ease(
        to: CameraOptions,
        duration: TimeInterval,
        curve: UIView.AnimationCurve,
        animationOwner: AnimationOwner,
        completion: AnimationCompletion?
    ) -> Cancelable {
        runner.cancelAnimations(withOwners: [animationOwner])
        let animatorImpl = factory.makeBasicCameraAnimator(
            duration: duration,
            curve: curve,
            animationOwner: animationOwner,
            animations: { (transition) in
                transition.center.toValue = to.center
                transition.padding.toValue = to.padding
                // don't animate the anchor since that's unlikely to be the caller's intent
                if let anchor = to.anchor {
                    transition.anchor.fromValue = anchor
                    transition.anchor.toValue = anchor
                }
                transition.zoom.toValue = to.zoom
                transition.bearing.toValue = to.bearing
                transition.pitch.toValue = to.pitch
            })
        let animator = BasicCameraAnimator(impl: animatorImpl)
        if let completion = completion {
            animator.addCompletion(completion)
        }
        runner.add(animator)
        animator.startAnimation()
        return animator
    }

    /// This function will handle the natural deceleration of a gesture when there is a velocity provided. A use case for this is the pan gesture.
    /// - Parameters:
    ///   - location: The initial location. This location will be simulated based on velocity and decelerationFactor.
    ///   - velocity: The initial velocity.
    ///   - decelerationFactor: A factor by which the velocity is multiplied once per millisecond. Typically slightly less than 1 so that the velocity slowly decreases over time.
    ///   - locationChangeHandler: A block that is called at each frame which provides the updated from and to location.
    ///   - completion: A completion block that is called when the animation finishes.
    internal func decelerate(location: CGPoint,
                             velocity: CGPoint,
                             decelerationFactor: CGFloat,
                             locationChangeHandler: @escaping (_ fromLocation: CGPoint, _ toLocation: CGPoint) -> Void,
                             completion: AnimationCompletion?) {
        runner.cancelAnimations(withOwners: [.cameraAnimationsManager])
        let animator = factory.makeGestureDecelerationCameraAnimator(
            location: location,
            velocity: velocity,
            decelerationFactor: decelerationFactor,
            animationOwner: .cameraAnimationsManager,
            locationChangeHandler: locationChangeHandler)
        if let completion = completion {
            animator.addCompletion(completion)
        }
        runner.add(animator)
        animator.startAnimation()
    }

    // MARK: - Low-Level Animation APIs

    /// See ``CameraAnimationsManager/makeAnimator(duration:timingParameters:animationOwner:animations:)``.
    internal func makeAnimator(duration: TimeInterval,
                               timingParameters: UITimingCurveProvider,
                               animationOwner: AnimationOwner,
                               animations: @escaping (inout CameraTransition) -> Void) -> BasicCameraAnimator {
        let animatorImpl = factory.makeBasicCameraAnimator(
            duration: duration,
            timingParameters: timingParameters,
            animationOwner: animationOwner,
            animations: animations)
        let animator = BasicCameraAnimator(impl: animatorImpl)
        runner.add(animator)
        return animator
    }

    /// See ``CameraAnimationsManager/makeAnimator(duration:curve:animationOwner:animations:)``.
    internal func makeAnimator(duration: TimeInterval,
                               curve: UIView.AnimationCurve,
                               animationOwner: AnimationOwner,
                               animations: @escaping (inout CameraTransition) -> Void) -> BasicCameraAnimator {
        let animatorImpl = factory.makeBasicCameraAnimator(
            duration: duration,
            curve: curve,
            animationOwner: animationOwner,
            animations: animations)
        let animator = BasicCameraAnimator(impl: animatorImpl)
        runner.add(animator)
        return animator
    }

    /// See ``CameraAnimationsManager/makeAnimator(duration:controlPoint1:controlPoint2:animationOwner:animations:)``.
    internal func makeAnimator(duration: TimeInterval,
                               controlPoint1: CGPoint,
                               controlPoint2: CGPoint,
                               animationOwner: AnimationOwner,
                               animations: @escaping (inout CameraTransition) -> Void) -> BasicCameraAnimator {
        let animatorImpl = factory.makeBasicCameraAnimator(
            duration: duration,
            controlPoint1: controlPoint1,
            controlPoint2: controlPoint2,
            animationOwner: animationOwner,
            animations: animations)
        let animator = BasicCameraAnimator(impl: animatorImpl)
        runner.add(animator)
        return animator
    }

    /// See ``CameraAnimationsManager/makeAnimator(duration:dampingRatio:animationOwner:animations:)``.
    internal func makeAnimator(duration: TimeInterval,
                               dampingRatio: CGFloat,
                               animationOwner: AnimationOwner,
                               animations: @escaping (inout CameraTransition) -> Void) -> BasicCameraAnimator {
        let animatorImpl = factory.makeBasicCameraAnimator(
            duration: duration,
            dampingRatio: dampingRatio,
            animationOwner: animationOwner,
            animations: animations)
        let animator = BasicCameraAnimator(impl: animatorImpl)
        runner.add(animator)
        return animator
    }

    internal func makeSimpleCameraAnimator(from: CameraOptions,
                                           to: CameraOptions,
                                           duration: TimeInterval,
                                           curve: TimingCurve,
                                           owner: AnimationOwner) -> SimpleCameraAnimatorProtocol {
        let animator = factory.makeSimpleCameraAnimator(
            from: from,
            to: to,
            duration: duration,
            curve: curve,
            owner: owner)
        runner.add(animator)
        return animator
    }
}

extension CameraAnimationsManagerProtocol {

    /// See ``CameraAnimationsManager/ease(to:duration:curve:completion:)``.
    @discardableResult
    func ease(
        to: CameraOptions,
        duration: TimeInterval,
        curve: UIView.AnimationCurve,
        completion: AnimationCompletion?
    ) -> Cancelable {
        ease(to: to, duration: duration, curve: curve, animationOwner: .cameraAnimationsManager, completion: completion)
    }
}
