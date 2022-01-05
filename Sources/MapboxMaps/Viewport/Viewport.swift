// provides a structured approach to organizing
// camera management logic into states and transitions between them
//
// at any given time, the viewport is either:
//
//  - idle (not updating the camera)
//  - in a state (camera is being managed by a ViewportState)
//  - transitioning (camera is being managed by a ViewportTransition)
//
public final class Viewport {

    // a factory that we'll use to create instances of default states and transitions
    // this allows us make the built-in states an transitions depend on internal APIs
    // without injecting those APIs into Viewport itself.
    private let factory: ViewportFactoryProtocol

    // viewport requires a default transition at all times
    internal init(defaultTransition: ViewportTransition, factory: ViewportFactoryProtocol) {
        self.defaultTransition = defaultTransition
        self.factory = factory
    }

    // MARK: - States

    private var statesByIdentity = [ObjectIdentifier: ViewportState]()

    // the list of states. order is not guaranteed
    // TODO: should we guarantee order? Converting this to a Set would be inconvenient
    public var states: [ViewportState] {
        Array(statesByIdentity.values)
    }

    // adds state to the list of states
    // adding the same state more than once has no effect
    public func addState(_ state: ViewportState) {
        let key = ObjectIdentifier(state)
        if statesByIdentity[key] == nil {
            statesByIdentity[key] = state
            state.didMove(to: self)
        }
    }

    // removes state from list of states
    // sets current state to nil if it was identical to state
    // attempting to remove a state that was not added has no effect
    // any active transition to that state will also be canceled
    public func removeState(_ state: ViewportState) {
        if let _ = statesByIdentity.removeValue(forKey: ObjectIdentifier(state)) {
            if state === currentState {
                currentState = nil
                currentCancelable?.cancel()
                currentCancelable = nil
            }

            state.didMove(to: nil)
        }
    }

    // MARK: - Current State

    // a nil currentState is known as "idle"; this is the default
    public private(set) var currentState: ViewportState?

    // a cancelable that can be used to stop the current state or transition
    private var currentCancelable: Cancelable?

    // set
    // the Bool in the completion block indicates whether the transition ran to
    // completion (true) or was interrupted by another transition (false)
    public func setCurrentState(_ toState: ViewportState?, completion: ((Bool) -> Void)? = nil) {
        // exit early if attempting to transition into the current state
        guard toState !== currentState else {
            completion?(true)
            return
        }

        let fromState = currentState

        // cancel any previous state or transition
        currentCancelable?.cancel()
        currentCancelable = nil

        currentState = toState

        if let toState = toState {
            // toState must be a state that has been added
            // TODO: does this really matter? should we just auto-add it?
            assert(statesByIdentity[ObjectIdentifier(toState)] != nil)

            // get the transition (or default) for the from and to state
            let transition = self.transition(from: fromState, to: toState) ?? defaultTransition

            // run the transition
            var completionBlockInvoked = false
            let transitionCancelable = transition.run(from: fromState, to: toState) { [weak self] (finished) in
                completionBlockInvoked = true

                if finished {
                    // transfer camera upating responsibility to toState
                    self?.currentCancelable = toState.startUpdatingCamera()
                }

                // and call the completion block
                completion?(finished)
            }

            // since it's possible that a transition might invoke its
            // completion block synchronously, we'll only store the
            // transition cancelable if the transition is not complete
            // so that we don't clobber the toState cancelable.
            if !completionBlockInvoked {
                currentCancelable = transitionCancelable
            }
        } else {
            // if transitioning to nil (idle), never run a transition
            completion?(true)
        }
    }

    // MARK: - Transitions

    // this transition is used unless overridden by one of the registered transitions
    public var defaultTransition: ViewportTransition

    // CompositeTransitionKey allows us to use identity-based equality and hashing
    // of both the from and to states. This means you can register different
    // transitions into a given state based on the from state (or vice-versa).
    private var registeredTransitions = [CompositeTransitionKey: ViewportTransition]()

    // set
    // we allow setting a custom transition from idle (nil) to a state, but
    // there's never a transition when going from some non-nil state to idle.
    public func setTransition(_ transition: ViewportTransition, from fromState: ViewportState?, to toState: ViewportState) {
        assert(fromState !== toState)
        registeredTransitions[CompositeTransitionKey(from: fromState, to: toState)] = transition
    }

    // get
    public func transition(from fromState: ViewportState?, to toState: ViewportState) -> ViewportTransition? {
        assert(fromState !== toState)
        return registeredTransitions[CompositeTransitionKey(from: fromState, to: toState)]
    }

    // delete
    public func removeTransition(from fromState: ViewportState?, to toState: ViewportState) {
        assert(fromState !== toState)
        registeredTransitions.removeValue(forKey: CompositeTransitionKey(from: fromState, to: toState))
    }
}

extension Viewport {
    public func makeFollowingViewportState(zoom: CGFloat, pitch: CGFloat) -> FollowingViewportState {
        return factory.makeFollowingViewportState(zoom: zoom, pitch: pitch)
    }

    public func makeOverviewViewportState(geometry: GeometryConvertible) -> OverviewViewportState {
        return factory.makeOverviewViewportState(geometry: geometry)
    }

    public func makeEaseToViewportTransition(duration: TimeInterval, curve: UIView.AnimationCurve) -> EaseToViewportTransition {
        return factory.makeEaseToViewportTransition(duration: duration, curve: curve)
    }

    public func makeFlyToViewportTransition(duration: TimeInterval) -> FlyToViewportTransition {
        return factory.makeFlyToViewportTransition(duration: duration)
    }

    public func makeImmediateViewportTransition() -> ImmediateViewportTransition {
        return factory.makeImmediateViewportTransition()
    }
}

private struct CompositeTransitionKey: Hashable {
    private let objectIdentifiers: [ObjectIdentifier?]

    internal init(from: ViewportState?, to: ViewportState) {
        self.objectIdentifiers = [from, to].map { $0.map(ObjectIdentifier.init) }
    }
}
