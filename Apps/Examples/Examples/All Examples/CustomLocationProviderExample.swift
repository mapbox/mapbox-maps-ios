import UIKit
import MapboxMaps

@objc(CustomLocationProviderExample)
final class CustomLocationProviderExample: UIViewController, ExampleProtocol {

    var mapView: MapView!
    // initialize the custom location provoder with the location of your choice
    var locationProvider = SimulatedLocationProvider(
        currentLocation: CLLocation(latitude: 40.7131854, longitude: -74.0165265)
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        let centerCoordinate = CLLocationCoordinate2D(latitude: 40.7131854, longitude: -74.0165265)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 3))
        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(mapView)

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapDetected(_:)))
        mapView.addGestureRecognizer(recognizer)

        mapView.location.overrideLocationProvider(with: locationProvider)
        mapView.location.options.puckType = .puck2D()
        // The following line is just for testing purposes.
        locationProvider.currentLocation = CLLocation(latitude: 40.7131854, longitude: -74.0165265)
        finish()
    }

    @objc private func tapDetected(_ sender: UITapGestureRecognizer) {
        let tapPoint = sender.location(in: sender.view)
        let tapCoordinate = mapView.mapboxMap.coordinate(for: tapPoint)

        locationProvider.currentLocation = CLLocation(latitude: tapCoordinate.latitude, longitude: tapCoordinate.longitude)
    }
}
