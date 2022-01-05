// requiring states to be classes allows us to use them as keys (via ObjectIdentity)
// without requiring that they conform to Hashable. One implication is that they
// must not be shared among multiple MapView/Viewport instances.
public protocol ViewportState: AnyObject {
    // this method allows a transition to observe the target camera. The handler must
    // be invoked on the main queue. Transitions typically can't start until after the
    // handler is invoked for the first time, so it's a good idea for states to invoke
    // the handler with the current state if it's not too stale rather than waiting
    // for the next camera change to occur. States can pre-warm their data sources
    // when they move to a new viewport (see ``ViewportState.didMove(to:)``) to
    // minimize delays. The caller may either cancel the returned Cancelable *or*
    // return false from the handler to indicate that it wishes to stop receiving
    // updates. Following either of these events, implemenations must no longer invoke
    // the handler.
    func observeCamera(with handler: @escaping (CameraOptions) -> Bool) -> Cancelable

    // tells this state that it is now responsible for updating the camera
    // the viewport calls this method at the end of the transition into this state
    // and calls the cancelable at the beginning of the transition out of this state
    func startUpdatingCamera() -> Cancelable

    // called when a viewport is added to or removed from a ``Viewport``
    // states can pre-warm their data sources when they are added to a ``Viewport``
    // to minimize delays when they become current
    func didMove(to viewport: Viewport?)
}
