@_spi(Experimental) public protocol ViewportTransition: AnyObject {
    // The completion block must be invoked with true if the transition
    // completes successfully. If the transition fails, invoke the completion
    // block with false. If the returned Cancelable is canceled, it not
    // necessary to invoke the completion block (but is safe to do so — it will
    // just be ignored). the completion block must be invoked on the main queue.
    //
    // Transitions should handle the possibility that the "to" state might fail
    // to provide a target camera in a timely manner or might update the target
    // camera multiple times during the transition (a "moving target").
    //
    // Viewport never invokes run with the same state for from and to.
    func run(to toState: ViewportState,
             completion: @escaping (Bool) -> Void) -> Cancelable
}
