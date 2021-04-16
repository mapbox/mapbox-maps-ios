import UIKit
import CoreLocation

// MARK: CameraAnimator Class
public class CameraAnimator: NSObject {

    // MARK: Stored Properties

    /// Instance of the property animator that will run animations.
    private var propertyAnimator: UIViewPropertyAnimator

    /// Delegate that conforms to `CameraAnimatorDelegate`.
    private weak var delegate: CameraAnimatorDelegate?

    /// The ID of the owner of this `CameraAnimator`.
    internal var owner: AnimationOwner

    /// The `CameraView` owned by this animator
    internal var cameraView: CameraView

    /// The set of properties being animated by this renderer
    internal var propertiesBeingAnimated: Set<AnimatableCameraProperty>?

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
    public var fractionComplete: Double {
        get { return Double(propertyAnimator.fractionComplete) }
        set { propertyAnimator.fractionComplete = CGFloat(newValue) }
    }

    // MARK: Initializer
    internal init(delegate: CameraAnimatorDelegate,
                  propertyAnimator: UIViewPropertyAnimator,
                  owner: AnimationOwner) {
        self.delegate = delegate
        self.propertyAnimator = propertyAnimator
        self.owner = owner

        // Set up the short lived camera view
        cameraView = CameraView()
        delegate.addViewToViewHeirarchy(cameraView)
    }

    deinit {
        propertyAnimator.stopAnimation(false)
        propertyAnimator.finishAnimation(at: .current)
        cameraView.removeFromSuperview()
    }

    // MARK: Functions

    /// Starts the animation.
    public func startAnimation() {

        guard let renderedCamera = delegate?.camera else {
            fatalError("Rendered camera options cannot be nil when starting an animation")
        }

        cameraView.syncLayer(to: renderedCamera) // Set up the "from" values for the interpoloation
        propertyAnimator.startAnimation()
    }

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

    /// Add animations block to the animator with a `delayFactor`.
    public func addAnimations(_ animations: @escaping (inout CameraOptions) -> Void, delayFactor: Double) {
        let wrappedAnimations = wrapAnimationsBlock(animations)
        propertyAnimator.addAnimations(wrappedAnimations,
                                       delayFactor: CGFloat(delayFactor))
    }

    /// Add animations block to the animator.
    public func addAnimations(_ animations: @escaping (inout CameraOptions) -> Void) {
        let wrappedAnimations = wrapAnimationsBlock(animations)
        propertyAnimator.addAnimations(wrappedAnimations)
    }

    internal func wrapAnimationsBlock(_ userProvidedAnimation: @escaping (inout CameraOptions) -> Void) -> () -> Void {

        guard let delegate = delegate else {
            fatalError("Delegate MUST not be nil when adding animations")
        }

        let renderedCameraOptions = delegate.camera

        return { [weak self] in
            guard let self = self else { return }

            var cameraOptions = CameraOptions(with: renderedCameraOptions)
            userProvidedAnimation(&cameraOptions) // The `userProvidedAnimation` block will mutate the "rendered" camera options and provide the "to" values of the animation

            // To consider: Should we throw a FatalError() if we detect that multiple CameraAnimators are manipulating the same camera property??
            self.propertiesBeingAnimated = AnimatableCameraProperty.diffChangesToCameraOptions(from: renderedCameraOptions,
                                                                    to: cameraOptions)
            self.cameraView.syncLayer(to: cameraOptions)
        }
    }

    /// Add a completion block to the animator. 
    public func addCompletion(_ completion: @escaping AnimationCompletion) {
        propertyAnimator.addCompletion({ [weak self] animatingPosition in
            guard let self = self else { return }
            self.delegate?.schedulePendingCompletion(forAnimator: self, completion: completion, animatingPosition: animatingPosition)
        })
    }

    /// Continue the animation with a timing parameter (`UITimingCurveProvider`) and duration factor (`CGFloat`).
    public func continueAnimation(withTimingParameters parameters: UITimingCurveProvider?, durationFactor: Double) {
        propertyAnimator.continueAnimation(withTimingParameters: parameters, durationFactor: CGFloat(durationFactor))
    }

    internal func update() {

        // Only call jumpTo if this animator is currently "active" and there are known changes to animate.
        guard propertyAnimator.state == .active,
              let propertiesBeingAnimated = propertiesBeingAnimated,
              propertiesBeingAnimated.count > 0, let delegate = delegate else {
            return
        }

        let cameraOptions = CameraOptions()
        let interpolatedCamera = cameraView.localCamera
        let propertiesBeingAnimatedNames = propertiesBeingAnimated.map { $0.name }

        if propertiesBeingAnimatedNames.contains("center") {
            cameraOptions.center = interpolatedCamera.center?.wrap()
        }

        if propertiesBeingAnimatedNames.contains("bearing") {
            cameraOptions.bearing = interpolatedCamera.bearing
        }

        // To consider: should we flag here if anchor and center is being animated??
        if propertiesBeingAnimatedNames.contains("anchor") {
            cameraOptions.anchor = interpolatedCamera.anchor
        }

        if propertiesBeingAnimatedNames.contains("padding") {
            cameraOptions.padding = interpolatedCamera.padding
        }

        if propertiesBeingAnimatedNames.contains("zoom") {
            cameraOptions.zoom = interpolatedCamera.zoom
        }

        if propertiesBeingAnimatedNames.contains("pitch") {
            cameraOptions.pitch = interpolatedCamera.pitch
        }

        delegate.jumpTo(camera: cameraOptions)
    }
}

fileprivate extension CameraOptions {

    func clampCenter() -> CameraOptions {
        return CameraOptions(center: self.center?.wrap(),
                             padding: self.padding,
                             anchor: self.anchor,
                             zoom: self.zoom,
                             bearing: self.bearing,
                             pitch: self.pitch)

    }
}
