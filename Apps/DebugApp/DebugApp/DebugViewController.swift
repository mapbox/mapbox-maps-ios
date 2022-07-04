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
        MapView.shared = mapView
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

//        mapView.gestures.options.simultaneousRotateAndPinchZoomEnabled = false
        mapView.gestures.delegate = self
//        mapView.location.options.puckType = .puck2D(.makeDefault())
//        mapView.location.options.puckBearingSource = .course
    }
}

extension DebugViewController: GestureManagerDelegate {
    func gestureManager(_ gestureManager: GestureManager, didBegin gestureType: GestureType) {
        print("fff begin \(gestureType)")
    }

    func gestureManager(_ gestureManager: GestureManager, didEnd gestureType: GestureType, willAnimate: Bool) {
        print("fff end \(gestureType) willAnimate: \(willAnimate)")

    }

    func gestureManager(_ gestureManager: GestureManager, didEndAnimatingFor gestureType: GestureType) {
        print("fff didEndAnimatingFor \(gestureType)")
    }
}
