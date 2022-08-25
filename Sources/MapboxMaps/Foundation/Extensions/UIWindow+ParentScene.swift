#if os(OSX)
import AppKit
#else
import UIKit
#endif

#if os(iOS)
import CarPlay

@available(iOS 13.0, *)
extension UIWindow {
    internal var parentScene: UIScene? {
        switch self {
        case let carPlayWindow as CPWindow:
            return carPlayWindow.templateApplicationScene
        default:
            return windowScene

        }
    }
}
#endif
