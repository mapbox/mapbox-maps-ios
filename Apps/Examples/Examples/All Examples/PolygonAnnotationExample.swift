import UIKit
import MapboxMaps

@objc(PolygonAnnotationExample)

public class PolygonAnnotationExample: UIViewController, ExampleProtocol {
    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        let centerCoordinate = CLLocationCoordinate2D(latitude: 25.04579, longitude: -88.90136)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 5.0))

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Allows the delegate to receive information about map events.
        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            self.setupExample()
        }
    }

    // Wait for the map to load before adding an annotation.
    public func setupExample() {

        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]

        // This polygon has an intererior polygon which represents a hole in the shape.
        let polygonHole = [
            CLLocationCoordinate2DMake(25.085598897064752, -89.20898437499999),
            CLLocationCoordinate2DMake(25.085598897064752, -88.61572265625),
            CLLocationCoordinate2DMake(25.720735134412106, -88.61572265625),
            CLLocationCoordinate2DMake(25.720735134412106, -89.20898437499999),
            CLLocationCoordinate2DMake(25.085598897064752, -89.20898437499999)
        ]

        // Create the polygon annotation.
        let polygon = PolygonAnnotation(coordinates: polygonCoords, interiorPolygons: [polygonHole])

        // Add the annotation to the map.
        mapView.annotations.addAnnotation(polygon)

        // The below line is used for internal testing purposes only.
        finish()
    }
}
