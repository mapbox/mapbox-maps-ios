/// `ViewportTransition` is a protocol that ``ViewportManager`` depends on as it orchestrates transitions
/// to and from different ``ViewportState``s.
///
/// MapboxMaps provides implementations of ``ViewportTransition`` that can be created and
/// configured via methods on ``ViewportManager``. Applications may also define their own implementations to
/// handle advanced use cases not covered by the provided implementations.
///
/// - SeeAlso:
///   - ``DefaultViewportTransition``
///   - ``ImmediateViewportTransition``
public protocol ViewportTransition: AnyObject {
    /// Runs the transition to `toState`.
    ///
    /// The completion block must be invoked with `true` if the transition completes successfully. If the
    /// transition fails, invoke the completion block with `false`.
    ///
    /// If the returned `Cancelable` is canceled, it not necessary to invoke the completion block (but
    /// is safe to do so — it will just be ignored).
    ///
    /// Transitions should handle the possibility that the "to" state might fail to provide a target camera in a
    /// timely manner or might update the target camera multiple times during the transition (a "moving
    /// target").
    ///
    /// - Parameters:
    ///   - toState: The target state for the transition.
    ///   - completion:A block that must be invoked when the transition is complete. Must be invoked
    ///                on the main queue.
    /// - Returns: a `Cancelable` that can be used to terminate the transition. If
    ///            `Cancelable/cancel()` is invoked, the transition must immediately stop
    ///            updating the camera and cancel any animations that it started.
    func run(to toState: ViewportState,
             completion: @escaping (_ success: Bool) -> Void) -> Cancelable
}
