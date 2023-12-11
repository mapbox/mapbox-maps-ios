import UIKit

public struct Example {
    public static let finishNotificationName = Notification.Name("com.mapbox.Examples.finish")

    public var title: String
    public var description: String
    public var testTimeout: TimeInterval = 20.0
    public var type: ExampleProtocol.Type

    func makeViewController() -> UIViewController {
        guard let exampleClass = type as? UIViewController.Type else {
            fatalError("Unable to get class name from example named \(type)")
        }

        let exampleViewController: UIViewController

        // Look for a storyboard
        let storyboardName = String(describing: exampleClass)
        if Bundle.main.path(forResource: storyboardName, ofType: "storyboardc") != nil {
            let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
            exampleViewController = storyboard.instantiateInitialViewController()!

            // Check controller is what we expect
            assert(Swift.type(of: exampleViewController) == exampleClass)
        } else {
            exampleViewController = exampleClass.init()
        }

        exampleViewController.title = title
        exampleViewController.navigationItem.largeTitleDisplayMode = .never

        return exampleViewController
    }
}
