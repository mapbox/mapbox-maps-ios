import UIKit
import MapboxMaps
import CoreLocation

@objc(MultiplePointAnnotationsExample)
final class MultiplePointAnnotationsExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the map's initial center coordinate and zoom level.
        let center = CLLocationCoordinate2D(latitude: 24.902556, longitude: 75.323383)
        let camera = CameraOptions(center: center, zoom: 5)
        mapView = MapView(frame: view.bounds, mapInitOptions: MapInitOptions(cameraOptions: camera))
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(mapView)

        // Once the map is fully loaded, add the annotations
        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            self.addAnnotations()
        }
    }

    private func addAnnotations() {
        // Create the first annotation. It will use an image of a red star from the app's assets.
        let coordinate = CLLocationCoordinate2D(latitude: 28.549545, longitude: 77.220154)
        var pointAnnotation1 = PointAnnotation(id: "first-annotation", coordinate: coordinate)
        if let image = UIImage(named: "star") {
            pointAnnotation1.image = .init(image: image, name: "star")
        }

        // Create the second annotation. It will use a custom image from the app's assets.
        let coordinate2 = CLLocationCoordinate2D(latitude: 19.0582239, longitude: 72.880554)
        var pointAnnotation2 = PointAnnotation(id: "second-annotation", coordinate: coordinate2)

        if let image = UIImage(named: "custom_marker") {
            pointAnnotation2.image = .init(image: image, name: "custom-marker")
        }

        // Initialize the map's point annotation manager.
        // Annotation managers are kept alive by `AnnotationOrchestrator`
        // (`mapView.annotations`) until you explicitly destroy them
        // by calling `mapView.annotations.removeAnnotationManager(withId:)`
        let pointAnnotationManager = mapView.annotations.makePointAnnotationManager()

        // Pass the point annotations into the annotation manager.
        // This will add them to the map.
        pointAnnotationManager.annotations = [pointAnnotation2, pointAnnotation1]

        // The next line is used for internal testing purposes only.
        finish()
    }
}
