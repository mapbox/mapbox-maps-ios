import MapboxMaps

final class MockViewportStatusObserver: ViewportStatusObserver {
    struct ViewportStatusDidChangeParams: Equatable {
        var fromStatus: ViewportStatus
        var toStatus: ViewportStatus
        var reason: ViewportStatusChangeReason
    }
    let viewportStatusDidChangeStub = Stub<ViewportStatusDidChangeParams, Void>()
    func viewportStatusDidChange(from fromStatus: ViewportStatus,
                                 to toStatus: ViewportStatus,
                                 reason: ViewportStatusChangeReason) {
        viewportStatusDidChangeStub.call(with: .init(
            fromStatus: fromStatus,
            toStatus: toStatus,
            reason: reason))
    }
}
