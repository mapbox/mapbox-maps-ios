import Foundation
import MapboxMaps

@objc(BuildingExtrusionsExample)
public class BuildingExtrusionsExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        let options = MapInitOptions(styleURI: .light)
        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.mapboxMap.onNext(.styleLoaded) { _ in
            self.setupExample()
        }
    }

    internal func setupExample() {
        addBuildingExtrusions()

        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 40.7135, longitude: -74.0066),
                                          zoom: 15.5,
                                          bearing: -17.6,
                                          pitch: 45)
        mapView.camera.setCamera(to: cameraOptions)

        // The below lines are used for internal testing purposes only.
        DispatchQueue.main.asyncAfter(deadline: .now()+5.0) {
            self.finish()
        }
    }

    // See https://docs.mapbox.com/mapbox-gl-js/example/3d-buildings/ for equivalent gl-js example
    internal func addBuildingExtrusions() {
        var layer = FillExtrusionLayer(id: "3d-buildings")

        layer.source                      = "composite"
        layer.minZoom                     = 15
        layer.sourceLayer                 = "building"
        layer.fillExtrusionColor   = .constant(ColorRepresentable(color: .lightGray))
        layer.fillExtrusionOpacity = .constant(0.6)

        layer.filter = Exp(.eq) {
            Exp(.get) {
                "extrude"
            }
            "true"
        }

        layer.fillExtrusionHeight = .expression(
            Exp(.interpolate) {
                Exp(.linear)
                Exp(.zoom)
                15
                0
                15.05
                Exp(.get) {
                    "height"
                }
            }
        )

        layer.fillExtrusionBase = .expression(
            Exp(.interpolate) {
                Exp(.linear)
                Exp(.zoom)
                15
                0
                15.05
                Exp(.get) { "min_height"}
            }
        )

        try! mapView.mapboxMap.style.addLayer(layer)
    }
}
