import UIKit
import MapboxMaps

@objc(CustomLocationIndicatorLayerExample)

public class CustomLocationIndicatorLayerExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(with: view.bounds, resourceOptions: resourceOptions())
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.on(.styleLoadingFinished) { [weak self] _ in
            guard let self = self else { return }
            self.setupExample()
        }
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The below line is used for internal testing purposes only.
        finish()
    }

    internal func setupExample() {

        mapView.update { (mapOptions) in
            mapOptions.location.showUserLocation = true

            // Granularly style the location puck with a `LocationIndicatorLayerViewModel`
            let locationIndicatorLayerVM = LocationIndicatorLayerViewModel(topImage: UIImage(named: "star"))
            mapOptions.location.locationPuck = .puck2D(locationIndicatorLayerVM)
        }

        let coordinate = CLLocationCoordinate2D(latitude: 39.085006, longitude: -77.150925)
        mapView.cameraManager.setCamera(centerCoordinate: coordinate,
                                        zoom: 14,
                                        pitch: 0)
    }
}
