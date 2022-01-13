#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
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
        view.addSubview(mapView)
    }
}
