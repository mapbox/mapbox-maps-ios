import UIKit
import MapboxMaps

@objc(CustomPointAnnotationExample)

public class CustomPointAnnotationExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Center the map camera over New York City
        let centerCoordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate,
                                                                  zoom: 9.0))

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Allows the delegate to receive information about map events.
        mapView.on(.mapLoaded) { [weak self] _ in

            guard let self = self else { return }

            /**
             Create the point annotation, using a custom image to mark the location specified.
             The image is referenced from the application's asset catalog.
             */
            let centerCoordinate = self.mapView.cameraState.center
            let customPointAnnotation = PointAnnotation(coordinate: centerCoordinate,
                                                        image: UIImage(named: "star"))

            // Add the annotation to the map.
            self.mapView.annotations.addAnnotation(customPointAnnotation)

            // The below line is used for internal testing purposes only.
            self.finish()
        }
    }
}
