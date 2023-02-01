import UIKit
import MapboxMaps

@objc(Custom3DPuckExample)
final class Custom3DPuckExample: UIViewController, ExampleProtocol, LocationConsumer {

    private var mapView: MapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.mapboxMap.onNext(event: .styleLoaded) { _ in
            self.setupExample()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         // The below line is used for internal testing purposes only.
        finish()
    }

    private func setupExample() {

        // Fetch the `gltf` asset
        let uri = Bundle.main.url(forResource: "sportcar",
                                  withExtension: "glb")

        // Instantiate the model
        let myModel = Model(uri: uri, orientation: [0, 0, 180])

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

        let configuration = Puck3DConfiguration(model: myModel, modelScale: .expression(scalingExpression), modelOpacity: .constant(0.5))
        mapView.location.options.puckType = .puck3D(configuration)
        mapView.location.options.puckBearingSource = .course

        mapView.location.addLocationConsumer(newConsumer: self)
    }

    internal func locationUpdate(newLocation: Location) {
        mapView.camera.ease(
            to: CameraOptions(
                center: newLocation.coordinate,
                zoom: 15,
                bearing: 0,
                pitch: 55),
            duration: 1,
            curve: .linear,
            completion: nil)
    }
}
