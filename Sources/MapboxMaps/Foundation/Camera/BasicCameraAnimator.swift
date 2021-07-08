import UIKit
import CoreLocation

// MARK: CameraAnimator Class
public class BasicCameraAnimator: NSObject, CameraAnimator, CameraAnimatorInterface {
    private enum InternalState: Equatable {
        case initial
        case inProgress(CameraTransition)
        case final
    }

    /// Instance of the property animator that will run animations.
    private let propertyAnimator: UIViewPropertyAnimator

    /// The ID of the owner of this `CameraAnimator`.
    private let owner: AnimationOwner

    /// The `CameraView` owned by this animator
    private let cameraView: CameraView

    private let mapboxMap: CameraAnimatorMapboxMap

    /// Represents the animation that this animator is attempting to execute
    private var animation: ((inout CameraTransition) -> Void)?

    private var completions = [AnimationCompletion]()

    /// Defines the transition that will occur to the `CameraOptions` of the renderer due to this animator
    public var transition: CameraTransition? {
        switch internalState {
        case let .inProgress(transition):
            return transition
        case .initial, .final:
            return nil
        }
    }

    /// A timer used to delay the start of an animation
    private var delayedAnimationTimer: Timer?

    /// The state from of the animator.
    public var state: UIViewAnimatingState { propertyAnimator.state }

    private var internalState = InternalState.initial

    /// Boolean that represents if the animation is running or not.
    public var isRunning: Bool { propertyAnimator.isRunning }

    /// Boolean that represents if the animation is running normally or in reverse.
    public var isReversed: Bool { propertyAnimator.isReversed }

    /// A Boolean value that indicates whether a completed animation remains in the active state.
    public var pausesOnCompletion: Bool {
        get { propertyAnimator.pausesOnCompletion }
        set { propertyAnimator.pausesOnCompletion = newValue }
    }

    /// Value that represents what percentage of the animation has been completed.
    public var fractionComplete: Double {
        get { Double(propertyAnimator.fractionComplete) }
        set { propertyAnimator.fractionComplete = CGFloat(newValue) }
    }

    // MARK: Initializer
    internal init(propertyAnimator: UIViewPropertyAnimator,
                  owner: AnimationOwner,
                  mapboxMap: CameraAnimatorMapboxMap,
                  cameraView: CameraView) {
        self.propertyAnimator = propertyAnimator
        self.owner = owner
        self.mapboxMap = mapboxMap
        self.cameraView = cameraView
    }

    deinit {
        propertyAnimator.stopAnimation(true)
        cameraView.removeFromSuperview()
        delayedAnimationTimer?.invalidate()
    }

    /// Starts the animation if this animator is in `inactive` state. Also used to resume a "paused" animation.
    public func startAnimation() {
        switch internalState {
        case .initial:
            createTransition()
            propertyAnimator.startAnimation()
        case .inProgress:
            propertyAnimator.startAnimation()
        case .final:
            fatalError("Attempt to restart an animation that has already completed.")
        }
    }

