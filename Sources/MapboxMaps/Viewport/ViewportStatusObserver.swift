public protocol ViewportStatusObserver: AnyObject {
    func viewportStatusDidChange(from fromStatus: ViewportStatus,
                                 to toStatus: ViewportStatus,
                                 reason: ViewportStatusChangeReason)
}

public struct ViewportStatusChangeReason: RawRepresentable, Hashable {
    public typealias RawValue = String

    public var rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static let programmatic = ViewportStatusChangeReason(rawValue: "PROGRAMMATIC")

    public static let userInteraction = ViewportStatusChangeReason(rawValue: "USER_INTERACTION")
}
