import Foundation
import MapboxMaps

@objc(BuildingExtrusionsExample)
public class BuildingExtrusionsExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds, styleURI: .light)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.on(.styleLoaded) { [weak self] _ in
            self?.setupExample()
        }
        
        mapView.on(.mapLoaded) { [weak self] (_) in
            var animator = self?.mapView.cameraManager.makeCameraAnimator(duration: 10, curve: .easeInOut, animations: { (transition) in
                transition.zoom.toValue = 17
                transition.pitch.toValue = 75
                transition.bearing.toValue = transition.bearing.fromValue - 50
            })
            
            animator?.addCompletion({ (_) in
                animator = nil
            })
            
            animator?.startAnimation()
        }
    }

    internal func setupExample() {
        addBuildingExtrusions()

        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 40.7135, longitude: -74.0066),
                                          zoom: 12,
                                          bearing: -17.6)
        mapView.cameraManager.setCamera(to: cameraOptions)
    

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
        layer.paint?.fillExtrusionColor   = .constant(ColorRepresentable(color: .lightGray))
        layer.paint?.fillExtrusionOpacity = .constant(0.6)

        layer.filter = Exp(.eq) {
            Exp(.get) {
                "extrude"
            }
            "true"
        }

        layer.paint?.fillExtrusionHeight = .expression(
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

        layer.paint?.fillExtrusionBase = .expression(
            Exp(.interpolate) {
                Exp(.linear)
                Exp(.zoom)
                15
                0
                15.05
                Exp(.get) { "min_height"}
            }
        )

        mapView.style.addLayer(layer: layer)
        
        var sky = SkyLayer(id: "my-sky")
        sky.paint?.skyType = .constant(.atmosphere)
        mapView.style.addLayer(layer: sky)
    }
}
