import UIKit
import MapboxMaps

@objc(FlyToExample)

public class FlyToExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(with: view.bounds, resourceOptions: resourceOptions())
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Center the map over the United States.
        let centerCoordinate = CLLocationCoordinate2D(latitude: 40.58058466412761,
                                                      longitude: -97.734375)

        mapView.cameraManager.setCamera(centerCoordinate: centerCoordinate,
                                        zoom: 3)

        // Allows the view controller to receive information about map events.
        mapView.on(.mapLoaded) { [weak self] _ in
            guard let self = self else { return }
            self.setupExample()
        }

    }

    // Wait for the style to load before adding data to it.
    public func setupExample() {
        let start = CameraOptions(center: .sanfrancisco,
                                  zoom: 15,
                                  bearing: 0,
                                  pitch: 0)

        let end = CameraOptions(center: .boston,
                                zoom: 15,
                                bearing: 180,
                                pitch: 50)

        mapView.cameraManager.setCamera(to: start) { _ in
            let animator = self.mapView.cameraManager.flyTo(to: end)
            animator?.startAnimation()
        }
    }
}

fileprivate extension CLLocationCoordinate2D {
    static let sanfrancisco = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    static let boston = CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589)
}
