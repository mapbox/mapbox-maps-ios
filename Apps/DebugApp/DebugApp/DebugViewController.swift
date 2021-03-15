import UIKit
import MapboxMaps
import Turf

/**
 NOTE: This view controller should be used as a scratchpad
 while you develop new features. Changes to this file
 should not be committed.
 */

public class DebugViewController: UIViewController {

    internal var mapView: MapView!

    var resourceOptions: ResourceOptions {
        guard let accessToken = AccountManager.shared.accessToken else {
            fatalError("Access token not set")
        }

        let resourceOptions = ResourceOptions(accessToken: accessToken)
        return resourceOptions
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(with: view.bounds, resourceOptions: resourceOptions)
        mapView.update { (mapOptions) in
            mapOptions.location.showUserLocation = true
        }

        mapView.on(.mapLoadingFinished) { _ in

            let coordinate = CLLocationCoordinate2D(latitude: 39.085006, longitude: -77.150925)
            self.mapView.cameraManager.setCamera(centerCoordinate: coordinate,
                                                 zoom: 12)

            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 10, delay: 2, options: .curveLinear) {

                let coordinate2 = CLLocationCoordinate2D(latitude: 39.085006, longitude: -78.12)
                self.mapView.cameraManager.setCamera(centerCoordinate: coordinate2, zoom: 16)

            } completion: { (_) in
                print("Camera animation complete!!!")
            }
        }
        self.view.addSubview(mapView)
    }
}
