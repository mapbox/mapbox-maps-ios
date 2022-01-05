public protocol ViewportTransition: AnyObject {
    // the completion block contains a Bool that is true if the transition ran to completion and false
    // if it was canceled. implementations must be sure to invoke the completion block with false if
    // the returned Cancelable is invoked prior to completion. the completion block must be invoked
    // on the main queue. Transitions must handle the possibility that the "to" state might fail to
    // provide a target camera in a timely manner or might update the target camera multiple times
    // during the transition (a "moving target").
    func run(from fromState: ViewportState?,
             to toState: ViewportState,
             completion: @escaping (Bool) -> Void) -> Cancelable
}
