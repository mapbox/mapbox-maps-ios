import UIKit
@_spi(Experimental) import MapboxMaps

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

        mapView.location.options.puckType = .puck2D(.makeDefault())
        mapView.location.options.puckBearingSource = .course

        mapView.mapboxMap.loadStyleURI(StyleURI.init(rawValue: "mapbox://styles/mapbox-map-design/ckvmcnpk54xxy15tjy15i9pij")!)
        let followPuckViewportState = mapView.viewport.makeFollowPuckViewportState(
            options: FollowPuckViewportStateOptions(
                bearing: .course)
        )
        mapView.viewport.transition(to: followPuckViewportState)
    }
}
