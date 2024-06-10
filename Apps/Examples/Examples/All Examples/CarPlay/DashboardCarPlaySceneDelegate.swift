import CarPlay

@available(iOS 13.4, *)
class DashboardCarPlaySceneDelegate: NSObject, CPTemplateApplicationSceneDelegate, CPTemplateApplicationDashboardSceneDelegate {
    let dashboardVC = CarPlayRootVC()

    func templateApplicationDashboardScene(_ templateApplicationDashboardScene: CPTemplateApplicationDashboardScene, didConnect dashboardController: CPDashboardController, to window: UIWindow) {
        window.rootViewController = dashboardVC

        dashboardController.shortcutButtons = [
            CPDashboardButton(titleVariants: ["Start"], subtitleVariants: [], image: UIImage(systemName: "play.square.fill")!, handler: { _ in
                CarPlayViewController.shared.play()
            }),
            CPDashboardButton(titleVariants: ["Stop"], subtitleVariants: [], image: UIImage(systemName: "square.circle.fill")!, handler: { _ in
                CarPlayViewController.shared.stop()
            })
        ]
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        dashboardVC.updateCarPlayViewController(CarPlayViewController.shared)
    }
}
