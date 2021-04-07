import Foundation
import MapboxMaps

public protocol ExampleProtocol: AnyObject {
    func resourceOptions() -> ResourceOptions
    func finish()
}

extension ExampleProtocol {
    public func resourceOptions() -> ResourceOptions {
        guard let accessToken = CredentialsManager.default.accessToken else {
            fatalError("Access token not set")
        }

        guard !accessToken.isEmpty else {
            fatalError("Empty access token")
        }

        let resourceOptions = ResourceOptions(accessToken: accessToken)
        return resourceOptions
    }

    public func finish() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            NotificationCenter.default.post(name: Example.finishNotificationName, object: self)
        }
    }
}
