import UIKit
import MapboxMaps

@objc(CustomPointAnnotationExample)

public class CustomPointAnnotationExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(with: view.bounds, resourceOptions: resourceOptions())
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Center the map camera over New York City
        let centerCoordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)

        mapView.cameraManager.setCamera(centerCoordinate: centerCoordinate,
                                        zoom: 9.0)

        // Allows the delegate to receive information about map events.
        mapView.on(.mapLoaded) { [weak self] _ in

            guard let self = self else { return }

            /**
             Create the point annotation, using a custom image to mark the location specified.
             The image is referenced from the application's asset catalog.
             */
            let centerCoordinate = self.mapView.centerCoordinate
            let customPointAnnotation = PointAnnotation(coordinate: centerCoordinate,
                                                        image: UIImage(named: "star"))

            // Add the annotation to the map.
            self.mapView.annotationManager.addAnnotation(customPointAnnotation)

            // The below line is used for internal testing purposes only.
            self.finish()
        }
    }
}
