import UIKit
internal protocol ViewportManagerImplProtocol: AnyObject {
    var options: ViewportOptions { get set }

    var status: ViewportStatus { get }
    var safeAreaPadding: Signal<UIEdgeInsets?> { get }
    func addStatusObserver(_ observer: ViewportStatusObserver)
    func removeStatusObserver(_ observer: ViewportStatusObserver)

    func idle()
    func transition(to toState: ViewportState, transition: ViewportTransition?, completion: ((Bool) -> Void)?)

    var defaultTransition: ViewportTransition { get set }
}

// provides a structured approach to organizing
// camera management logic into states and transitions between them
//
// at any given time, the viewport is either:
//
//  - idle (only camera padding is updating from safe area (if configured))
//  - in a state (camera is being managed by a ViewportState)
//  - transitioning (camera is being managed by a ViewportTransition)
//
final class ViewportManagerImpl: ViewportManagerImplProtocol {

    var options: ViewportOptions {
        get {
            var opts = ViewportOptions(
                transitionsToIdleUponUserInteraction: anyTouchGestureRecognizer.isEnabled)
            opts.usesSafeAreaInsetsAsPadding = usesSafeAreaInsetsAsPadding.value
            return opts
        }
        set {
            anyTouchGestureRecognizer.isEnabled = newValue.transitionsToIdleUponUserInteraction
            usesSafeAreaInsetsAsPadding.value = newValue.usesSafeAreaInsetsAsPadding
        }
    }

    /// Stream of amounts of camera padding that is contributed by safe area insets.
    /// The value changes when device rotates, `additionalSafeAreaInsets` or
    /// ``ViewportOptions/usesSafeAreaInsetsAsPadding`` change.
    ///
    /// When ``ViewportOptions/usesSafeAreaInsetsAsPadding`` is disabled the value is `nil`.
    let safeAreaPadding: Signal<UIEdgeInsets?>

    private let mapboxMap: MapboxMapProtocol
    private let mainQueue: DispatchQueueProtocol
    private let anyTouchGestureRecognizer: UIGestureRecognizer
    private let isDefaultCameraInitialized: Signal<Bool>

    private var usesSafeAreaInsetsAsPadding = CurrentValueSignalSubject(false)
    private var safeAreaPaddingForIdleToken: AnyCancelable?
    private var safeAreaPaddingForIdle: UIEdgeInsets? {
        didSet {
            if status == .idle {
                // In idle state the padding will remain the same, but we need to update
                // safe area contribution into it, when it changes (device rotation).
                let padding = self.mapboxMap.cameraState.padding
                let newPadding = padding + ((safeAreaPaddingForIdle - oldValue) ?? .zero)
                if padding != newPadding {
                    mapboxMap.setCamera(to: CameraOptions(padding: newPadding))
                }
            }
        }
    }

    deinit {
        currentCancelable?.cancel()
        status = .idle
    }

