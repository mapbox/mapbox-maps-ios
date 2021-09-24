import UIKit
import MapboxMaps

@objc(UpdatePointAnnotationPositionExample)

public class UpdatePointAnnotationPositionExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    /// Keep a reference to the `PointAnnotationManager` since the annotations will only show if their corresponding manager is alive
    internal lazy var pointAnnotationManager: PointAnnotationManager = {
        return mapView.annotations.makePointAnnotationManager()
    }()

    override public func viewDidLoad() {
        super.viewDidLoad()

        let camera = CameraOptions(center: CLLocationCoordinate2D(latitude: 59.3, longitude: 8.06),
                                   zoom: 12)
        let options = MapInitOptions(cameraOptions: camera)

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Allows the view controller to receive information about map events.
        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            self.addPointAnnotation()
            // The below line is used for internal testing purposes only.
            self.finish()
        }

    }

    public func addPointAnnotation() {
        // Create the point annotation with the default marker image
        var pointAnnotation = PointAnnotation(coordinate: mapView.cameraState.center)
        pointAnnotation.image = .init(image: UIImage(named: "custom_marker")!, name: "custom_marker")

        // Add the annotation to the map
        pointAnnotationManager.annotations = [pointAnnotation]

        // Add a gesture recognizer to the map
        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(updatePosition)))
    }

    @objc public func updatePosition(_ sender: UITapGestureRecognizer) {

        // Get the coordinate of the position tapped on the mapView
        let newCoordinate = mapView.mapboxMap.coordinate(for: sender.location(in: mapView))

        // Create a new point annotation with the new coordinate
        var pointAnnotation = PointAnnotation(coordinate: newCoordinate)
        pointAnnotation.image = .init(image: UIImage(named: "custom_marker")!, name: "custom_marker")

        // Update the annotations being managed by the manager
        pointAnnotationManager.annotations = [pointAnnotation]
    }
}
