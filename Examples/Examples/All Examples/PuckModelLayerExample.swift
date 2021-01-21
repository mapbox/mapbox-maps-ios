import UIKit
import MapboxMaps

@objc(PuckModelLayerExample)

public class PuckModelLayerExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.mapView = MapView(with: view.bounds, resourceOptions: resourceOptions())
        self.view.addSubview(mapView)

        self.mapView.on(.styleLoadingFinished) { [weak self] _ in
            guard let self = self else { return }
            self.setupExample()
        }
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         // The below line is used for internal testing purposes only.
        self.finish()
    }

    internal func setupExample() {

        self.mapView.update { (mapOptions) in

            mapOptions.location.showUserLocation = true

            mapOptions.location.locationPuck = .layer3d { (puckModelLayerViewModel) in
                let uri = Bundle.main.url(forResource: "race_car_model",
                                          withExtension: "gltf")

                let myModel = Model(uri: uri,
                                    position: [-177.150925, 39.085006],
                                    orientation: [0, 0, 0])

                puckModelLayerViewModel.model = myModel

                /// Setting an expression to  scale the model based on camera zoom
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

                puckModelLayerViewModel.modelScale = .expression(scalingExpression)
            }
        }

        let coordinate = CLLocationCoordinate2D(latitude: 39.085006, longitude: -77.150925)
        self.mapView.cameraManager.setCamera(centerCoordinate: coordinate,
                                             zoom: 14,
                                             pitch: 80)
    }
}
