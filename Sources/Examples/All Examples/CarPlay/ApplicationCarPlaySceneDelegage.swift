import CarPlay

class ApplicationCarPlaySceneDelegage: NSObject, CPTemplateApplicationSceneDelegate {
    let applicationVC = CarPlayRootVC()
    private var mapTemplate: CPMapTemplate?
    private var isNavigating = false

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController, to window: CPWindow) {
        window.rootViewController = applicationVC
        let mapTemplate = CPMapTemplate()
        self.mapTemplate = mapTemplate
        updateLeadingButtons()

        interfaceController.setRootTemplate(mapTemplate, animated: false, completion: nil)
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        applicationVC.updateCarPlayViewController(CarPlayViewController.shared)
    }

    private func updateLeadingButtons() {
        if isNavigating {
            mapTemplate?.leadingNavigationBarButtons = [
                CPBarButton(title: "Exit") { [weak self] _ in
                    self?.switchMode(navigating: false)
                },
            ]
            mapTemplate?.trailingNavigationBarButtons = []
        } else {
            mapTemplate?.leadingNavigationBarButtons = [
                CPBarButton(title: "Start") { _ in
                    CarPlayViewController.shared.play()
                },
                CPBarButton(title: "Navigate") { [weak self] _ in
                    self?.switchMode(navigating: true)
                }
            ]
            mapTemplate?.trailingNavigationBarButtons = [
                CPBarButton(title: "Stop") { _ in
                    CarPlayViewController.shared.stop()
                }
            ]
        }
    }

    private func switchMode(navigating: Bool) {
        isNavigating = navigating
        applicationVC.updateCarPlayViewController(
            navigating ? CarPlayNavViewController.shared : CarPlayViewController.shared
        )
        updateLeadingButtons()
    }
}
