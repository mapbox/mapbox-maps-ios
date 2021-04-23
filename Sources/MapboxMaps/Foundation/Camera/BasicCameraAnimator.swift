import UIKit
import CoreLocation

@objc public protocol CameraAnimator: AnyObject {

    /// Stops the animation in its tracks and calls any provided completion
    func stopAnimation()

    /// The current state of the animation
    var state: UIViewAnimatingState { get }
}

/// Internal-facing protocol to represent camera animators
@objc internal protocol CameraAnimatorInterface: AnyObject {
    func update()

    func stopAnimation()

    var state: UIViewAnimatingState { get }
}

// MARK: CameraAnimator Class
public class BasicCameraAnimator: NSObject, CameraAnimator, CameraAnimatorInterface {

    /// Instance of the property animator that will run animations.
    internal private(set) var propertyAnimator: UIViewPropertyAnimator

    /// Delegate that conforms to `CameraAnimatorDelegate`.
    internal private(set) weak var delegate: CameraAnimatorDelegate?

    /// The ID of the owner of this `CameraAnimator`.
    public private(set) var owner: AnimationOwner

    /// The `CameraView` owned by this animator
    internal private(set) var cameraView: CameraView

    /// Represents the animation that this animator is attempting to execute
    internal private(set) var animation: ((inout CameraTransition) -> Void)?

    /// Defines the transition that will occur to the `CameraOptions` of the renderer due to this animator
    public private(set) var transition: CameraTransition?

    /// A timer used to delay the start of an animation
    private var delayedAnimationTimer: Timer?

    /// The state from of the animator.
    public var state: UIViewAnimatingState { propertyAnimator.state }

    /// Boolean that represents if the animation is running or not.
    public var isRunning: Bool { propertyAnimator.isRunning }

    /// Boolean that represents if the animation is running normally or in reverse.
    public var isReversed: Bool { propertyAnimator.isReversed }

    /// A Boolean value that indicates whether a completed animation remains in the active state.
    public var pausesOnCompletion: Bool {
        get { propertyAnimator.pausesOnCompletion}
        set { propertyAnimator.pausesOnCompletion = newValue }
    }

    /// Value that represents what percentage of the animation has been completed.
    public var fractionComplete: Double {
        get { Double(propertyAnimator.fractionComplete) }
        set { propertyAnimator.fractionComplete = CGFloat(newValue) }
    }

    // MARK: Initializer
    internal init(delegate: CameraAnimatorDelegate,
                  propertyAnimator: UIViewPropertyAnimator,
                  owner: AnimationOwner,
                  cameraView: CameraView = CameraView()) {
        self.delegate = delegate
        self.propertyAnimator = propertyAnimator
        self.owner = owner
        self.cameraView = cameraView
    }

    deinit {
        propertyAnimator.stopAnimation(false)
        propertyAnimator.finishAnimation(at: .current)
        cameraView.removeFromSuperview()
    }

    /// Starts the animation if this animator is in `inactive` state. Also used to resume a "paused" animation.
    public func startAnimation() {

        if self.state != .active {

            guard let delegate = delegate else {
                fatalError("CameraAnimator delegate cannot be nil when starting an animation")
            }

            guard let animation = animation else {
                fatalError("Animation cannot be nil when starting an animation")
            }

            // Set up the short lived camera view
            delegate.addViewToViewHeirarchy(cameraView)

            var cameraTransition = CameraTransition(with: delegate.camera, initialAnchor: delegate.anchorAfterPadding())
            animation(&cameraTransition)

            propertyAnimator.addAnimations { [weak cameraView] in
                guard let cameraView = cameraView else { return }
                cameraView.syncLayer(to: cameraTransition.toCameraOptions) // Set up the "to" values for the interpolation
            }

            cameraView.syncLayer(to: cameraTransition.fromCameraOptions) // Set up the "from" values for the interpoloation
            transition = cameraTransition // Store the mutated camera transition
        }

        propertyAnimator.startAnimation()
    }

    /// Starts the animation after a delay
    /// - Parameter delay: Delay (in seconds) after which the animation should start
    public func startAnimation(afterDelay delay: TimeInterval) {
        delayedAnimationTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: { [weak self] (timer) in
            guard let self = self else { return }
            self.startAnimation()
            timer.invalidate()
        })
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

    /// Add animations block to the animator.
    internal func addAnimations(_ animations: @escaping (inout CameraTransition) -> Void) {
        animation = animations
    }

    /// Add a completion block to the animator. 
    public func addCompletion(_ completion: @escaping AnimationCompletion) {
        let wrappedCompletion = wrapCompletion(completion)
        propertyAnimator.addCompletion(wrappedCompletion)
    }

    internal func wrapCompletion(_ completion: @escaping AnimationCompletion) -> (UIViewAnimatingPosition) -> Void {
        return { [weak self] animationPosition in
            guard let self = self, let delegate = self.delegate else { return }
            self.transition = nil // Clear out the transition being animated by this animator,
                                  // since the animation is complete if we are here.
            delegate.schedulePendingCompletion(forAnimator: self, completion: completion, animatingPosition: animationPosition)

            // Invalidate the delayed animation timer if it exists
            self.delayedAnimationTimer?.invalidate()
            self.delayedAnimationTimer = nil
        }
    }

    /// Continue the animation with a timing parameter (`UITimingCurveProvider`) and duration factor (`CGFloat`).
    public func continueAnimation(withTimingParameters parameters: UITimingCurveProvider?, durationFactor: Double) {
        propertyAnimator.continueAnimation(withTimingParameters: parameters, durationFactor: CGFloat(durationFactor))
    }

    public func update() {

        // Only call jumpTo if this animator is currently "active" and there are known changes to animate.
        guard propertyAnimator.state == .active,
              let transition = transition,
              let delegate = delegate else {
            return
        }

        var cameraOptions = CameraOptions()
        let interpolatedCamera = cameraView.localCamera

        if transition.center.toValue != nil {
            cameraOptions.center = interpolatedCamera.center?.wrap() // Wraps to [-180, +180]
        }

        if transition.bearing.toValue != nil {
            cameraOptions.bearing = interpolatedCamera.bearing
        }

        if transition.anchor.toValue != nil {
            cameraOptions.anchor = interpolatedCamera.anchor
        }

        if transition.padding.toValue != nil {
            cameraOptions.padding = interpolatedCamera.padding
        }

        if transition.zoom.toValue != nil {
            cameraOptions.zoom = interpolatedCamera.zoom
        }

        if transition.pitch.toValue != nil {
            cameraOptions.pitch = interpolatedCamera.pitch
        }

        delegate.jumpTo(camera: cameraOptions)
    }
}
