import CarPlay
import UIKit

@available(iOS 13.0, *)
extension UIWindow {
    internal var parentScene: UIScene? {
        return windowScene ?? (self as? CPWindow)?.templateApplicationScene
    }
}
