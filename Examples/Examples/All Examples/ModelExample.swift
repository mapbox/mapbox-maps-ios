import UIKit
import MapboxMaps

@objc(ModelExample)

public class ModelExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(with: view.bounds, resourceOptions: resourceOptions())
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.on(.styleLoadingFinished) { [weak self] _ in
            guard let self = self else { return }
            self.setupExample()
        }
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         // The below line is used for internal testing purposes only.
        finish()
    }

    internal func setupExample() {

        let uri = Bundle.main.url(forResource: "race_car_model",
                                  withExtension: "gltf")

        let raceCarModel = Model(uri: uri,
                                 position: [-122.4194, 37.7749],
                                 orientation: [0, 0, 90.0])

        var modelSource = ModelSource()
        modelSource.models = ["race-car": raceCarModel]
        mapView.style.addSource(source: modelSource,
                                identifier: "race-car-model-source")

        var modelLayer = ModelLayer(id: "race-car-model-layer")
        modelLayer.layout?.visibility = .constant(.visible)
        modelLayer.paint?.modelOpacity = .constant(0.8)
        modelLayer.paint?.modelScale = .constant([5.0, 5.0, 5.0])
        modelLayer.source = "race-car-model-source"

        mapView.style.addLayer(layer: modelLayer)

        var skyLayer = SkyLayer(id: "my-sky")
        skyLayer.paint?.skyType = .constant(.gradient)

        mapView.style.addLayer(layer: skyLayer)

        let sanFrancisco = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        mapView.cameraManager.setCamera(centerCoordinate: sanFrancisco,
                                        zoom: 19,
                                        bearing: 0.0,
                                        pitch: 80)
    }
}
