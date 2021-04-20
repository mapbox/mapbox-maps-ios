import UIKit
import CoreLocation

public typealias CameraAnimation = (inout CameraTransition) -> Void

// MARK: CameraAnimator Class
public class CameraAnimator: NSObject {
    
    /// Instance of the property animator that will run animations.
    private var propertyAnimator: UIViewPropertyAnimator

    /// Delegate that conforms to `CameraAnimatorDelegate`.
    private weak var delegate: CameraAnimatorDelegate?

    /// The ID of the owner of this `CameraAnimator`.
    internal var owner: AnimationOwner

    /// The `CameraView` owned by this animator
    internal var cameraView: CameraView
    
    /// Represents the animation that this animator is attempting to execute
    internal var animation: CameraAnimation?
    
    /// Defines the transition that will occur to the `CameraOptions` of the renderer due to this animator
    internal var transition: CameraTransition?

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
    public var fractionComplete: Double {
        get { return Double(propertyAnimator.fractionComplete) }
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

        // Set up the short lived camera view
        self.cameraView = cameraView
        delegate.addViewToViewHeirarchy(cameraView)
    }

    deinit {
        propertyAnimator.stopAnimation(false)
        propertyAnimator.finishAnimation(at: .current)
        cameraView.removeFromSuperview()
    }

    // MARK: Functions

    /// Starts the animation if this animator is in `inactive` state. Also used to resume a "paused" animation.
    public func startAnimation() {
    
        if self.state != .active {
            
            guard let delegate = delegate else {
                fatalError("CameraAnimator delegate cannot be nil when starting an animation")
            }
            
            guard let animation = animation else {
                fatalError("Animation cannot be nil when starting an animation")
            }
                
            var cameraTransition = CameraTransition(with: delegate.camera, initialAnchor: delegate.anchorAfterPadding())
            animation(&cameraTransition)
            
            propertyAnimator.addAnimations { [weak self] in
                guard let self = self else { return }
                self.cameraView.syncLayer(to: cameraTransition.toCameraOptions) // Set up the "to" values for the interpolation
            }
    
            cameraView.syncLayer(to: cameraTransition.fromCameraOptions) // Set up the "from" values for the interpoloation
            transition = cameraTransition // Store the mutated camera transition
        }
       
        propertyAnimator.startAnimation()
    }
    
    /// Starts the animation after a delay
    /// - Parameter delay: Delay (in seconds) after which the animation should start
    public func startAnimation(afterDelay delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self else { return }
            self.startAnimation()
        }
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
    internal func addAnimations(_ animations: @escaping CameraAnimation) {
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
            self.transition = nil // Clear out the set maintaining the properties being animated by this animator -- since the animation is complete if we are here.
            delegate.schedulePendingCompletion(forAnimator: self, completion: completion, animatingPosition: animationPosition)
        }
    }

    /// Continue the animation with a timing parameter (`UITimingCurveProvider`) and duration factor (`CGFloat`).
    public func continueAnimation(withTimingParameters parameters: UITimingCurveProvider?, durationFactor: Double) {
        propertyAnimator.continueAnimation(withTimingParameters: parameters, durationFactor: CGFloat(durationFactor))
    }

    internal func update() {

        // Only call jumpTo if this animator is currently "active" and there are known changes to animate.
        guard propertyAnimator.state == .active,
              let transition = transition,
              let delegate = delegate else {
            return
        }

        let cameraOptions = CameraOptions()
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
