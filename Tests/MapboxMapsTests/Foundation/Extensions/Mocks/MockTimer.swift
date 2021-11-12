@testable import MapboxMaps

final class MockTimer: TimerProtocol {
    let invalidateStub = Stub<Void, Void>()
    func invalidate() {
        invalidateStub.call()
    }
}