    // viewport requires a default transition at all times
    internal init(options: ViewportOptions,
                  mapboxMap: MapboxMapProtocol,
                  safeAreaInsets: Signal<UIEdgeInsets>,
                  isDefaultCameraInitialized: Signal<Bool>,
                  mainQueue: DispatchQueueProtocol,
                  defaultTransition: ViewportTransition,
                  anyTouchGestureRecognizer: UIGestureRecognizer,
                  doubleTapGestureRecognizer: UIGestureRecognizer,
                  doubleTouchGestureRecognizer: UIGestureRecognizer) {
        self.mapboxMap = mapboxMap
        self.mainQueue = mainQueue
        self.defaultTransition = defaultTransition
        self.status = .idle
        self.isDefaultCameraInitialized = isDefaultCameraInitialized
        self.anyTouchGestureRecognizer = anyTouchGestureRecognizer
        self.safeAreaPadding = Signal
            .combineLatest(usesSafeAreaInsetsAsPadding.signal, safeAreaInsets)
            .map { enabled, insets in
                enabled ? insets : nil
            }
        anyTouchGestureRecognizer.addTarget(self, action: #selector(handleAnyTouchGesture(_:)))
        doubleTapGestureRecognizer.addTarget(self, action: #selector(handleDoubleTapAndTouchGestures(_:)))
        doubleTouchGestureRecognizer.addTarget(self, action: #selector(handleDoubleTapAndTouchGestures(_:)))
        // sync with provided options
        self.options = options

        // In case of initialization from idle state and with `usesSafeAreaInsetsAsPadding = true`
        // we need to wait until the first onCameraChange event is happened (`defaultCameraLoaded`).
        // Otherwise, we early set just a camera padding and core won't apply the initial default
        // style camera. In practice, it would result in irrelevant zero camera with some padding.
        let defaultCameraLoaded =  isDefaultCameraInitialized.filter { $0 }
        safeAreaPaddingForIdleToken = Signal
            .combineLatest(safeAreaPadding, defaultCameraLoaded)
            .map { $0.0 }
            .assign(to: \.safeAreaPaddingForIdle, ofWeak: self)
    }

    // MARK: - Status

    // defaults to .idle
    internal private(set) var status: ViewportStatus

    private var statusObservers = [ViewportStatusObserver]()

    internal func addStatusObserver(_ observer: ViewportStatusObserver) {
        if statusObservers.allSatisfy({ $0 !== observer }) {
            statusObservers.append(observer)
        }
    }

    internal func removeStatusObserver(_ observer: ViewportStatusObserver) {
        statusObservers.removeAll { $0 === observer }
    }

    private func notifyObservers(withFromStatus fromStatus: ViewportStatus,
                                 toStatus: ViewportStatus,
                                 reason: ViewportStatusChangeReason) {
        guard fromStatus != toStatus else {
            return
        }
        mainQueue.async { [weak self] in
            self?.statusObservers.forEach {
                $0.viewportStatusDidChange(from: fromStatus, to: toStatus, reason: reason)
            }
        }
    }

    // a cancelable that can be used to stop the current state or transition
    private var currentCancelable: Cancelable?

    // MARK: - Changing States

    internal func idle() {
        idle(invokingCancelable: true, reason: .idleRequested)
    }

    private func idle(invokingCancelable: Bool, reason: ViewportStatusChangeReason) {
        if invokingCancelable {
            // cancel any previous state or transition
            currentCancelable?.cancel()
        }
        currentCancelable = nil
        let fromStatus = status
        status = .idle
        notifyObservers(withFromStatus: fromStatus, toStatus: status, reason: reason)
    }

    // the Bool in the completion block indicates whether the transition ran to
    // completion (true) or was interrupted in some way (false). if the source
    // of the interruption was because transition(to:completion:) or idle() was
    // invoked, the next status is determined by those interrupting calls. if
    // the source of the interruption was external (e.g. the ViewportTransition
    // failed for some reason), the status will be set to .idle.
    //
    // transitioning to state x when status equals .state(x) just
    // invokes completion synchronously with `true` and does not modify status
    //
    // transitioning to state x when status equals .transition(_, _, x) just
    // invokes completion synchronously with `false` and does not modify status
    internal func transition(to toState: ViewportState, transition: ViewportTransition?, completion: ((Bool) -> Void)?) {
        // swiftlint:disable:previous function_body_length
        switch status {
        case .idle:
            break
        case .state(let state):
            // exit early if attempting to transition into the current state
            guard state !== toState else {
                completion?(true)
                return
            }
        case .transition(_, let oldToState):
            // exit early if attempting to transition to the same state as the current transition
            guard oldToState !== toState else {
                completion?(false)
                return
            }
        }

        // cancel any previous state or transition
        currentCancelable?.cancel()
        currentCancelable = nil

        // get the transition (or default) for the from and to state
        let transition = transition ?? defaultTransition

        // run the transition
        var transitionCanceled = false
        var completionBlockInvoked = false
        let transitionCancelable = transition.run(to: toState) { [weak self] (success) in
            completionBlockInvoked = true

            // transitions are allowed to invoke this completion block when we
            // cancel the cancelable they return to us. If we initiate the
            // cancellation, we just want to ignore the rest of this block
            // since we handle the cleanup separately (and differently) in that
            // case.
            guard !transitionCanceled else {
                return
            }

            if let self = self {
                if success {
                    // transfer camera upating responsibility to toState
                    toState.startUpdatingCamera()

                    self.currentCancelable = BlockCancelable {
                        toState.stopUpdatingCamera()
                    }

                    // set the status before calling the completion block
                    // since it could trigger some further mutation to status
                    // which would then be clobbered by this line.
                    let fromStatus = self.status
                    self.status = .state(toState)

                    self.notifyObservers(
                        withFromStatus: fromStatus,
                        toStatus: self.status,
                        reason: .transitionSucceeded)
                } else {
                    // the transition failed for some reason (e.g. its animations were canceled externally)
                    self.idle(invokingCancelable: false, reason: .transitionFailed)
                }
            }

            // and call the completion block
            completion?(success)
        }

        // since it's possible that a transition might invoke its
        // completion block synchronously, we'll only store the
        // transition cancelable if the transition is not complete
        // so that we don't clobber the toState cancelable.
        if !completionBlockInvoked {
            currentCancelable = BlockCancelable {
                // we canceled the transition; set this flag
                // so that we skip the run completion block if
                // it gets invoked when we cancel transitionCancelable
                transitionCanceled = true
                transitionCancelable.cancel()
                completion?(false)
            }
            let fromStatus = status
            status = .transition(transition, toState: toState)
            notifyObservers(
                withFromStatus: fromStatus,
                toStatus: status,
                reason: .transitionStarted)
        }
    }

    // MARK: - Configuring Transitions

    // this transition is used unless overridden by one of the registered transitions
    internal var defaultTransition: ViewportTransition

    // MARK: - Gestures

    @objc private func handleAnyTouchGesture(_ gestureRecognizer: UIGestureRecognizer) {
        guard options.transitionsToIdleUponUserInteraction else {
            return
        }
        switch gestureRecognizer.state {
        case .began:
            idle(invokingCancelable: true, reason: .userInteraction)
        default:
            break
        }
    }

    @objc private func handleDoubleTapAndTouchGestures(_ gestureRecognizer: UIGestureRecognizer) {
        guard options.transitionsToIdleUponUserInteraction else {
            return
        }
        switch gestureRecognizer.state {
        case .recognized:
            idle(invokingCancelable: true, reason: .userInteraction)
        default:
            break
        }
    }
}
