import Foundation

extension Timer: TimerProtocol {}

internal protocol TimerProtocol: AnyObject {
    func invalidate()
}
