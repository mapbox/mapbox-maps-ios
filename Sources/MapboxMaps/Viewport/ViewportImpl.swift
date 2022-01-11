internal protocol ViewportImplProtocol: AnyObject {
    var status: ViewportStatus { get }
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

    // viewport requires a default transition at all times
    internal init(defaultTransition: ViewportTransition) {
        self.defaultTransition = defaultTransition
        self.status = .state(nil)
    }

    // MARK: - Current State

    // defaults to .state(nil), aka idle
    internal private(set) var status: ViewportStatus

    // a cancelable that can be used to stop the current state or transition
    private var currentCancelable: Cancelable?

    internal func idle() {
        // cancel any previous state or transition
        currentCancelable?.cancel()
        currentCancelable = nil
        status = .state(nil)

        // TODO: notify of status change
    }

    // set
    // the Bool in the completion block indicates whether the transition ran to
    // completion (true) or was interrupted by another transition (false)
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

        status = .transition(transition, fromState: fromState, toState: toState)

        // TODO: notify of state change

        // run the transition
        var completionBlockInvoked = false
        let transitionCancelable = transition.run(from: fromState, to: toState) { [weak self] in
            completionBlockInvoked = true

            if let self = self {
                // transfer camera upating responsibility to toState
                toState.startUpdatingCamera()

                self.currentCancelable = BlockCancelable {
                    toState.stopUpdatingCamera()
                }

                // set the status before calling the completion block
                // since it could trigger some further mutation to status
                // which would then be clobbered by this line.
                self.status = .state(toState)
            }

            // and call the completion block
            completion?(true)

            // TODO: notify of status change here if needed; decouple
            // this from when status is actually set so that we can
            // invoke the completion block first
        }

        // since it's possible that a transition might invoke its
        // completion block synchronously, we'll only store the
        // transition cancelable if the transition is not complete
        // so that we don't clobber the toState cancelable.
        if !completionBlockInvoked {
            currentCancelable = BlockCancelable {
                transitionCancelable.cancel()
                completion?(false)
            }
        }
    }

    // MARK: - Transitions

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
}

private struct CompositeTransitionKey: Hashable {
    private let objectIdentifiers: [ObjectIdentifier?]

    internal init(from: ViewportState?, to: ViewportState) {
        self.objectIdentifiers = [from, to].map { $0.map(ObjectIdentifier.init) }
    }
}
