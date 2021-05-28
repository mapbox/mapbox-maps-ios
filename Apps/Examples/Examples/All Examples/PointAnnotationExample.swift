import UIKit
import MapboxMaps

@objc(PointAnnotationExample)

public class PointAnnotationExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!
    private var pointAnnotationManager: PointAnnotationManager?

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Center the map camera over Copenhagen.
        let centerCoordinate = CLLocationCoordinate2D(latitude: 55.665957, longitude: 12.550343)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 8.0))

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Allows the delegate to receive information about map events.
        mapView.mapboxMap.onNext(.mapLoaded) { [weak  self] _ in

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

        // Make the annotation show the default red pin
        customPointAnnotation.image = .default

        // Add the annotation to the manager in order to render it on the mao.
        pointAnnotationManager.syncAnnotations([customPointAnnotation])

        // The annotations added above will show as long as the `PointAnnotationManager` is alive,
        // so keep a reference to it.
        self.pointAnnotationManager = pointAnnotationManager
    }
}
