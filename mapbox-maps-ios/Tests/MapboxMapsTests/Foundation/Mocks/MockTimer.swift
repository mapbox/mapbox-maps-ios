@testable import MapboxMaps

final class MockTimer: TimerProtocol {
    let invalidateStub = Stub<Void, Void>()
    func invalidate() {
        invalidateStub.call()
    }
}

final class MockTimerProvider: TimerProviderProtocol {
    struct MakeScheduledTimerParams {
        var timeInterval: TimeInterval
        var repeats: Bool
        var block: (TimerProtocol) -> Void
    }
    let makeScheduledTimerStub = Stub<MakeScheduledTimerParams, TimerProtocol>(defaultReturnValue: MockTimer())
    func makeScheduledTimer(timeInterval: TimeInterval,
                            repeats: Bool,
                            block: @escaping (TimerProtocol) -> Void) -> TimerProtocol {
        makeScheduledTimerStub.call(with: .init(
            timeInterval: timeInterval,
            repeats: repeats,
            block: block))
    }
}
