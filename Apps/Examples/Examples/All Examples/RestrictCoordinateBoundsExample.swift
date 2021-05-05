import UIKit
import MapboxMaps
import MapboxCoreMaps

@objc(RestrictCoordinateBoundsExample)

public class RestrictCoordinateBoundsExample: UIViewController, ExampleProtocol {

    override public func viewDidLoad() {
        super.viewDidLoad()

        let mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        let bounds = CoordinateBounds(southwest: CLLocationCoordinate2D(latitude: 63.33, longitude: -25.52),
                                      northeast: CLLocationCoordinate2D(latitude: 66.61, longitude: -13.47))
        let camera = mapView.mapboxMap.camera(for: bounds, padding: .zero, bearing: 0, pitch: 0)
        // Set the camera's center coordinate.
        mapView.camera.setCamera(to: camera)

        mapView.update { (mapOptions) in
            mapOptions.camera.restrictedCoordinateBounds = bounds
        }
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         // The below line is used for internal testing purposes only.
        finish()
    }
}
