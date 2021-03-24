import UIKit

// MARK: CameraAnimator Class
public class CameraAnimator: NSObject {

    // MARK: Stored Properties

    /// Instance of the property animator that will run animations.
    private let propertyAnimator: UIViewPropertyAnimator

    /// Delegate that conforms to `CameraAnimatorDelegate`.
    private weak var delegate: CameraAnimatorDelegate?

    /// The ID of the owner of this `CameraAnimator`.
    internal var owner: AnimationOwner

    // MARK: Computed Properties

    /// The state from of the animator.
    public var state: UIViewAnimatingState { return propertyAnimator.state }

    /// Boolean that represents if the animation is running or not.
    public var isRunning: Bool { return propertyAnimator.isRunning }

    /// Boolean that represents if the animation is running normally or in reverse.
    public var isReversed: Bool { return propertyAnimator.isReversed }

    /// A Boolean value that indicates whether a completed animation remains in the active state.
    public var pausesOnCompletion: Bool {
        get { return propertyAnimator.pausesOnCompletion}
        set { propertyAnimator.pausesOnCompletion = newValue }
    }

    /// Value that represents what percentage of the animation has been completed.
    public var fractionComplete: CGFloat {
        get { return propertyAnimator.fractionComplete }
        set { propertyAnimator.fractionComplete = newValue }
    }

    // MARK: Initializer
    internal init(delegate: CameraAnimatorDelegate,
                  propertyAnimator: UIViewPropertyAnimator,
                  owner: AnimationOwner) {
        self.delegate = delegate
        self.propertyAnimator = propertyAnimator
        self.owner = owner
    }

    // MARK: Functions

    /// Starts the animation.
    public func startAnimation() {
        propertyAnimator.startAnimation()
    }

    /// Starts the animation after a `delay` which is of type `TimeInterval`.
    public func startAnimation(afterDelay delay: TimeInterval) {
        propertyAnimator.startAnimation(afterDelay: delay)
    }

    /// Pauses the animation.
    public func pauseAnimation() {
        propertyAnimator.pauseAnimation()
    }

    /// Stops the animation.
    public func stopAnimation() {
        propertyAnimator.stopAnimation(false)
        propertyAnimator.finishAnimation(at: .current)
    }

    /// Add animations block to the animator with a `delayFactor`.
    public func addAnimations(_ animations: @escaping () -> Void, delayFactor: CGFloat) {
        // if this cameraAnimator is not in the list of CameraAnimators held by the `CameraManager` then add it to that list??
        propertyAnimator.addAnimations(animations, delayFactor: delayFactor)
    }

    /// Add animations block to the animator.
    public func addAnimations(_ animations: @escaping () -> Void) {
        propertyAnimator.addAnimations(animations)
    }

    /// Add a completion block to the animator. 
    public func addCompletion(_ completion: @escaping AnimationCompletion) {
        propertyAnimator.addCompletion({ animatingPosition in
            self.delegate?.schedulePendingCompletion(forAnimator: self, completion: completion, animatingPosition: animatingPosition)
        })
    }

    /// Continue the animation with a timing parameter (`UITimingCurveProvider`) and duration factor (`CGFloat`).
    public func continueAnimation(withTimingParameters parameters: UITimingCurveProvider?, durationFactor: CGFloat) {
        propertyAnimator.continueAnimation(withTimingParameters: parameters, durationFactor: durationFactor)
    }
}
