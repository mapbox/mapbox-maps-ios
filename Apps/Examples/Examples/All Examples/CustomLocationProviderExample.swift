import UIKit
import MapboxMaps

final class CustomLocationProviderExample: UIViewController, ExampleProtocol {

    var mapView: MapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let centerCoordinate = CLLocationCoordinate2D(latitude: 40.7131854, longitude: -74.0165265)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 10))
        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(mapView)

        // initialize the custom location provider with the location of your choice
        let location = Location(coordinate: centerCoordinate)
        mapView.location.override(locationProvider: Signal(just: [location]))
        mapView.location.options.puckType = .puck2D(.makeDefault())
        // The following line is just for testing purposes.
        finish()
    }
}
