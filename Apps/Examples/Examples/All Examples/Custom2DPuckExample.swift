import UIKit
import MapboxMaps

@objc(Custom2DPuckExample)
public class Custom2DPuckExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(with: view.bounds, resourceOptions: resourceOptions())
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.on(.styleLoaded) { [weak self] _ in
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

            // Granularly configure the location puck with a `Puck2DConfiguration`
            let configuration = Puck2DConfiguration(topImage: UIImage(named: "star"))
            mapOptions.location.puckType = .puck2D(configuration)
        }

        let coordinate = CLLocationCoordinate2D(latitude: 39.085006, longitude: -77.150925)
        mapView.cameraManager.setCamera(centerCoordinate: coordinate,
                                        zoom: 14,
                                        pitch: 0)
    }
}
