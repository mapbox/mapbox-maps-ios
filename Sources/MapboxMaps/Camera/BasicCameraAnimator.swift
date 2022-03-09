import UIKit
import CoreLocation

// MARK: CameraAnimator Class
public class BasicCameraAnimator: NSObject, CameraAnimator, CameraAnimatorProtocol {
    private enum InternalState: Equatable {
        case initial
        case running(CameraTransition)
        case paused(CameraTransition)
        case final
    }

    /// Instance of the property animator that will run animations.
    private let propertyAnimator: UIViewPropertyAnimator

    /// The ID of the owner of this `CameraAnimator`.
    public let owner: AnimationOwner

    /// The `CameraView` owned by this animator
    private let cameraView: CameraView

    private let mapboxMap: MapboxMapProtocol

    internal weak var delegate: CameraAnimatorDelegate?

    /// Represents the animation that this animator is attempting to execute
    private var animation: ((inout CameraTransition) -> Void)?

    private var completions = [AnimationCompletion]()

    /// Defines the transition that will occur to the `CameraOptions` of the renderer due to this animator
    public var transition: CameraTransition? {
        switch internalState {
        case let .running(transition), let .paused(transition):
            return transition
        case .initial, .final:
            return nil
        }
    }

    /// The state from of the animator.
    public var state: UIViewAnimatingState { propertyAnimator.state }

    private var internalState = InternalState.initial {
        didSet {
            switch (oldValue, internalState) {
            case (.initial, .running), (.paused, .running):
                delegate?.cameraAnimatorDidStartRunning(self)
            case (.running, .paused), (.running, .final):
                delegate?.cameraAnimatorDidStopRunning(self)
            default:
                // this matches cases where…
                // * oldValue and internalState are the same
                // * initial transitions to paused
                // * paused transitions to final
                // * the transition is invalid…
                //     * initial --> final
                //     * running/paused/final --> initial
                //     * final --> running/paused
                break
            }
        }
    }

    /// Boolean that represents if the animation is running or not.
    public var isRunning: Bool { propertyAnimator.isRunning }

    /// Boolean that represents if the animation is running normally or in reverse.
    public var isReversed: Bool {
        get { propertyAnimator.isReversed }
        set { propertyAnimator.isReversed = newValue }
    }

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
                  mapboxMap: MapboxMapProtocol,
                  cameraView: CameraView) {
        self.propertyAnimator = propertyAnimator
        self.owner = owner
        self.mapboxMap = mapboxMap
        self.cameraView = cameraView
    }

    deinit {
        propertyAnimator.stopAnimation(true)
        cameraView.removeFromSuperview()
    }

    /// Starts the animation if this animator is in `inactive` state. Also used to resume a "paused" animation.
    public func startAnimation() {
        switch internalState {
        case .initial:
            internalState = .running(makeTransition())
            propertyAnimator.startAnimation()
        case .running:
            // already running; do nothing
            break
        case let .paused(transition):
            internalState = .running(transition)
            propertyAnimator.startAnimation()
        case .final:
            fatalError("Attempt to restart an animation that has already completed.")
        }
    }

    /// Starts the animation after a delay. This cannot be called on a paused animation.
    /// If animations are cancelled before the end of the delay, it will also be cancelled.
    /// - Parameter delay: Delay (in seconds) after which the animation should start
    public func startAnimation(afterDelay delay: TimeInterval) {
        if internalState != .initial {
            fatalError("startAnimation(afterDelay:) cannot be called on already-delayed, paused, running, or completed animators.")
        }

        internalState = .running(makeTransition())
        propertyAnimator.startAnimation(afterDelay: delay)
    }

    /// Pauses the animation.
    public func pauseAnimation() {
        switch internalState {
        case .initial:
            internalState = .paused(makeTransition())
            propertyAnimator.pauseAnimation()
        case let .running(transition):
            internalState = .paused(transition)
            propertyAnimator.pauseAnimation()
        case .paused:
            // already paused; do nothing
            break
        case .final:
            fatalError("Attempt to pause an animation that has already completed.")
        }
    }

    /// Stops the animation.
    public func stopAnimation() {
        switch internalState {
        case .initial:
            fatalError("Attempt to stop an animation that has not started.")
        case .running, .paused:
            propertyAnimator.stopAnimation(false)
            // this invokes the completion block which updates internalState
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
        case .running:
            fatalError("Attempt to continue an animation that is already running.")
        case let .paused(transition):
            internalState = .running(transition)
            propertyAnimator.continueAnimation(withTimingParameters: parameters, durationFactor: CGFloat(durationFactor))
        case .final:
            fatalError("Attempt to continue an animation that has already completed.")
        }
    }

    func update() {
        switch internalState {
        case .initial, .paused, .final:
            return
        case let .running(transition):
            // The animator is running, so get the interpolated value. This may be nil if
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

    private func makeTransition() -> CameraTransition {
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
            // if the animation was stopped/canceled before finishing,
            // do not update the camera again.
            if animatingPosition != .current {
                let finalCamera = self.cameraOptions(with: transition, cameraViewCameraOptions: self.cameraView.cameraOptions)
                self.mapboxMap.setCamera(to: finalCamera)
            }
            for completion in self.completions {
                completion(animatingPosition)
            }
            self.completions.removeAll()
        }

        UIView.performWithoutAnimation {
            cameraView.syncLayer(to: transition.fromCameraOptions) // Set up the "from" values for the interpoloation
        }
        return transition
    }

    // MARK: Cancelable

    public func cancel() {
        stopAnimation()
    }
}
