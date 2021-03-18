import UIKit

@main
//swiftlint:disable explicit_top_level_acl explicit_acl
class AppDelegate: UIResponder, UIApplicationDelegate {

    lazy var window: UIWindow? = {
        return UIWindow(frame: UIScreen.main.bounds)
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        let examplesTableViewController = ExampleTableViewController()
        let navigationController = UINavigationController(rootViewController: examplesTableViewController)
        navigationController.navigationBar.prefersLargeTitles = true
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }
}
