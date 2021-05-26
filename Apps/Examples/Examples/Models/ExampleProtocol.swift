import Foundation
import MapboxMaps

public protocol ExampleProtocol: AnyObject {
    func resourceOptions() -> ResourceOptions
    func finish()
}

extension ExampleProtocol {
    public func resourceOptions() -> ResourceOptions {
        return ResourceOptionsManager.default.resourceOptions
    }

    public func finish() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            NotificationCenter.default.post(name: Example.finishNotificationName, object: self)
        }
    }
}
