import UIKit

public final class BasicCameraAnimator: NSObject, CameraAnimator, CameraAnimatorProtocol {

    private let impl: BasicCameraAnimatorProtocol

    /// The animator's owner.
    public var owner: AnimationOwner {
        impl.owner
    }

    internal weak var delegate: CameraAnimatorDelegate?

    /// Defines the transition that will occur to the `CameraOptions` of the renderer due to this animator
    public var transition: CameraTransition? {
        impl.transition
    }

    /// The state from of the animator.
    public var state: UIViewAnimatingState {
        impl.state
    }

    /// Boolean that represents if the animation is running or not.
    public var isRunning: Bool {
        impl.isRunning
    }

    /// Boolean that represents if the animation is running normally or in reverse.
    public var isReversed: Bool {
        get { impl.isReversed }
        set { impl.isReversed = newValue }
    }

    /// A Boolean value that indicates whether a completed animation remains in the active state.
    public var pausesOnCompletion: Bool {
        get { impl.pausesOnCompletion }
        set { impl.pausesOnCompletion = newValue }
    }

    /// Value that represents what percentage of the animation has been completed.
    public var fractionComplete: Double {
        get { impl.fractionComplete }
        set { impl.fractionComplete = newValue }
    }

    internal init(impl: BasicCameraAnimatorProtocol) {
        self.impl = impl
        super.init()
        impl.delegate = self
    }

    /// Starts the animation if this animator is in `inactive` state. Also used to resume a "paused"
    /// animation. Calling this method on an animator that has already completed or been canceled has
    /// no effect.
    public func startAnimation() {
        impl.startAnimation()
    }

    /// Starts the animation after a delay. This cannot be called on a paused animation.
    /// If animations are cancelled before the end of the delay, it will also be cancelled. Calling this method
    /// on an animator that has already completed or been canceled has no effect.
    /// - Parameter delay: Delay (in seconds) after which the animation should start
    public func startAnimation(afterDelay delay: TimeInterval) {
        impl.startAnimation(afterDelay: delay)
    }

    /// Pauses the animation. Calling this method on an animator that has already completed or been
    /// canceled has no effect.
    public func pauseAnimation() {
        impl.pauseAnimation()
    }

    /// Stops the animation.
    public func stopAnimation() {
        impl.stopAnimation()
    }

    /// Add a completion block to the animator.
    public func addCompletion(_ completion: @escaping AnimationCompletion) {
        impl.addCompletion(completion)
    }

    /// Continue the animation with a timing parameter (`UITimingCurveProvider`) and duration factor (`CGFloat`).
    public func continueAnimation(withTimingParameters timingParameters: UITimingCurveProvider?,
                                  durationFactor: Double) {
        impl.continueAnimation(
            withTimingParameters: timingParameters,
            durationFactor: durationFactor)
    }

    public func cancel() {
        impl.stopAnimation()
    }

    internal func update() {
        impl.update()
    }
}

extension BasicCameraAnimator: BasicCameraAnimatorDelegate {
    internal func basicCameraAnimatorDidStartRunning(_ animator: BasicCameraAnimatorProtocol) {
        delegate?.cameraAnimatorDidStartRunning(self)
    }

    internal func basicCameraAnimatorDidStopRunning(_ animator: BasicCameraAnimatorProtocol) {
        delegate?.cameraAnimatorDidStopRunning(self)
    }
}
