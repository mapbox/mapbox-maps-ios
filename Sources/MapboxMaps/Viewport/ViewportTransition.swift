public protocol ViewportTransition: AnyObject {
    // The completion block must not be invoked if the returned Cancelable is invoked prior to
    // completion. the completion block must be invoked on the main queue. Transitions should
    // handle the possibility that the "to" state might fail to provide a target camera in a
    // timely manner or might update the target camera multiple times during the transition
    // (a "moving target").
    //
    // Viewport never invokes run with the same state for from and to.
    func run(from fromState: ViewportState?,
             to toState: ViewportState,
             completion: @escaping () -> Void) -> Cancelable
}
