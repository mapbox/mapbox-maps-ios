import UIKit
import MapboxMaps
import MapboxCoreMaps

@objc(RestrictCoordinateBoundsExample)
final class RestrictCoordinateBoundsExample: UIViewController, ExampleProtocol {

    override func viewDidLoad() {
        super.viewDidLoad()

        let mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        let bounds = CoordinateBounds(southwest: CLLocationCoordinate2D(latitude: 63.33, longitude: -25.52),
                                      northeast: CLLocationCoordinate2D(latitude: 66.61, longitude: -13.47))

        // Restrict the camera to `bounds`.
        try? mapView.mapboxMap.setCameraBounds(with: CameraBoundsOptions(bounds: bounds))

        // Center the camera on the bounds
        let camera = mapView.mapboxMap.camera(for: bounds, padding: .zero, bearing: 0, pitch: 0)

        // Set the camera's center coordinate.
        mapView.mapboxMap.setCamera(to: camera)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         // The below line is used for internal testing purposes only.
        finish()
    }
}
