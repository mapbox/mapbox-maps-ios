#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

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

        let appearance = UINavigationBar.appearance()
        appearance.prefersLargeTitles = true

        if #available(iOS 13.0, *) {
            appearance.scrollEdgeAppearance = UINavigationBarAppearance()
        }

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }
}
