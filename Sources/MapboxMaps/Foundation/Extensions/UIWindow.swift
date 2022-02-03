import UIKit

@available(iOS 13.0, *)
extension UIWindow {
    private static let templateApplicationSceneSelector = Selector(("templateApplicationScene"))

    internal var parentScene: UIScene? {
        var carPlayScene: UIScene? {
            guard self.responds(to: UIWindow.templateApplicationSceneSelector) else {
                return nil
            }
            return self.value(forKey: UIWindow.templateApplicationSceneSelector.description) as? UIScene
        }
        return windowScene ?? carPlayScene
    }
}
