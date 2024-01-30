import UIKit
#if !(swift(>=5.9) && os(visionOS))
import Fingertips
#endif

@UIApplicationMain
public class AppDelegate: UIResponder, UIApplicationDelegate {
#if !(swift(>=5.9) && os(visionOS))
    public var window: UIWindow? = {
        let window = FingerTipWindow(frame: UIScreen.main.bounds)
        window.alwaysShowTouches = true
        return window
    }()
#endif
}
