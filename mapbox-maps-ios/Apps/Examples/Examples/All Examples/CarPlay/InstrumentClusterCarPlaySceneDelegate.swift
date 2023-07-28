import CarPlay
import MapboxMaps

@available(iOS 15.4, *)
class InstrumentClusterCarPlaySceneDelegate: NSObject,
                                                CPTemplateApplicationInstrumentClusterSceneDelegate,
                                                CPInstrumentClusterControllerDelegate {

    func instrumentClusterControllerDidConnect(_ instrumentClusterWindow: UIWindow) {
        instrumentClusterWindow.rootViewController = carPlayController
    }

    func instrumentClusterControllerDidDisconnectWindow(_ instrumentClusterWindow: UIWindow) {
        instrumentClusterWindow.rootViewController = nil
    }

    func instrumentClusterControllerDidZoom(in instrumentClusterController: CPInstrumentClusterController) {
        guard let carPlayController = carPlayController else { return }

        let cameraState = carPlayController.mapView.mapboxMap.cameraState
        carPlayController.mapView.camera.ease(to: .init(zoom: cameraState.zoom + 1),
                                              duration: 0.3)
    }

    func instrumentClusterControllerDidZoomOut(_ instrumentClusterController: CPInstrumentClusterController) {
        guard let carPlayController = carPlayController else { return }

        let cameraState = carPlayController.mapView.mapboxMap.cameraState
        carPlayController.mapView.camera.ease(to: .init(zoom: cameraState.zoom - 1),
                                              duration: 0.3)
    }

    func contentStyleDidChange(_ contentStyle: UIUserInterfaceStyle) {
        let style: StyleURI
        switch contentStyle {
        case .dark:
            style = .dark
        default:
            style = .light
        }
        carPlayController?.mapView.mapboxMap.styleURI = style
    }

    func instrumentClusterController(_ instrumentClusterController: CPInstrumentClusterController,
                                     didChangeCompassSetting compassSetting: CPInstrumentClusterSetting) {
        let compassVisibility: OrnamentVisibility
        switch compassSetting {
        case .enabled:
            compassVisibility = .visible
        case .disabled:
            compassVisibility = .hidden
        default:
            compassVisibility = .adaptive
        }
        carPlayController?.mapView.ornaments.options.compass.visibility = compassVisibility
    }

    func instrumentClusterController(_ instrumentClusterController: CPInstrumentClusterController,
                                     didChangeSpeedLimitSetting speedLimitSetting: CPInstrumentClusterSetting) {
        // Do nothing, prevent runtime crash
    }

    var carPlayController: CarPlayViewController?

    func templateApplicationInstrumentClusterScene(_ templateApplicationInstrumentClusterScene: CPTemplateApplicationInstrumentClusterScene, didConnect instrumentClusterController: CPInstrumentClusterController) {
        carPlayController = CarPlayViewController()
        instrumentClusterController.delegate = self
    }

    func templateApplicationInstrumentClusterScene(_ templateApplicationInstrumentClusterScene: CPTemplateApplicationInstrumentClusterScene, didDisconnectInstrumentClusterController instrumentClusterController: CPInstrumentClusterController) {
        carPlayController = nil
    }
}
