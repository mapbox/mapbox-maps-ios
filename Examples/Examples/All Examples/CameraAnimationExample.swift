import UIKit
import MapboxMaps

@objc(CameraAnimationExample)

public class CameraAnimationExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        guard let accessToken = AccountManager.shared.accessToken else {
            fatalError("Access token not set")
        }

        let resourceOptions = ResourceOptions(accessToken: accessToken)
        mapView = MapView(with: view.bounds, resourceOptions: resourceOptions)
        self.view.addSubview(mapView)

        // Allows the delegate to receive information about map events.
        mapView.on(.mapLoadingFinished) { [weak self] _ in

            guard let self = self else { return }

            // Center the map camera over New York City.
            let centerCoordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)

            let newCamera = CameraOptions(center: centerCoordinate,
                                          padding: .zero,
                                          anchor: .zero,
                                          zoom: 7.0,
                                          bearing: 180.0,
                                          pitch: 15.0)

            self.mapView.cameraManager.setCamera( to: newCamera,
                                                  animated: true,
                                                  duration: 5.0) { _ in
                // The below line is used for internal testing purposes only.
                self.finish()
            }
        }
    }
}
