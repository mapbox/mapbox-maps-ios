import UIKit
import MapboxMaps

@objc(LineAnnotationExample)

public class LineAnnotationExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        let centerCoordinate = CLLocationCoordinate2D(latitude: 39.7128, longitude: -75.0060)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 5.0))

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Allows the delegate to receive information about map events.
        mapView.mapboxMap.on(.mapLoaded) { _ in

            // Line from New York City, NY to Washington, D.C.
            let lineCoordinates = [
                CLLocationCoordinate2DMake(40.7128, -74.0060),
                CLLocationCoordinate2DMake(38.9072, -77.0369)
            ]

            // Create the line annotation.
            let lineAnnotation = LineAnnotation(coordinates: lineCoordinates)

            // Add the annotation to the map.
            self.mapView.annotations.addAnnotation(lineAnnotation)

            // The below line is used for internal testing purposes only.
            self.finish()

            return true
        }
    }
}
