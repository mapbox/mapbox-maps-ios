import UIKit
import MapboxMaps
import MapboxCoreMaps

final class RestrictCoordinateBoundsExample: UIViewController, ExampleProtocol {

    override func viewDidLoad() {
        super.viewDidLoad()

        let bounds = CoordinateBounds(southwest: CLLocationCoordinate2D(latitude: 60, longitude: -29),
                                      northeast: CLLocationCoordinate2D(latitude: 70, longitude: -9))

        let mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Restrict the camera to `bounds`.
        try? mapView.mapboxMap.setCameraBounds(with: CameraBoundsOptions(bounds: bounds))

        // Set the camera's center coordinate on the center of the bounds
        mapView.mapboxMap.setCamera(to: .init(center: bounds.center))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         // The below line is used for internal testing purposes only.
        finish()
    }
}
