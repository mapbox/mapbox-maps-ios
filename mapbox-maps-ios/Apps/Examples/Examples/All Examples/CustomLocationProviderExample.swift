import UIKit
import MapboxMaps

@objc(CustomLocationProviderExample)
final class CustomLocationProviderExample: UIViewController, ExampleProtocol {

    var mapView: MapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let centerCoordinate = CLLocationCoordinate2D(latitude: 40.7131854, longitude: -74.0165265)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 10))
        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(mapView)

        // initialize the custom location provoder with the location of your choice
        let customLocationProvider = SimulatedLocationProvider(
            currentLocation: CLLocation(latitude: 40.7131854, longitude: -74.0165265))
        mapView.location.overrideLocationProvider(with: customLocationProvider)
        mapView.location.options.puckType = .puck2D()
        // The following line is just for testing purposes.
        finish()
    }
}
