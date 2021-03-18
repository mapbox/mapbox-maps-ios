import UIKit

public struct Example {
    public static let finishNotificationName = Notification.Name("com.mapbox.Examples.finish")

    public var title: String
    public var description: String
    public var testTimeout: TimeInterval = 20.0
    public var type: ExampleProtocol.Type

    public func makeViewController() -> UIViewController {
        guard let exampleClass = type as? UIViewController.Type else {
            fatalError("Unable to get class name from example named \(type)")
        }

        let exampleViewController = exampleClass.init()
        exampleViewController.title = title
        exampleViewController.navigationItem.largeTitleDisplayMode = .never

        let association = ExampleAssociation(example: self, viewController: exampleViewController)
        objc_setAssociatedObject(exampleViewController, &ExampleAssociationHandle, association, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        let barButtonItem = UIBarButtonItem(title: "Info", style: .plain, target: association, action: #selector(ExampleAssociation.presentAlert))

        exampleViewController.navigationItem.setRightBarButton(barButtonItem, animated: false)

        return exampleViewController
    }
}

private var ExampleAssociationHandle: UInt8 = 0
private class ExampleAssociation: NSObject {

    internal let example: Example
    internal weak var viewController: UIViewController?

    internal init(example: Example, viewController: UIViewController) {
        self.example = example
        self.viewController = viewController
        super.init()
    }

    @objc func presentAlert() {
        guard let viewController = viewController else {
            return
        }

        let alert = UIAlertController(title: "About this example",
                                      message: example.description,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "Got it", style: .default, handler: nil)
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
}
