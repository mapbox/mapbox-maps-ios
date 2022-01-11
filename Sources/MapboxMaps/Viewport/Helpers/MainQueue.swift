// depending on this protocol instead of on DispatchQueue directly
// allow mocking the main queue in tests which avoids the need for waits
internal protocol MainQueueProtocol: AnyObject {
    func async(execute work: @escaping () -> Void)
}

internal final class MainQueue: MainQueueProtocol {
    internal func async(execute work: @escaping () -> Void) {
        DispatchQueue.main.async(execute: work)
    }
}
