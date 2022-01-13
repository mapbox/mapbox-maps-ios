#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public protocol CameraAnimator: Cancelable {

    /// Stops the animation in its tracks and calls any provided completion
    func stopAnimation()

    /// The current state of the animation
    var state: UIViewAnimatingState { get }
}

/// Internal-facing protocol to represent camera animators
internal protocol CameraAnimatorInterface: CameraAnimator {
    func update()
}

internal protocol CameraAnimatorDelegate: AnyObject {
    func cameraAnimatorDidStartRunning(_ cameraAnimator: CameraAnimator)
    func cameraAnimatorDidStopRunning(_ cameraAnimator: CameraAnimator)
}
