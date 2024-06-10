import CarPlay

@available(iOS 13.0, *)
class ApplicationCarPlaySceneDelegage: NSObject, CPTemplateApplicationSceneDelegate {
    let applicationVC = CarPlayRootVC()

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController, to window: CPWindow) {
        window.rootViewController = applicationVC
        let mapTemplate = CPMapTemplate()
        if #available(iOS 14.0, *) {
            mapTemplate.leadingNavigationBarButtons = [
                CPBarButton(title: "Start") { _ in
                    CarPlayViewController.shared.play()
                }
            ]
            mapTemplate.trailingNavigationBarButtons = [
                CPBarButton(title: "Stop") { _ in
                    CarPlayViewController.shared.stop()
                }
            ]
        }
        interfaceController.setRootTemplate(mapTemplate, animated: false)
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        applicationVC.updateCarPlayViewController(CarPlayViewController.shared)
    }
}
