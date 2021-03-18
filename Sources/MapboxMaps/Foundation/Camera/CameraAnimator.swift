import UIKit

// MARK: CameraAnimator Class
public class CameraAnimator: NSObject {

    private let propertyAnimator: UIViewPropertyAnimator

    private var delegate: CameraAnimatorDelegate?

    internal var owner: AnimationOwnerProtocol

    internal init(delegate: CameraAnimatorDelegate,
                  propertyAnimator: UIViewPropertyAnimator,
                  owner: AnimationOwnerProtocol) {
        self.delegate = delegate
        self.propertyAnimator = propertyAnimator
        self.owner = owner
    }

    public var state: UIViewAnimatingState { return propertyAnimator.state }

    public var isRunning: Bool { return propertyAnimator.isRunning }

    public var isReversed: Bool { return propertyAnimator.isReversed }

    public var fractionComplete: CGFloat { return propertyAnimator.fractionComplete }

    public func startAnimation() {
        propertyAnimator.startAnimation()
    }

    public func startAnimation(afterDelay delay: TimeInterval) {
        propertyAnimator.startAnimation(afterDelay: delay)
    }

    public func pauseAnimation() {
        propertyAnimator.pauseAnimation()
    }

    public func stopAnimation() {
        propertyAnimator.stopAnimation(false)
        propertyAnimator.finishAnimation(at: .current)
        delegate?.animatorIsFinished(forAnimator: self)
    }

    public func addAnimations(_ animations: @escaping () -> Void, delayFactor: CGFloat) {
        propertyAnimator.addAnimations(animations, delayFactor: delayFactor)
    }

    public func addAnimations(_ animations: @escaping () -> Void) {
        propertyAnimator.addAnimations(animations)
    }

    public func addCompletion(_ completion: @escaping (UIViewAnimatingPosition) -> Void) {
        propertyAnimator.addCompletion({ animatingPosition in
            self.delegate?.schedulePendingCompletion(forAnimator: self, completion: completion, animatingPosition: animatingPosition)
        })
    }

    public func continueAnimation(withTimingParameters parameters: UITimingCurveProvider?, durationFactor: CGFloat) {
        propertyAnimator.continueAnimation(withTimingParameters: parameters, durationFactor: durationFactor)
    }
}

// MARK: CameraAnimatorDelegate Protocol
internal protocol CameraAnimatorDelegate {

    func schedulePendingCompletion(forAnimator animator: CameraAnimator, completion: @escaping (UIViewAnimatingPosition) -> Void, animatingPosition: UIViewAnimatingPosition)

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
