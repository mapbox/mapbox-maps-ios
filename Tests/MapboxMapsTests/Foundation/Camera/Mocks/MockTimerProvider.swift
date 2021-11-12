@testable import MapboxMaps

internal struct TimerProviderParams {
    var interval: TimeInterval
    var repeats: Bool
    var block: (TimerProtocol) -> Void
}

internal extension Stub where ParametersType == TimerProviderParams, ReturnType == TimerProtocol {
    func provide(_ interval: TimeInterval, _ repeats: Bool, _ block: @escaping (TimerProtocol) -> Void) -> TimerProtocol {
        call(with: TimerProviderParams(interval: interval, repeats: repeats, block: block))
    }
}

typealias MockTimerProvider = Stub<TimerProviderParams, TimerProtocol>
