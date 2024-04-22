import UIKit

internal protocol BasicCameraAnimatorProtocol: AnyObject {
    var owner: AnimationOwner { get }
    var animationType: AnimationType { get }
    var transition: CameraTransition? { get }
    var state: UIViewAnimatingState { get }
    var isRunning: Bool { get }
    var isReversed: Bool { get set }
    var pausesOnCompletion: Bool { get set }
    var fractionComplete: Double { get set }
    var onCameraAnimatorStatusChanged: Signal<CameraAnimatorStatus> { get }
    func startAnimation()
    func startAnimation(afterDelay delay: TimeInterval)
    func pauseAnimation()
    func stopAnimation()
    func addCompletion(_ completion: @escaping AnimationCompletion)
    func continueAnimation(withTimingParameters timingParameters: UITimingCurveProvider?,
                           durationFactor: Double)
    func update()
}

internal final class BasicCameraAnimatorImpl: BasicCameraAnimatorProtocol {
    typealias Animation = (inout CameraTransition) -> Void

    private enum InternalState: Equatable {
        case initial
        case running(CameraTransition)
        case paused(CameraTransition)
        case final(UIViewAnimatingPosition)
    }

    /// Instance of the property animator that will run animations.
    private let propertyAnimator: UIViewPropertyAnimator

    /// The animator's owner.
    internal let owner: AnimationOwner

    /// Type of the embeded animation
    internal var animationType: AnimationType

    /// The `CameraView` owned by this animator
    private let cameraView: CameraView

    private let mapboxMap: MapboxMapProtocol

    private let mainQueue: MainQueueProtocol

    /// Represents the animation that this animator is attempting to execute
    private let animation: Animation

    private var completions = [AnimationCompletion]()

    /// Defines the transition that will occur to the `CameraOptions` of the renderer due to this animator
    internal var transition: CameraTransition? {
        switch internalState {
        case let .running(transition), let .paused(transition):
            return transition
        case .initial, .final:
            return nil
        }
    }

    private let cameraAnimatorStatusSignal = SignalSubject<CameraAnimatorStatus>()
    var onCameraAnimatorStatusChanged: Signal<CameraAnimatorStatus> { cameraAnimatorStatusSignal.signal }

    /// The state from of the animator.
    internal var state: UIViewAnimatingState { propertyAnimator.state }

    private var internalState = InternalState.initial {
        didSet {
            switch (oldValue, internalState) {
            case (.initial, .running), (.paused, .running):
                cameraAnimatorStatusSignal.send(.started)
            case (.running, .paused):
                cameraAnimatorStatusSignal.send(.paused)
            case (.running, .final(let position)), (.paused, .final(let position)):
                let isCancelled = position != .end
                cameraAnimatorStatusSignal.send(.stopped(reason: isCancelled ? .cancelled : .finished))
            default:
                // this matches cases where…
                // * oldValue and internalState are the same
                // * initial transitions to paused
                // * initial transitions to final
                // * the transition is invalid…
                //     * running/paused/final --> initial
                //     * final --> running/paused
                break
            }
        }
    }

    /// Boolean that represents if the animation is running or not.
    internal var isRunning: Bool { propertyAnimator.isRunning }

    /// Boolean that represents if the animation is running normally or in reverse.
    internal var isReversed: Bool {
        get { propertyAnimator.isReversed }
        set { propertyAnimator.isReversed = newValue }
    }

    /// A Boolean value that indicates whether a completed animation remains in the active state.
    internal var pausesOnCompletion: Bool {
        get { propertyAnimator.pausesOnCompletion }
        set { propertyAnimator.pausesOnCompletion = newValue }
    }

    /// Value that represents what percentage of the animation has been completed.
    internal var fractionComplete: Double {
        get { Double(propertyAnimator.fractionComplete) }
        set { propertyAnimator.fractionComplete = CGFloat(newValue) }
    }

    // MARK: Initializer
    internal init(propertyAnimator: UIViewPropertyAnimator,
                  owner: AnimationOwner,
                  type: AnimationType = .unspecified,
                  mapboxMap: MapboxMapProtocol,
                  mainQueue: MainQueueProtocol,
                  cameraView: CameraView,
                  animation: @escaping Animation) {
        self.propertyAnimator = propertyAnimator
        self.owner = owner
        self.animationType = type
        self.mapboxMap = mapboxMap
        self.mainQueue = mainQueue
        self.cameraView = cameraView
        self.animation = animation
    }

    deinit {
        propertyAnimator.stopAnimation(true)
        cameraView.removeFromSuperview()
    }

    /// See ``BasicCameraAnimator/startAnimation()``
    internal func startAnimation() {
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
            // animators cannot be restarted
            break
        }
    }

    /// See ``BasicCameraAnimator/startAnimation(afterDelay:)``
    internal func startAnimation(afterDelay delay: TimeInterval) {
        switch internalState {
        case .initial:
            internalState = .running(makeTransition())
            propertyAnimator.startAnimation(afterDelay: delay)
        case .running:
            // already running; do nothing
            break
        case .paused:
            assertionFailure("A paused animator cannot be started with a delay.")
        case .final:
            // animators cannot be restarted
            break
        }
    }

    /// See ``BasicCameraAnimator/pauseAnimation()``
    internal func pauseAnimation() {
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
            // already completed; do nothing
            break
        }
    }

    /// Stops the animation.
    internal func stopAnimation() {
        switch internalState {
        case .initial:
            internalState = .final(.current)
            for completion in completions {
                completion(.current)
            }
            completions.removeAll()
        case .running, .paused:
            propertyAnimator.stopAnimation(false)
            // this invokes the completion block which updates internalState
            propertyAnimator.finishAnimation(at: .current)
        case .final:
            // Already stopped, so do nothing
            break
        }
    }

    /// Add a completion block to the animator.
    internal func addCompletion(_ completion: @escaping AnimationCompletion) {
        switch internalState {
        case .initial, .running, .paused:
            completions.append(completion)
        case .final(let position):
            mainQueue.async {
                completion(position)
            }
        }
    }

    /// Continue the animation with a timing parameter (`UITimingCurveProvider`) and duration factor (`CGFloat`).
    internal func continueAnimation(withTimingParameters parameters: UITimingCurveProvider?, durationFactor: Double) {
        switch internalState {
        case .initial:
            assertionFailure("Can't continue an animation that has not started.")
        case .running:
            assertionFailure("Can't continue an animation that is already running.")
        case let .paused(transition):
            internalState = .running(transition)
            propertyAnimator.continueAnimation(withTimingParameters: parameters, durationFactor: CGFloat(durationFactor))
        case .final:
            assertionFailure("Can't continue an animation that has already completed.")
        }
    }

    internal func update() {
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
        assert(internalState == .initial, "createTransition must only be called when BasicCameraAnimator is in its initial state.")

        var transition = CameraTransition(cameraState: mapboxMap.cameraState, initialAnchor: mapboxMap.anchor)
        animation(&transition)

        propertyAnimator.addAnimations { [weak cameraView] in
            guard let cameraView = cameraView else { return }
            cameraView.syncLayer(to: transition.toCameraOptions) // Set up the "to" values for the interpolation
        }

        propertyAnimator.addCompletion { [weak self] (animatingPosition) in
            guard let self = self else { return }
            self.internalState = .final(animatingPosition)
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
            // set unique non-animatable value to detect same-transaction animations
            cameraView.layer.needsDisplayOnBoundsChange.toggle()
            cameraView.syncLayer(to: transition.fromCameraOptions) // Set up the "from" values for the interpoloation
        }
        return transition
    }
}
