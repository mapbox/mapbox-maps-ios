import CarPlay
import UIKit

@available(iOS 13.0, *)
extension UIWindow {

    /// The `UIScene` containing this window.
    internal var parentScene: UIScene? {
        switch self {
        case let carPlayWindow as CPWindow:
            return carPlayWindow.templateApplicationScene
        default:
            return windowScene
        }
    }
}

@available(iOS 13.0, *)
extension UIScene {

    internal var allWindows: [UIWindow] {
        if let windowScene = self as? UIWindowScene {
            return windowScene.windows
        } else if let carPlayScene = self as? CPTemplateApplicationScene {
            return [carPlayScene.carWindow]
        } else if #available(iOS 13.4, *), let carPlayDashboardScene = self as? CPTemplateApplicationDashboardScene {
            return [carPlayDashboardScene.dashboardWindow]
        }

        Log.info(forMessage: "Found no window attached to the current scene: \(self)")
        return []
    }
}
