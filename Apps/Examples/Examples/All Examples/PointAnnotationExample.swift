import UIKit
import MapboxMaps

@objc(PointAnnotationExample)

public class PointAnnotationExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(with: view.bounds, resourceOptions: resourceOptions())
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Center the map camera over Copenhagen.
        let centerCoordinate = CLLocationCoordinate2D(latitude: 55.665957, longitude: 12.550343)

        mapView.cameraManager.setCamera(centerCoordinate: centerCoordinate,
                                        zoom: 8.0)

        // Allows the delegate to receive information about map events.
        mapView.on(.mapLoaded) { [weak self] _ in

            guard let self = self else { return }

            // Create the point annotation, which will be rendered with the default red pin.
            let centerCoordinate = self.mapView.centerCoordinate
            let pointAnnotation = PointAnnotation(coordinate: centerCoordinate)

            // Add the annotation to the map.
            self.mapView.annotationManager.addAnnotation(pointAnnotation)

            // The below line is used for internal testing purposes only.
            self.finish()
        }
    }
}
