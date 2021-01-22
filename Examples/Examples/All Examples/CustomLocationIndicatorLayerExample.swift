import UIKit
import MapboxMaps

@objc(CustomLocationIndicatorLayerExample)

public class CustomLocationIndicatorLayerExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.mapView = MapView(with: view.bounds, resourceOptions: resourceOptions())
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(mapView)

        self.mapView.on(.styleLoadingFinished) { [weak self] _ in
            guard let self = self else { return }
            self.setupExample()
        }
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         // The below line is used for internal testing purposes only.
        self.finish()
    }

    internal func setupExample() {

        self.mapView.update { (mapOptions) in
            mapOptions.location.showUserLocation = true
            mapOptions.location.locationPuck = .puck2D(customize: { (locationIndicatorLayerVM) in

                let topImage = UIImage(named: "star")
                locationIndicatorLayerVM.topImage = topImage
                // Perform additional styling here
            })
        }

        let coordinate = CLLocationCoordinate2D(latitude: 39.085006, longitude: -77.150925)
        self.mapView.cameraManager.setCamera(centerCoordinate: coordinate,
                                             zoom: 14,
                                             pitch: 0)
    }
}
