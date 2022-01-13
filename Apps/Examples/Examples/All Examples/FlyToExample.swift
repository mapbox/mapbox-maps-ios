#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
import MapboxMaps

@objc(FlyToExample)

public class FlyToExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Center the map over San Francisco.
        let options = MapInitOptions(cameraOptions: CameraOptions(center: .sanfrancisco, zoom: 15))

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Allows the view controller to receive information about map events.
        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            self.setupExample()
        }
    }

    // Wait for the style to load before adding data to it.
    public func setupExample() {

        let end = CameraOptions(center: .boston,
                                zoom: 15,
                                bearing: 180,
                                pitch: 50)

        _ = mapView.camera.fly(to: end) { [weak self] _ in
            print("Camera fly-to finished")
            // The below line is used for internal testing purposes only.
            self?.finish()
        }
    }
}

fileprivate extension CLLocationCoordinate2D {
    static let sanfrancisco = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    static let boston = CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589)
}
