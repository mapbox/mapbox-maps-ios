import UIKit

// MARK: Typealias
public typealias AnimationCompletion = (UIViewAnimatingPosition) -> Void

// MARK: CameraAnimatorDelegate Protocol
internal protocol CameraAnimatorDelegate: class {
    
    var camera: CameraOptions { get }
    
    func jumpTo(camera: CameraOptions)
    
    func addToViewHeirarchy(view: CameraView)

    /**
    This delegate function notifies that the completion block needs to be scheduled

    - Parameter animator: The current animator that this delegate function is being called from
    - Parameter completion: The completion block that needs to be scheduled
    - Parameter animatingPosition  The position of the animation needed for the closure
    */
    func schedulePendingCompletion(forAnimator animator: CameraAnimator,
                                   completion: @escaping AnimationCompletion,
                                   animatingPosition: UIViewAnimatingPosition)
}
