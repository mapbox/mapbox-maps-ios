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

        mapView.location.delegate = self
        mapView.location.options.puckType = .puck2D(.makeDefault(showBearing: true))
        mapView.location.options.puckBearingSource = .heading
        mapView.location.options.puckBearingEnabled = true

        mapView.viewport.transition(to: mapView.viewport.makeFollowPuckViewportState())
    }
}

extension DebugViewController: LocationManagerDelegate {
    func locationManagerShouldDisplayHeadingCalibration(_ locationManager: LocationManager) -> Bool {
        return true
    }
}
