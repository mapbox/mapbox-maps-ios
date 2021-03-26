import UIKit
import MapboxMaps

@objc(FlyToExample)

public class FlyToExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!
    internal var flyToAnimator: CameraAnimator?

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(with: view.bounds, resourceOptions: resourceOptions())
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Center the map over San Francisco.
        mapView.cameraManager.setCamera(centerCoordinate: .sanfrancisco,
                                        zoom: 15)

        // Allows the view controller to receive information about map events.
        mapView.on(.mapLoaded) { [weak self] _ in
            guard let self = self else { return }
            self.setupExample()
        }

    }

    // Wait for the style to load before adding data to it.
    public func setupExample() {


        let end = CameraOptions(center: .boston,
                                zoom: 15,
                                bearing: 180,
                                pitch: 50)

        
        flyToAnimator = self.mapView.cameraManager.fly(to: end) { [weak self] _ in
            print("Camera fly-to finished")
            // The below line is used for internal testing purposes only.
            self?.flyToAnimator = nil
            self?.finish()
        }
        
    }
}

fileprivate extension CLLocationCoordinate2D {
    static let sanfrancisco = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    static let boston = CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589)
}
