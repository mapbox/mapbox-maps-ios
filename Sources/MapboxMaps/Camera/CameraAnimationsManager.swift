import UIKit

/// APIs for animating the camera.
public final class CameraAnimationsManager {

    private let impl: CameraAnimationsManagerProtocol

    internal init(impl: CameraAnimationsManagerProtocol) {
        self.impl = impl
    }

    /// List of animators currently alive
    public var cameraAnimators: [CameraAnimator] {
        return impl.cameraAnimators
    }

    /// Interrupts all `active` animation.
    /// The camera remains at the last point before the cancel request was invoked, i.e.,
    /// the camera is not reset or fast-forwarded to the end of the transition.
    /// Canceled animations cannot be restarted / resumed. The animator must be recreated.
    public func cancelAnimations() {
        impl.cancelAnimations()
    }

    // MARK: High-Level Animation APIs

    /// Moves the viewpoint to a different location using a transition animation that
    /// evokes powered flight and an optional transition duration and timing function.
    /// It seamlessly incorporates zooming and panning to help
    /// the user find his or her bearings even after traversing a great distance.
    ///
    /// - Parameters:
    ///   - to: The camera options at the end of the animation. Any camera parameters that are nil will
    ///         not be animated.
    ///   - duration: Duration of the animation, measured in seconds. If nil, a suitable calculated
    ///               duration is used.
    ///   - curve: The easing curve for the animation
    ///   - completion: Completion handler called when the animation stops
    /// - Returns: An instance of `Cancelable` which can be canceled if necessary
    @discardableResult
    public func fly(
        to: CameraOptions,
        duration: TimeInterval? = nil,
        curve: TimingCurve = .easeOut,
        completion: AnimationCompletion? = nil
    ) -> Cancelable {
        return impl.fly(to: to, duration: duration, curve: curve, completion: completion)
    }

    /// Ease the camera to a destination
    /// - Parameters:
    ///   - to: the target camera after animation; if `camera.anchor` is non-nil, it is use for both
    ///         the `fromValue` and the `toValue` of the underlying animation such that the
    ///         value specified will not be interpolated, but will be passed as-is to each camera update
    ///         during the animation. To animate `anchor` itself, use the `makeAnimator` APIs.
    ///   - duration: duration of the animation
    ///   - curve: the easing curve for the animation
    ///   - completion: completion to be called after animation
    /// - Returns: An instance of `Cancelable` which can be canceled if necessary
    @discardableResult
    public func ease(
        to: CameraOptions,
        duration: TimeInterval,
        curve: UIView.AnimationCurve = .easeOut,
        completion: AnimationCompletion? = nil
    ) -> Cancelable {
        return impl.ease(
            to: to,
            duration: duration,
            curve: curve,
            completion: completion)
    }

    // MARK: Low-Level Animation APIs

    /// Creates a ``BasicCameraAnimator``.
    ///
    /// - Note: `CameraAnimationsManager` only keeps animators alive while their
    ///         ``CameraAnimator/state`` is `.active`.
    ///
    /// - Parameters:
    ///   - duration: The duration of the animation.
    ///   - timingParameters: The object providing the timing information. This object must adopt
    ///                       the `UITimingCurveProvider` protocol.
    ///   - animationOwner: An `AnimationOwner` that can be used to identify what component
    ///                     initiated an animation.
    ///   - animations: a closure that configures the animation's to and from values via a
    ///                 ``CameraTransition``.
    /// - Returns: A new ``BasicCameraAnimator``.
    public func makeAnimator(duration: TimeInterval,
                             timingParameters: UITimingCurveProvider,
                             animationOwner: AnimationOwner = .unspecified,
                             animations: @escaping (inout CameraTransition) -> Void) -> BasicCameraAnimator {
        return impl.makeAnimator(
            duration: duration,
            timingParameters: timingParameters,
            animationOwner: animationOwner,
            animations: animations)
    }

