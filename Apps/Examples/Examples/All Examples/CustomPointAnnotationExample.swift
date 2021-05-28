import UIKit
import MapboxMaps

@objc(CustomPointAnnotationExample)

public class CustomPointAnnotationExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!
    internal var pointAnnotationManager: PointAnnotationManager?
    private lazy var customImage: UIImage = {
        UIImage(named: "star")!
    }()

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
        mapView.mapboxMap.onNext(.mapLoaded) { [weak self] _ in

            guard let self = self else { return }
            self.setupExample()

            // The below line is used for internal testing purposes only.
            self.finish()
        }
    }

    func setupExample() {

        // We want to display the annotation at the center of the map's current viewport
        let centerCoordinate = mapView.cameraState.center

        // Make a `PointAnnotationManager` which will be responsible for managing a collection of `PointAnnotion`s.
        let pointAnnotationManager = mapView.annotations.makePointAnnotationManager()

        // Initialize a point annotation with a geometry ("coordinate" in this case)
        // and configure it with a custom image (sourced from the asset catalogue)
        var customPointAnnotation = PointAnnotation(coordinate: centerCoordinate)
        customPointAnnotation.image = .custom(image: customImage, name: "my-custom-image-name")

        // Add the annotation to the manager in order to render it on the mao.
        pointAnnotationManager.syncAnnotations([customPointAnnotation])

        // The annotations added above will show as long as the `PointAnnotationManager` is alive,
        // so keep a reference to it.
        self.pointAnnotationManager = pointAnnotationManager
    }
}
