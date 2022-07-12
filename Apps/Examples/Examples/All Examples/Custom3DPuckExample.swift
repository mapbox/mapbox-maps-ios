import UIKit
@_spi(Experimental) import MapboxMaps

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

    private func setupExample() {
        addBuildingExtrusions()

        // set light configuration for shadow visibility
        var light = Light()
        light.anchor = .map
        light.color = StyleColor(.yellow)
        light.position = [10.0, 40.0, 50.0]
        light.castShadows = .constant(true)
        light.shadowIntensity = .constant(0.7)
        try! mapView.mapboxMap.style.setLight(light)

        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 40.7135, longitude: -74.0066),
                                          zoom: 15.5,
                                          bearing: -17.6,
                                          pitch: 45)
        mapView.mapboxMap.setCamera(to: cameraOptions)

        // The below lines are used for internal testing purposes only.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.finish()
        }

        // add the 3D model to the map to represent the user's location
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

        let configuration = Puck3DConfiguration(model: myModel, modelScale: .expression(scalingExpression), modelRotation: .constant([0.0, 0.0, 180.0]), modelCastShadows: .constant(false))
        mapView.location.options.puckType = .puck3D(configuration)
        mapView.location.options.puckBearingSource = .course

        mapView.location.addLocationConsumer(newConsumer: self)
    }

    // See https://docs.mapbox.com/mapbox-gl-js/example/3d-buildings/ for equivalent gl-js example
    private func addBuildingExtrusions() {
        var layer = FillExtrusionLayer(id: "3d-buildings")

        layer.source                      = "composite"
        layer.minZoom                     = 15
        layer.sourceLayer                 = "building"
        layer.fillExtrusionColor   = .constant(StyleColor(.lightGray))
        layer.fillExtrusionOpacity = .constant(0.6)

        layer.filter = Exp(.eq) {
            Exp(.get) {
                "extrude"
            }
            "true"
        }

        layer.fillExtrusionHeight = .expression(
            Exp(.get) { "height" }
        )

        layer.fillExtrusionBase = .expression(
            Exp(.get) { "min_height"}
        )

        layer.fillExtrusionAmbientOcclusionIntensity = .constant(0.3)

        layer.fillExtrusionAmbientOcclusionRadius = .constant(3.0)

        try! mapView.mapboxMap.style.addLayer(layer)
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
