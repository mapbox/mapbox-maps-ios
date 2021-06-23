#  Add a map view

import MapboxMaps

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(mapView)
    }
}
