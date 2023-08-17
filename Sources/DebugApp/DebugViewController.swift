import UIKit
import MapboxMaps

/**
 NOTE: This view controller should be used as a scratchpad
 while you develop new features. Changes to this file
 should not be committed.
 */

final class DebugViewController: UIViewController {

    var mapView: MapView!

    var cancellables: Set<AnyCancelable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(mapView, at: 0)

        configureStateRestoration(mapView: mapView)

        mapView.mapboxMap.onStyleLoaded.observeNext { [weak self] styleLoaded in
            self?.mapStyleDidLoad(styleLoaded)
        }.store(in: &cancellables)
    }

    func mapStyleDidLoad(_ styleLoaded: StyleLoaded) {

    }
}
