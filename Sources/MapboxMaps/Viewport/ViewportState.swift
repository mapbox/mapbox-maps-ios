// requiring states to be classes allows us to use them as keys (via ObjectIdentity)
// without requiring that they conform to Hashable. One implication is that they
// must not be shared among multiple MapView/Viewport instances.
//
// States should generally pre-warm their data sources as soon as they are created
// to minimize delays when they become current. For this reason, only states that
// are currently needed should be kept alive.
@_spi(Experimental) public protocol ViewportState: AnyObject {
    // this method allows a transition to observe the target camera. The handler must
    // be invoked on the main queue. Transitions typically can't start until after the
    // handler is invoked for the first time, so it's a good idea for states to invoke
    // the handler with the current state if it's not too stale rather than waiting
    // for the next camera change to occur. States can pre-warm their data sources
    // when they are created to minimize delays. The caller may either cancel the
    // returned Cancelable *or* return false from the handler to indicate that it wishes
    // to stop receiving updates. Following either of these events, implemenations must
    // no longer invoke the handler.
    func observeDataSource(with handler: @escaping (CameraOptions) -> Bool) -> Cancelable

    // tells this state that it is now responsible for updating the camera.
    // the viewport calls this method at the end of the transition into this state
    func startUpdatingCamera()

    // tells this state that it is no longer responsible for updating the camera.
    // the viewport calls this method at the beginning of the transition out of this state.
    func stopUpdatingCamera()
}
