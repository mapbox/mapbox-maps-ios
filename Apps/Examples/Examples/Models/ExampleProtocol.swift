import Foundation
import MapboxMaps

public protocol ExampleProtocol: AnyObject {
    func finish()
}

extension ExampleProtocol {
    public func finish() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            NotificationCenter.default.post(name: Example.finishNotificationName, object: self)
        }
    }
}
