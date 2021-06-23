#  Set the map's style

import MapboxMaps

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let centerCoordinate = CLLocationCoordinate2D(latitude: 39.964175, longitude: -82.955368)
        let cameraOptions = CameraOptions(center: centerCoordinate, zoom: 5.5)
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions, styleURI: .outdoors)

        let mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(mapView)
    }
}
