import UIKit
@_spi(Experimental) import MapboxMaps

// EXPERIMENTAL: Not intended for usage in current stata. Subject to change or deletion.
final class IndoorExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    // Set indoor style. Do not commit staging style URIs.
    private var styleURI: String?
    private var cancellables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        let cameraOptions = CameraOptions(
            center: CLLocationCoordinate2D(latitude: 40.6441, longitude: -73.7824),
            zoom: 16,
            bearing: 12,
            pitch: 60)
        let options = MapInitOptions(cameraOptions: cameraOptions)

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.mapboxMap.styleURI = StyleURI(rawValue: styleURI!)!

        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.ornaments.options.scaleBar.visibility = .visible
        // EXPERIMENTAL: Not intended for usage in current stata. Subject to change or deletion.
        mapView.mapboxMap.indoor.selectFloor(selectedFloorId: "b937e2aa3423453ab0552d9f")
        mapView.mapboxMap.indoor.onIndoorUpdated.sink { indoorState in
             print(indoorState)
        }.store(in: &cancellables)

        view.addSubview(mapView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The below line is used for internal testing purposes only.
        finish()
    }
}
