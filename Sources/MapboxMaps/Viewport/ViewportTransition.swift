public protocol ViewportTransition: AnyObject {
    // The completion block must not be invoked if the returned Cancelable is invoked prior to
    // completion. the completion block must be invoked on the main queue. Transitions should
    // handle the possibility that the "to" state might fail to provide a target camera in a
    // timely manner or might update the target camera multiple times during the transition
    // (a "moving target").
    //
    // TODO: How to handle the possibility that the transition interrupts a previous transiton (or even a previous invocation of itself)? What should fromState be in that case? Should transitions even be allowed to depend on the fromState or should they only be allowed to depend on the current camera?
    func run(from fromState: ViewportState?,
             to toState: ViewportState,
             completion: @escaping () -> Void) -> Cancelable
}
