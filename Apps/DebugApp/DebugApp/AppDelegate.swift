import UIKit
import Fingertips
import os

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = FingerTipWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = DebugViewController()
        window?.makeKeyAndVisible()
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        if let debugViewController = window?.rootViewController as? DebugViewController {
            os_log("Save camera state on applicationWillTerminate")
            debugViewController.saveCameraState()
        }
    }
}
