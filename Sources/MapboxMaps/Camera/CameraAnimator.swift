import UIKit

public protocol CameraAnimator: Cancelable {
    /// The animation's owner.
    var owner: AnimationOwner { get }

    /// Stops the animation and calls any provided completion. Does nothing if the animator has already
    /// completed.
    func stopAnimation()

    /// The current state of the animation.
    var state: UIViewAnimatingState { get }
}

/// Internal-facing protocol to represent camera animators
internal protocol CameraAnimatorProtocol: CameraAnimator {
    /// Type of the embeded animation
    var animationType: AnimationType { get }

    /// Adds a completion block to the animator. If the animator is already complete,
    /// implementations should invoke the completion block asynchronously with the
    /// same `UIViewAnimatingPosition` value as when it completed.
    func addCompletion(_ completion: @escaping AnimationCompletion)

    /// Starts the animation. Does nothing if the animator has already completed.
    func startAnimation()

    /// Called at each display link to allow animators to update the camera.
    func update()

    var onCameraAnimatorStatusChanged: Signal<CameraAnimatorStatus> { get }
}
