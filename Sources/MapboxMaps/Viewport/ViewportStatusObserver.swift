@_spi(Experimental) public protocol ViewportStatusObserver: AnyObject {
    func viewportStatusDidChange(from fromStatus: ViewportStatus,
                                 to toStatus: ViewportStatus,
                                 reason: ViewportStatusChangeReason)
}

@_spi(Experimental) public struct ViewportStatusChangeReason: Hashable {
    private var rawValue: String

    private init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static let idleRequested = ViewportStatusChangeReason(rawValue: "IDLE_REQUESTED")

    public static let transitionStarted = ViewportStatusChangeReason(rawValue: "TRANSITION_STARTED")

    public static let transitionSucceeded = ViewportStatusChangeReason(rawValue: "TRANSITION_SUCCEEDED")

    public static let transitionFailed = ViewportStatusChangeReason(rawValue: "TRANSITION_FAILED")

    public static let userInteraction = ViewportStatusChangeReason(rawValue: "USER_INTERACTION")
}
