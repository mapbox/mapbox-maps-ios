import UIKit
import Fingertips

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    lazy var window: UIWindow? = {
        return FingerTipWindow(frame: UIScreen.main.bounds)
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        let appearance = UINavigationBar.appearance()
        appearance.prefersLargeTitles = true

        if #available(iOS 13.0, *) {
            appearance.scrollEdgeAppearance = UINavigationBarAppearance()
        }

        if #unavailable(iOS 13.0) {
            let examplesTableViewController = ExampleTableViewController()
            let navigationController = UINavigationController(rootViewController: examplesTableViewController)
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
        }

        return true
    }
}

@available(iOS 13.0, *)
final class SceneDelegate: NSObject, UISceneDelegate {
    var windows: [UIWindow] = []

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = FingerTipWindow(windowScene: windowScene)

        let examplesTableViewController = ExampleTableViewController()
        let navigationController = UINavigationController(rootViewController: examplesTableViewController)

        let appearance = UINavigationBar.appearance()
        appearance.prefersLargeTitles = true

        appearance.scrollEdgeAppearance = UINavigationBarAppearance()

        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        windows.append(window)
    }
}
