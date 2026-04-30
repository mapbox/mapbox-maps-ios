#if canImport(CarPlay)
import CarPlay
#endif
import UIKit

extension UIWindow {

    var isCarPlay: Bool {
#if canImport(CarPlay)
        return self is CPWindow
#else
        return false
#endif
    }

    /// The scene this window is hosted in, if any.
    ///
    /// `windowScene` is nil for `CPWindow` because `CPTemplateApplicationScene`
    /// is not a `UIWindowScene`. Walking the responder chain recovers the
    /// owning scene uniformly across UIKit and CarPlay..
    var parentScene: UIScene? {
        if let windowScene {
            return windowScene
        }

        #if canImport(CarPlay)
        if let cpWindow = self as? CPWindow {
            return cpWindow.templateApplicationScene
        }
        #endif

        var responder: UIResponder? = next
        while let r = responder {
            if let scene = r as? UIScene {
                return scene
            }
            responder = r.next
        }

        return nil
    }
}

extension UIScene {

    internal var allWindows: [UIWindow] {
        if let windowScene = self as? UIWindowScene {
            return windowScene.windows
        }
#if canImport(CarPlay)
        if let carPlayScene = self as? CPTemplateApplicationScene {
            return [carPlayScene.carWindow]
        } else if let carPlayDashboardScene = self as? CPTemplateApplicationDashboardScene {
            return [carPlayDashboardScene.dashboardWindow]
        } else if #available(iOS 15.4, *), let carPlayInstrumentClusterScene = self as? CPTemplateApplicationInstrumentClusterScene {
            if let instrumentClusterWindow = carPlayInstrumentClusterScene.instrumentClusterController.instrumentClusterWindow {
                return [instrumentClusterWindow]
            } else {
                return []
            }
        }
#endif
        Log.info("Found no window attached to the current scene: \(self)")
        return []
    }
}
