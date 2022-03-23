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

extension ExampleProtocol where Self: UIViewController {
    // Presents an alert with a given title.
    public func showAlert(with title: String) {
        let alertController = UIAlertController(title: title,
                                                message: nil,
                                                preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
}