    /// Creates a ``BasicCameraAnimator``.
    ///
    /// - Note: `CameraAnimationsManager` only keeps animators alive while their
    ///         ``CameraAnimator/state`` is `.active`.
    ///
    /// - Parameters:
    ///   - duration: The duration of the animation.
    ///   - curve: One of UIKit's predefined timing curves to apply to the animation.
    ///   - animationOwner: An `AnimationOwner` that can be used to identify what component
    ///                     initiated an animation.
    ///   - animations: a closure that configures the animation's to and from values via a
    ///                 ``CameraTransition``.
    /// - Returns: A new ``BasicCameraAnimator``.
    public func makeAnimator(duration: TimeInterval,
                             curve: UIView.AnimationCurve,
                             animationOwner: AnimationOwner = .unspecified,
                             animations: @escaping (inout CameraTransition) -> Void) -> BasicCameraAnimator {
        return impl.makeAnimator(
            duration: duration,
            curve: curve,
            animationOwner: animationOwner,
            animations: animations)
    }

    /// Creates a ``BasicCameraAnimator``.
    ///
    /// - Note: `CameraAnimationsManager` only keeps animators alive while their
    ///         ``CameraAnimator/state`` is `.active`.
    ///
    /// - Parameters:
    ///   - duration: The duration of the animation.
    ///   - controlPoint1: The first control point for the cubic Bézier timing curve.
    ///   - controlPoint2: The second control point for the cubic Bézier timing curve.
    ///   - animationOwner: An `AnimationOwner` that can be used to identify what component
    ///                     initiated an animation.
    ///   - animations: a closure that configures the animation's to and from values via a
    ///                 ``CameraTransition``.
    /// - Returns: A new ``BasicCameraAnimator``.
    public func makeAnimator(duration: TimeInterval,
                             controlPoint1: CGPoint,
                             controlPoint2: CGPoint,
                             animationOwner: AnimationOwner = .unspecified,
                             animations: @escaping (inout CameraTransition) -> Void) -> BasicCameraAnimator {
        return impl.makeAnimator(
            duration: duration,
            controlPoint1: controlPoint1,
            controlPoint2: controlPoint2,
            animationOwner: animationOwner,
            animations: animations)
    }

    /// Creates a ``BasicCameraAnimator``.
    ///
    /// - Note: `CameraAnimationsManager` only keeps animators alive while their
    ///         ``CameraAnimator/state`` is `.active`.
    ///
    /// - Parameters:
    ///   - duration: The duration of the animation.
    ///   - dampingRatio: The damping ratio to apply to the initial acceleration and oscillation. To
    ///                   smoothly decelerate the animation without oscillation, specify a value of 1.
    ///                   Specify values closer to 0 to create less damping and more oscillation.
    ///   - animationOwner: An `AnimationOwner` that can be used to identify what component
    ///                     initiated an animation.
    ///   - animations: a closure that configures the animation's to and from values via a
    ///                 ``CameraTransition``.
    /// - Returns: A new ``BasicCameraAnimator``.
    public func makeAnimator(duration: TimeInterval,
                             dampingRatio: CGFloat,
                             animationOwner: AnimationOwner = .unspecified,
                             animations: @escaping (inout CameraTransition) -> Void) -> BasicCameraAnimator {
        return impl.makeAnimator(
            duration: duration,
            dampingRatio: dampingRatio,
            animationOwner: animationOwner,
            animations: animations)
    }

    /// A stream that  emits an event  when a ``CameraAnimator`` has started
    public var onCameraAnimatorStarted: Signal<CameraAnimator> {
        impl.onCameraAnimatorStatusChanged
            .compactMap { (animator, status) in
                guard status == .started else { return nil }
                return animator
            }
    }

    /// A stream that  emits an event  when a ``CameraAnimator`` has finished.
    public var onCameraAnimatorFinished: Signal<CameraAnimator> {
        impl.onCameraAnimatorStatusChanged
            .compactMap { (animator, status) in
                guard status == .stopped(reason: .finished) else { return nil }
                return animator
            }
    }

    /// A stream that  emits an event  when a ``CameraAnimator`` has cancelled.
    public var onCameraAnimatorCancelled: Signal<CameraAnimator> {
        impl.onCameraAnimatorStatusChanged
            .compactMap { (animator, status) in
                guard status == .stopped(reason: .cancelled) else { return nil }
                return animator
            }
    }
}
