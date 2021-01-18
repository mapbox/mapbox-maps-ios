import UIKit
import MapboxMaps

@objc(PointAnnotationExample)

public class PointAnnotationExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(with: view.bounds, resourceOptions: resourceOptions())

        self.view.addSubview(mapView)

        // Center the map camera over New York City.
        let centerCoordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)

        mapView.cameraManager.setCamera(centerCoordinate: centerCoordinate,
                                                  zoom: 9.0)

        // Allows the delegate to receive information about map events.
        mapView.on(.mapLoadingFinished) { [weak self] _ in

            guard let self = self else { return }

            // Create the point annotation, which will be rendered with the default red pin.
            let centerCoordinate = self.mapView.cameraView.centerCoordinate
            let pointAnnotation = PointAnnotation(coordinate: centerCoordinate)

            // Add the annotation to the map.
            self.mapView.annotationManager.addAnnotation(pointAnnotation)

            // The below line is used for internal testing purposes only.
            self.finish()
        }
    }
}
