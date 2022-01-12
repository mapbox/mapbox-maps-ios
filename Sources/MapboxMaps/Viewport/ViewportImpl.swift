internal protocol ViewportImplProtocol: AnyObject {
    var options: ViewportOptions { get set }

    var status: ViewportStatus { get }
    func addStatusObserver(_ observer: ViewportStatusObserver)
    func removeStatusObserver(_ observer: ViewportStatusObserver)

    func idle()
    func transition(to toState: ViewportState, completion: ((Bool) -> Void)?)

    var defaultTransition: ViewportTransition { get set }
    func setTransition(_ transition: ViewportTransition, from fromState: ViewportState?, to toState: ViewportState)
    func getTransition(from fromState: ViewportState?, to toState: ViewportState) -> ViewportTransition?
    func removeTransition(from fromState: ViewportState?, to toState: ViewportState)
}

// provides a structured approach to organizing
// camera management logic into states and transitions between them
//
// at any given time, the viewport is either:
//
//  - idle (not updating the camera)
//  - in a state (camera is being managed by a ViewportState)
//  - transitioning (camera is being managed by a ViewportTransition)
//
internal final class ViewportImpl: ViewportImplProtocol {

    internal var options: ViewportOptions

    private let mainQueue: MainQueueProtocol

    // viewport requires a default transition at all times
    internal init(options: ViewportOptions,
                  mainQueue: MainQueueProtocol,
                  defaultTransition: ViewportTransition,
                  idleGestureRecognizer: UIGestureRecognizer) {
        self.options = options
        self.mainQueue = mainQueue
        self.defaultTransition = defaultTransition
        self.status = .state(nil)
        idleGestureRecognizer.addTarget(self, action: #selector(handleIdleGesture(_:)))
    }

    // MARK: - Status

    // defaults to .state(nil), aka idle
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
        idle(invokingCancelable: true, reason: .programmatic)
    }

    private func idle(invokingCancelable: Bool, reason: ViewportStatusChangeReason) {
        if invokingCancelable {
            // cancel any previous state or transition
            currentCancelable?.cancel()
        }
        currentCancelable = nil
        let fromStatus = status
        status = .state(nil)
        notifyObservers(withFromStatus: fromStatus, toStatus: status, reason: reason)
    }

    // the Bool in the completion block indicates whether the transition ran to
    // completion (true) or was interrupted in some way (false). if the source
    // of the interruption was because transition(to:completion:) or idle() was
    // invoked, the next status is determined by those interrupting calls. if
    // the source of the interruption was external (e.g. the ViewportTransition
    // failed for some reason), the status will be set to idle (.state(nil)).
    //
    // transitioning to state x when status equals .state(x) just
    // invokes completion synchronously with `true` and does not modify status
    //
    // transitioning to state x when status equals .transition(_, _, x) just
    // invokes completion synchronously with `false` and does not modify status
    internal func transition(to toState: ViewportState, completion: ((Bool) -> Void)?) {

        switch status {
        case .state(let state):
            // exit early if attempting to transition into the current state
            guard state !== toState else {
                completion?(true)
                return
            }
        case .transition(_, _, let oldToState):
            // exit early if attempting to transition to the same state as the current transition
            guard oldToState !== toState else {
                completion?(false)
                return
            }
        }

        // cancel any previous state or transition
        currentCancelable?.cancel()
        currentCancelable = nil

        let fromState: ViewportState?
        switch status {
        case .state(let state):
            fromState = state
        case .transition(_, _, let oldToState):
            fromState = oldToState
        }

        // get the transition (or default) for the from and to state
        let transition = getTransition(from: fromState, to: toState) ?? defaultTransition

        // run the transition
        var transitionCanceled = false
        var completionBlockInvoked = false
        let transitionCancelable = transition.run(from: fromState, to: toState) { [weak self] (success) in
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
                        reason: .programmatic)
                } else {
                    // the transition failed for some reason (e.g. its animations were canceled externally)
                    self.idle(invokingCancelable: false, reason: .programmatic)
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
            status = .transition(transition, fromState: fromState, toState: toState)
            notifyObservers(
                withFromStatus: fromStatus,
                toStatus: status,
                reason: .programmatic)
        }
    }

    // MARK: - Configuring Transitions

    // this transition is used unless overridden by one of the registered transitions
    internal var defaultTransition: ViewportTransition

    // CompositeTransitionKey allows us to use identity-based equality and hashing
    // of both the from and to states. This means you can register different
    // transitions into a given state based on the from state (or vice-versa).
    private var registeredTransitions = [CompositeTransitionKey: ViewportTransition]()

    // set
    // we allow setting a custom transition from idle (nil) to a state, but
    // there's never a transition when going from some non-nil state to idle.
    internal func setTransition(_ transition: ViewportTransition, from fromState: ViewportState?, to toState: ViewportState) {
        assert(fromState !== toState)
        registeredTransitions[CompositeTransitionKey(from: fromState, to: toState)] = transition
    }

    // get
    internal func getTransition(from fromState: ViewportState?, to toState: ViewportState) -> ViewportTransition? {
        assert(fromState !== toState)
        return registeredTransitions[CompositeTransitionKey(from: fromState, to: toState)]
    }

    // delete
    internal func removeTransition(from fromState: ViewportState?, to toState: ViewportState) {
        assert(fromState !== toState)
        registeredTransitions.removeValue(forKey: CompositeTransitionKey(from: fromState, to: toState))
    }

    // MARK: - Gestures

    @objc private func handleIdleGesture(_ gestureRecognizer: UIGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            if options.transitionsToIdleUponUserInteraction {
                idle(invokingCancelable: true, reason: .userInteraction)
            }
        default:
            break
        }
    }
}

private struct CompositeTransitionKey: Hashable {
    private let objectIdentifiers: [ObjectIdentifier?]

    internal init(from: ViewportState?, to: ViewportState) {
        self.objectIdentifiers = [from, to].map { $0.map(ObjectIdentifier.init) }
    }
}
