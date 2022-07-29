import UIKit
import MapboxMaps

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

        var puckConfig = Puck2DConfiguration.makeDefault(showBearing: true)
        puckConfig.pulsing = .default
        puckConfig.pulsing?.radius = .constant(30)
        mapView.location.options.puckType = .puck2D(puckConfig)
        mapView.location.addLocationConsumer(newConsumer: self)
    }
}

extension DebugViewController: LocationConsumer {
    func locationUpdate(newLocation: Location) {
        mapView.mapboxMap.setCamera(to: CameraOptions(center: newLocation.coordinate, zoom: 18))
    }
}
