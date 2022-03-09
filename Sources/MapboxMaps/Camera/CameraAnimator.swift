import UIKit

public protocol CameraAnimator: Cancelable {

    /// Stops the animation in its tracks and calls any provided completion
    func stopAnimation()

    /// The current state of the animation
    var state: UIViewAnimatingState { get }
}

/// Internal-facing protocol to represent camera animators
internal protocol CameraAnimatorProtocol: CameraAnimator {
    /// the animation's owner
    var owner: AnimationOwner { get }

    /// implementations must use a weak reference
    var delegate: CameraAnimatorDelegate? { get set }

    /// adds a completion block to the animator
    func addCompletion(_ completion: @escaping AnimationCompletion)

    /// starts the animation
    func startAnimation()

    /// Called at each display link to allow animators to update the camera
    func update()
}

internal protocol CameraAnimatorDelegate: AnyObject {
    func cameraAnimatorDidStartRunning(_ cameraAnimator: CameraAnimatorProtocol)
    func cameraAnimatorDidStopRunning(_ cameraAnimator: CameraAnimatorProtocol)
}
