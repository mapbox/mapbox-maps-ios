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

        self.mapView = MapView(with: view.bounds, resourceOptions: resourceOptions)
        mapView.update { (mapOptions) in
            mapOptions.location.showUserLocation = true
        }

        let centerCoordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)

        mapView.cameraManager.setCamera(centerCoordinate: centerCoordinate, padding: nil, anchor: nil, zoom: 7, bearing: nil, pitch: 45 , animated: true, duration: nil, completion: nil)

        self.view.addSubview(mapView)
    }
}
