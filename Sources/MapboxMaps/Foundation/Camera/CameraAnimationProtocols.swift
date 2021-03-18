import UIKit

// MARK: Typealias
public typealias AnimationCompletion = (UIViewAnimatingPosition) -> Void

// MARK: CameraAnimatorDelegate Protocol
internal protocol CameraAnimatorDelegate {

    /**
    This delegate function notifies that the completion block needs to be scheduled

    - Parameter animator: The current animator that this delegate function is being called from
    - Parameter completion: The completion block that needs to be scheduled
    - Parameter animatingPosition  The position of the animation needed for the closure
    */
    func schedulePendingCompletion(forAnimator animator: CameraAnimator,
                                   completion: @escaping AnimationCompletion,
                                   animatingPosition: UIViewAnimatingPosition)

    /**
    This delegate function notifies that the animation is finished

    - Parameter animator: The current animator that this delegate function is being called from
    */
    func animatorIsFinished(forAnimator animator: CameraAnimator)

}

// MARK: AnimationOwnerProtocol
internal protocol AnimationOwnerProtocol {
    var id: String { get }
}

// MARK: AnimationOwner Enum
public enum AnimationOwner: AnimationOwnerProtocol {
    case gestures
    case unspecified
    case custom(id: String)

    var id: String {
        switch self {
        case .gestures:
            return "com.mapbox.maps.gestures"
        case .unspecified:
            return "com.mapbox.maps.unspecified"
        case .custom(id: let  id):
            return id
        }
    }
}