    /// Starts the animation after a delay
    /// - Parameter delay: Delay (in seconds) after which the animation should start
    public func startAnimation(afterDelay delay: TimeInterval) {
        delayedAnimationTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [unowned self] (_) in
            startAnimation()
        }
    }

    /// Pauses the animation.
    public func pauseAnimation() {
        switch internalState {
        case .initial:
            createTransition()
            propertyAnimator.pauseAnimation()
        case .inProgress:
            propertyAnimator.pauseAnimation()
        case .final:
            fatalError("Attempt to pause an animation that has already completed.")
        }
    }

    /// Stops the animation.
    public func stopAnimation() {
        switch internalState {
        case .initial:
            fatalError("Attempt to stop an animation that has not started.")
        case .inProgress:
            propertyAnimator.stopAnimation(false)
            propertyAnimator.finishAnimation(at: .current)
        case .final:
            // Already stopped, so do nothing
            break
        }
    }

    /// Add animations block to the animator.
    internal func addAnimations(_ animations: @escaping (inout CameraTransition) -> Void) {
        precondition(animation == nil, "\(#function) should only be called once.")
        animation = animations
    }

    /// Add a completion block to the animator. 
    public func addCompletion(_ completion: @escaping AnimationCompletion) {
        precondition(internalState != .final, "Attempt to add a completion block to an animation that has already completed.")
        completions.append(completion)
    }

    /// Continue the animation with a timing parameter (`UITimingCurveProvider`) and duration factor (`CGFloat`).
    public func continueAnimation(withTimingParameters parameters: UITimingCurveProvider?, durationFactor: Double) {
        switch internalState {
        case .initial:
            fatalError("Attempt to continue an animation that has not started.")
        case .inProgress:
            propertyAnimator.continueAnimation(withTimingParameters: parameters, durationFactor: CGFloat(durationFactor))
        case .final:
            precondition(internalState != .final, "Attempt to continue an animation that has already completed.")
        }
    }

    func update() {
        switch internalState {
        case .initial, .final:
            return
        case let .inProgress(transition):
            // The animator has been started or paused, so get the interpolated value. This may be nil if
            // the animations haven't yet propagated into the CameraView's presentation tree.
            if let presentationCameraOptions = cameraView.presentationCameraOptions {
                mapboxMap.setCamera(
                    to: cameraOptions(
                        with: transition,
                        cameraViewCameraOptions: presentationCameraOptions))
            }
        }
    }

    // The CameraOptions returned by CameraView always includes non-nil values for each field.
    // This method creates returns a CameraOptions that has nil for the value of each field that
    // has a nil toValue in `transition` and has the non-nil value from
    // `cameraViewCameraOptions` for each field that has a non-nil toValue in `transition`.
    private func cameraOptions(with transition: CameraTransition, cameraViewCameraOptions: CameraOptions) -> CameraOptions {
        var cameraOptions = CameraOptions()

        if transition.center.toValue != nil {
            cameraOptions.center = cameraViewCameraOptions.center?.wrap() // Wraps to [-180, +180]
        }

        if transition.bearing.toValue != nil {
            cameraOptions.bearing = cameraViewCameraOptions.bearing
        }

        if transition.anchor.toValue != nil {
            cameraOptions.anchor = cameraViewCameraOptions.anchor
        }

        if transition.padding.toValue != nil {
            cameraOptions.padding = cameraViewCameraOptions.padding
        }

        if transition.zoom.toValue != nil {
            cameraOptions.zoom = cameraViewCameraOptions.zoom
        }

        if transition.pitch.toValue != nil {
            cameraOptions.pitch = cameraViewCameraOptions.pitch
        }

        return cameraOptions
    }

    private func createTransition() {
        precondition(internalState == .initial, "createTransition must only be called when BasicCameraAnimator is in its initial state.")

        guard let animation = animation else {
            fatalError("Animation cannot be nil when starting an animation")
        }

        var transition = CameraTransition(cameraState: mapboxMap.cameraState, initialAnchor: mapboxMap.anchor)
        animation(&transition)

        propertyAnimator.addAnimations { [weak cameraView] in
            guard let cameraView = cameraView else { return }
            cameraView.syncLayer(to: transition.toCameraOptions) // Set up the "to" values for the interpolation
        }

        propertyAnimator.addCompletion { [weak self] (animatingPosition) in
            guard let self = self else { return }
            self.internalState = .final
            let finalCamera = self.cameraOptions(with: transition, cameraViewCameraOptions: self.cameraView.cameraOptions)
            self.mapboxMap.setCamera(to: finalCamera)
            for completion in self.completions {
                completion(animatingPosition)
            }
            self.completions.removeAll()
        }

        cameraView.syncLayer(to: transition.fromCameraOptions) // Set up the "from" values for the interpoloation
        internalState = .inProgress(transition) // Store the mutated camera transition
    }

    // MARK: Cancelable

    public func cancel() {
        stopAnimation()
    }
}
