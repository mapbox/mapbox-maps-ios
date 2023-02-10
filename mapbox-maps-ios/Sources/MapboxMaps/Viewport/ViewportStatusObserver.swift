/// `ViewportStatusObserver` must be implemented by objects that wish to register
/// themselves using ``Viewport/addStatusObserver(_:)`` so that they can observe
/// ``Viewport/status`` changes.
///
/// - SeeAlso: ``Viewport/addStatusObserver(_:)`` for an important note about how
///            these notifications are delivered asynchronously.
public protocol ViewportStatusObserver: AnyObject {

    /// Called whenever ``Viewport/status`` changes.
    /// - Parameters:
    ///   - fromStatus: The value of ``Viewport/status`` prior to the change.
    ///   - toStatus: The value of ``Viewport/status`` after the change.
    ///   - reason: A ``ViewportStatusChangeReason`` that indicates what initiated the change.
    func viewportStatusDidChange(from fromStatus: ViewportStatus,
                                 to toStatus: ViewportStatus,
                                 reason: ViewportStatusChangeReason)
}

/// Constants that describe why ``Viewport/status`` changed.
public struct ViewportStatusChangeReason: Hashable {
    private var rawValue: String

    private init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// ``Viewport/status`` changed because ``Viewport/idle()`` was invoked.
    public static let idleRequested = ViewportStatusChangeReason(rawValue: "IDLE_REQUESTED")

    /// ``Viewport/status`` changed because ``Viewport/transition(to:transition:completion:)`` was invoked.
    ///
    /// An event with this reason is not delivered if the ``ViewportTransition/run(to:completion:)`` invokes its completion
    /// block synchronously.
    public static let transitionStarted = ViewportStatusChangeReason(rawValue: "TRANSITION_STARTED")

    /// ``Viewport/status`` changed because ``Viewport/transition(to:transition:completion:)`` completed successfully.
    public static let transitionSucceeded = ViewportStatusChangeReason(rawValue: "TRANSITION_SUCCEEDED")

    /// ``Viewport/status`` changed because ``Viewport/transition(to:transition:completion:)`` failed.
    public static let transitionFailed = ViewportStatusChangeReason(rawValue: "TRANSITION_FAILED")

    /// ``Viewport/status`` changed due to user interaction.
    ///
    /// - SeeAlso: ``ViewportOptions/transitionsToIdleUponUserInteraction``
    public static let userInteraction = ViewportStatusChangeReason(rawValue: "USER_INTERACTION")
}
