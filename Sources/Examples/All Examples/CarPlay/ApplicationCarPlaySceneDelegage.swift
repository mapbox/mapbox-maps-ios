import CarPlay

class ApplicationCarPlaySceneDelegage: NSObject, CPTemplateApplicationSceneDelegate {
    let applicationVC = CarPlayRootVC()

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController, to window: CPWindow) {
        window.rootViewController = applicationVC
        let mapTemplate = CPMapTemplate()
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
        interfaceController.setRootTemplate(mapTemplate, animated: false, completion: nil)
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        applicationVC.updateCarPlayViewController(CarPlayViewController.shared)
    }
}
