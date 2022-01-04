import UIKit
import MapboxMaps
import CoreLocation

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
        mapView.location.options.puckType = .puck2D()

        let followingState = mapView.viewport.makeFollowingViewportState()
        mapView.viewport.addState(followingState)

        let helsinki = CLLocationCoordinate2D(latitude: 60.1699, longitude: 24.9384)
        let helsinkiPolygon = Polygon(center: helsinki, radius: 2000, vertices: 200)
        let overviewState = mapView.viewport.makeOverviewViewportState(options: .init(geometry: helsinkiPolygon))
        mapView.viewport.addState(overviewState)

        let immediateTransition = mapView.viewport.makeImmediateViewportTransition()
        mapView.viewport.setTransition(immediateTransition, from: nil, to: followingState)

        mapView.viewport.transition(to: followingState)
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.mapView.viewport.transition(to: overviewState)
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                self.mapView.viewport.transition(to: followingState)
            }
        }
    }
}
