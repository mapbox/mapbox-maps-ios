import UIKit
import Fingertips

@UIApplicationMain
public class AppDelegate: UIResponder, UIApplicationDelegate {
    public var window: UIWindow? = {
        let window = FingerTipWindow(frame: UIScreen.main.bounds)
        window.alwaysShowTouches = true
        return window
    }()
}
