import UIKit
import Fingertips

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = FingerTipWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = DebugViewController()
        window?.makeKeyAndVisible()
        return true
    }
}
