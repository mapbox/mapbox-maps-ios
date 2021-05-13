import UIKit
import MapboxMaps

@objc(Custom2DPuckExample)
public class Custom2DPuckExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.mapboxMap.onNext(.styleLoaded) { _ in
            self.setupExample()
        }
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The below line is used for internal testing purposes only.
        finish()
    }

    internal func setupExample() {

        // Granularly configure the location puck with a `Puck2DConfiguration`
        let configuration = Puck2DConfiguration(topImage: UIImage(named: "star"))
        mapView.location.options.puckType = .puck2D(configuration)

        let coordinate = CLLocationCoordinate2D(latitude: 39.085006, longitude: -77.150925)
        mapView.camera.setCamera(to: CameraOptions(center: coordinate,
                                                          zoom: 14,
                                                          pitch: 0))
    }
}
