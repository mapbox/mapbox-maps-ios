import UIKit
import CarPlay
import MapboxMaps

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        window = UIWindow(frame: UIScreen.main.bounds)
//        window?.rootViewController = DebugViewController()
//        window?.makeKeyAndVisible()
        return true
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

extension AppDelegate: UISceneDelegate {
    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = DebugViewController()
        window?.makeKeyAndVisible()
    }
}

extension AppDelegate: CPTemplateApplicationSceneDelegate {
    @available(iOS 13.0, *)
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        let viewController = DebugViewController()
        templateApplicationScene.carWindow.rootViewController = viewController

        let mapTemplate = CPMapTemplate()
        mapTemplate.mapDelegate = viewController
        let zoomInButton = CPMapButton { _ in
            viewController.zoomIn()
        }
        zoomInButton.isHidden = false
        zoomInButton.isEnabled = true
        zoomInButton.image = UIImage(named: "star")

        let zoomOutButton = CPMapButton { _ in
            viewController.zoomOut()
        }
        zoomOutButton.isHidden = false
        zoomOutButton.isEnabled = true
        zoomOutButton.image = UIImage(named: "triangle")

        mapTemplate.mapButtons = [zoomInButton, zoomOutButton]
        mapTemplate.automaticallyHidesNavigationBar = false

        interfaceController.setRootTemplate(mapTemplate, animated: true)
    }
}
