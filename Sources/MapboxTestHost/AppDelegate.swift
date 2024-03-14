import UIKit
#if !(swift(>=5.9) && os(visionOS))
import Fingertips
#endif

@main
public class AppDelegate: UIResponder, UIApplicationDelegate {
#if !(swift(>=5.9) && os(visionOS))
    public var window: UIWindow? = {
        let window = FingerTipWindow(frame: UIScreen.main.bounds)
        window.alwaysShowTouches = true
        return window
    }()
#endif
}
