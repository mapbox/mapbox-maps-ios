import CarPlay
import UIKit

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
