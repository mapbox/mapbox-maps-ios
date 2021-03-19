import UIKit
import MapboxMaps

@objc(PuckModelLayerExample)

public class PuckModelLayerExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(with: view.bounds, resourceOptions: resourceOptions())
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.on(.styleLoaded) { [weak self] _ in
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

        mapView.update { (mapOptions) in

            mapOptions.location.showUserLocation = true

            // Fetch the `gltf` asset
            let uri = Bundle.main.url(forResource: "race_car_model",
                                      withExtension: "gltf")

            // Instantiate the model
            let myModel = Model(uri: uri,
                                position: [-177.150925, 39.085006],
                                orientation: [0, 0, 0])

            // Setting an expression to  scale the model based on camera zoom
            let scalingExpression = Exp(.interpolate) {
                Exp(.linear)
                Exp(.zoom)
                0
                Exp(.literal) {
                    [256000.0, 256000.0, 256000.0]
                }
                4
                Exp(.literal) {
                    [40000.0, 40000.0, 40000.0]
                }
                8
                Exp(.literal) {
                    [2000.0, 2000.0, 2000.0]
                }
                12
                Exp(.literal) {
                    [100.0, 100.0, 100.0]
                }
                16
                Exp(.literal) {
                    [7.0, 7.0, 7.0]
                }
                20
                Exp(.literal) {
                    [1.0, 1.0, 1.0]
                }
            }

            let puckModelLayerViewModel = PuckModelLayerViewModel(model: myModel, modelScale: .expression(scalingExpression))
            mapOptions.location.locationPuck = .puck3D(puckModelLayerViewModel)
        }

        let coordinate = CLLocationCoordinate2D(latitude: 39.085006, longitude: -77.150925)
        mapView.cameraManager.setCamera(centerCoordinate: coordinate,
                                        zoom: 14,
                                        pitch: 80)
    }
}
