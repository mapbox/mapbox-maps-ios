import UIKit
import MapboxMaps

@objc(LineAnnotationExample)

public class LineAnnotationExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds, resourceOptions: resourceOptions())
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        let centerCoordinate = CLLocationCoordinate2D(latitude: 39.7128, longitude: -75.0060)

        mapView.cameraManager.setCamera(centerCoordinate: centerCoordinate,
                                        zoom: 5.0)

        // Allows the delegate to receive information about map events.
        mapView.on(.mapLoaded) { [weak self] _ in

            guard let self = self else { return }

            // Line from New York City, NY to Washington, D.C.
            let lineCoordinates = [
                CLLocationCoordinate2DMake(40.7128, -74.0060),
                CLLocationCoordinate2DMake(38.9072, -77.0369)
            ]

            // Create the line annotation.
            let lineAnnotation = LineAnnotation(coordinates: lineCoordinates)

            // Add the annotation to the map.
            self.mapView.annotationManager.addAnnotation(lineAnnotation)

            // The below line is used for internal testing purposes only.
            self.finish()
        }
    }
}
