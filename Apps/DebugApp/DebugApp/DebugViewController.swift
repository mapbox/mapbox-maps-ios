import UIKit
import MapboxMaps
import CarPlay

/**
 NOTE: This view controller should be used as a scratchpad
 while you develop new features. Changes to this file
 should not be committed.
 */

final class DebugViewController: UIViewController {

    var mapView: MapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(mapView, at: 0)
    }

    func zoomIn() {
        let cameraOptions = CameraOptions(zoom: mapView.cameraState.zoom + 1)
        mapView.camera.ease(to: cameraOptions, duration: 1)
    }

    func zoomOut() {
        let cameraOptions = CameraOptions(zoom: mapView.cameraState.zoom - 1)
        mapView.camera.ease(to: cameraOptions, duration: 1)
    }
}

@available(iOS 12.0, *)
extension DebugViewController: CPMapTemplateDelegate {
    func mapTemplateDidBeginPanGesture(_ mapTemplate: CPMapTemplate) {

    }

    func mapTemplate(_ mapTemplate: CPMapTemplate, didUpdatePanGestureWithTranslation translation: CGPoint, velocity: CGPoint) {

    }

    func mapTemplate(_ mapTemplate: CPMapTemplate, panWith direction: CPMapTemplate.PanDirection) {
        
    }
}

@available(iOS 12.0, *)
final class Foo: CPMapTemplate {
    
}
