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

        self.view.addSubview(mapView)

        mapView.on(.mapLoadingFinished) { [weak self] _ in
            guard let self = self else { return }

            self.mapView.update {
                $0.ornaments.showsScale = false
                $0.location.showUserLocation = true

//                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                    self.mapView.cameraManager.setCamera(bearing: 90, animated: true, duration: 2.0, completion: nil)
//                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    self.mapView.cameraManager.setCamera(bearing: 270, animated: true, duration: 2.0, completion: nil)
                }
            }
        }
    }
}
