import Foundation

internal protocol TimerProtocol: AnyObject {
    func invalidate()
}

extension Timer: TimerProtocol {}

internal protocol TimerProviderProtocol {
    func makeScheduledTimer(timeInterval: TimeInterval,
                            repeats: Bool,
                            block: @escaping (TimerProtocol) -> Void) -> TimerProtocol
}

internal final class TimerProvider: TimerProviderProtocol {
    internal func makeScheduledTimer(timeInterval: TimeInterval, repeats: Bool, block: @escaping (TimerProtocol) -> Void) -> TimerProtocol {
        return Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: repeats, block: block)
    }
}
