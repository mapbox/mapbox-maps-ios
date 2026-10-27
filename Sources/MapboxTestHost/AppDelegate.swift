import UIKit
#if !(swift(>=5.9) && os(visionOS))
import Fingertips
#endif

@main
class AppDelegate: UIResponder, UIApplicationDelegate {}

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

#if !(swift(>=5.9) && os(visionOS))
        let window = FingerTipWindow(windowScene: windowScene)
        window.alwaysShowTouches = true
#else
        let window = UIWindow(windowScene: windowScene)
#endif
        window.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        window.makeKeyAndVisible()
        self.window = window
    }
}
