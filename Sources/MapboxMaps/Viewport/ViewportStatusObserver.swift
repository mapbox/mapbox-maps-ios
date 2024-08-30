/// `ViewportStatusObserver` must be implemented by objects that wish to register
/// themselves using ``ViewportManager/addStatusObserver(_:)`` so that they can observe
/// ``ViewportManager/status`` changes.
///
/// - SeeAlso: ``ViewportManager/addStatusObserver(_:)`` for an important note about how
///            these notifications are delivered asynchronously.
public protocol ViewportStatusObserver: AnyObject {

    /// Called whenever ``ViewportManager/status`` changes.
    /// - Parameters:
    ///   - fromStatus: The value of ``ViewportManager/status`` prior to the change.
    ///   - toStatus: The value of ``ViewportManager/status`` after the change.
    ///   - reason: A ``ViewportStatusChangeReason`` that indicates what initiated the change.
    func viewportStatusDidChange(from fromStatus: ViewportStatus,
                                 to toStatus: ViewportStatus,
                                 reason: ViewportStatusChangeReason)
}

/// Constants that describe why ``ViewportManager/status`` changed.
public struct ViewportStatusChangeReason: Hashable, Sendable {
    private var rawValue: String

    /// ``ViewportManager/status`` changed because ``ViewportManager/idle()`` was invoked.
    public static let idleRequested = ViewportStatusChangeReason(rawValue: "IDLE_REQUESTED")

    /// ``ViewportManager/status`` changed because ``ViewportManager/transition(to:transition:completion:)`` was invoked.
    ///
    /// An event with this reason is not delivered if the ``ViewportTransition/run(to:completion:)`` invokes its completion
    /// block synchronously.
    public static let transitionStarted = ViewportStatusChangeReason(rawValue: "TRANSITION_STARTED")

    /// ``ViewportManager/status`` changed because ``ViewportManager/transition(to:transition:completion:)`` completed successfully.
    public static let transitionSucceeded = ViewportStatusChangeReason(rawValue: "TRANSITION_SUCCEEDED")

    /// ``ViewportManager/status`` changed because ``ViewportManager/transition(to:transition:completion:)`` failed.
    public static let transitionFailed = ViewportStatusChangeReason(rawValue: "TRANSITION_FAILED")

    /// ``ViewportManager/status`` changed due to user interaction.
    ///
    /// - SeeAlso: ``ViewportOptions/transitionsToIdleUponUserInteraction``
    public static let userInteraction = ViewportStatusChangeReason(rawValue: "USER_INTERACTION")
}
