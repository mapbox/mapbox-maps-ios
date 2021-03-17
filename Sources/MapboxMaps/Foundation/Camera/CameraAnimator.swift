import UIKit

// MARK: CameraAnimator Class
public class CameraAnimator : NSObject {

    internal let propertyAnimator: UIViewPropertyAnimator

    internal var delegate: CameraAnimatorDelegate?

    internal var owner: AnimationOwnerProtocol

    internal init(delegate: CameraAnimatorDelegate,
                  propertyAnimator: UIViewPropertyAnimator,
                  owner: AnimationOwnerProtocol) {
        self.delegate = delegate
        self.propertyAnimator = propertyAnimator
        self.owner = owner
    }

    public var state: UIViewAnimatingState {
        get {
            return propertyAnimator.state
        }
    }

    public var isRunning: Bool {
        get {
            return propertyAnimator.isRunning
        }
    }

    public var isReversed: Bool {
        get {
            return propertyAnimator.isReversed
        }
    }

    public var fractionComplete: CGFloat {
        get {
            return propertyAnimator.fractionComplete
        }
    }

    public func startAnimation() {
        propertyAnimator.startAnimation()
    }

    public func startAnimation(afterDelay delay: TimeInterval) {
        propertyAnimator.startAnimation(afterDelay: delay)
    }

    public func pauseAnimation() {
        propertyAnimator.pauseAnimation()
    }

    public func stopAnimation(_ withoutFinishing: Bool) {
        propertyAnimator.stopAnimation(withoutFinishing)
    }

    public func addAnimations(_ animations: @escaping () -> Void, delayFactor: CGFloat) {
        propertyAnimator.addAnimations(animations, delayFactor: delayFactor)
    }

    public func addAnimations(_ animations: @escaping () -> Void) {
        propertyAnimator.addAnimations(animations)
    }

    public func addCompletion(_ completion: @escaping (UIViewAnimatingPosition) -> Void) {
        propertyAnimator.addCompletion(completion)
    }

    public func continueAnimation(withTimingParameters parameters: UITimingCurveProvider?, durationFactor: CGFloat) {
        propertyAnimator.continueAnimation(withTimingParameters: parameters, durationFactor: durationFactor)
    }
}

// MARK: CameraAnimatorDelegate Protocol
internal protocol CameraAnimatorDelegate {

    func schedulePendingCompletion(completion: @escaping () -> Void)

    func animatorIsFinished(animator: CameraAnimator)

}

// MARK: AnimationOwnerProtocol
protocol AnimationOwnerProtocol {
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
