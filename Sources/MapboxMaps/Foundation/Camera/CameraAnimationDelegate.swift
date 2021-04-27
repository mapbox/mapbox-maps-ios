import UIKit

// MARK: Typealias
public typealias AnimationCompletion = (UIViewAnimatingPosition) -> Void

// MARK: CameraAnimatorDelegate Protocol
internal protocol CameraAnimatorDelegate: class {

    /// The current camera of the map
    var camera: CameraOptions { get }

    /// Adds the view to the MapView's subviews
    func addViewToViewHeirarchy(_ view: CameraView)

    /// Calculates the anchor after taking padding into consideration
    func anchorAfterPadding() -> CGPoint

    /// This delegate function notifies that the completion block needs to be scheduled on the next tick of the displaylink
    /// - Parameters:
    ///   - animator: The current animator that this delegate function is being called from
    ///   - completion: The completion block that needs to be scheduled
    ///   - animatingPosition: The position of the animation needed for the closure
    func schedulePendingCompletion(forAnimator animator: CameraAnimator,
                                   completion: @escaping AnimationCompletion,
                                   animatingPosition: UIViewAnimatingPosition)
}
