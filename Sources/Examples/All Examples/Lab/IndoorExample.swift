import UIKit
@_spi(Experimental) import MapboxMaps

// EXPERIMENTAL: Not intended for usage in current stata. Subject to change or deletion.
final class IndoorExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var styleURI: String?
    private var cancellables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        let cameraOptions = CameraOptions(
            center: CLLocationCoordinate2D(latitude: 35.5483, longitude: 139.7780),
            zoom: 16,
            bearing: 12,
            pitch: 60)

        let options = MapInitOptions(cameraOptions: cameraOptions)
        mapView = MapView(frame: view.bounds, mapInitOptions: options)

        mapView.ornaments.options.scaleBar.visibility = .visible
        mapView.ornaments.options.indoorSelector.visibility = .visible

        var puckConfiguration = Puck2DConfiguration.makeDefault(showBearing: true)
        puckConfiguration.pulsing = nil
        mapView.location.options.puckType = .puck2D(puckConfiguration)

        mapView.location.onLocationChange.observeNext { [weak mapView] newLocation in
            guard let mapView, let location = newLocation.last else { return }
            mapView.mapboxMap.setCamera(to: .init(center: location.coordinate, zoom: 18))
        }.store(in: &cancellables)

        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        mapView.mapboxMap.indoor.onIndoorUpdated.sink { indoorState in
             print("Selected floor id: \(indoorState.selectedFloorId)")
        }.store(in: &cancellables)
        view.addSubview(mapView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The below line is used for internal testing purposes only.
        finish()
    }
}
