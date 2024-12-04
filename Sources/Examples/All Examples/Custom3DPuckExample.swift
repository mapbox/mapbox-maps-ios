import UIKit
import MapboxMaps

final class Custom3DPuckExample: UIViewController, ExampleProtocol {
    private var cancelables = Set<AnyCancelable>()
    private var mapView: MapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 37.26301831966747, longitude: -121.97647612483807), zoom: 15, pitch: 55)
        mapView = MapView(frame: view.bounds, mapInitOptions: MapInitOptions(cameraOptions: cameraOptions))
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.mapboxMap.onStyleLoaded.observeNext { _ in
            self.setupExample()
        }.store(in: &cancelables)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         // The below line is used for internal testing purposes only.
        finish()
    }

    private func setupExample() {

        // Fetch the `gltf` asset
        let uri = Bundle.main.url(forResource: "sportcar", withExtension: "glb")

        // Instantiate the model
        let myModel = Model(uri: uri, orientation: [0, 0, 180])

        let configuration = Puck3DConfiguration(
            model: myModel,
            modelScale: .constant([10, 10, 10]),
            modelOpacity: .constant(0.5),
            layerPosition: .default
        )
        mapView.location.options.puckType = .puck3D(configuration)
        mapView.location.options.puckBearing = .course
        mapView.location.options.puckBearingEnabled = true

        mapView.location.onLocationChange.observeNext { [weak mapView] newLocation in
            guard let location = newLocation.last, let mapView else { return }
            mapView.camera.ease(
                to: CameraOptions(
                    center: location.coordinate,
                    zoom: 15,
                    bearing: 0,
                    pitch: 55),
                duration: 1,
                curve: .linear,
                completion: nil)
        }.store(in: &cancelables)
    }
}
