import UIKit
import MapboxMaps

final class CustomPointAnnotationExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private let customImage = UIImage(named: "dest-pin")!
    private var cancelables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Center the map camera over New York City
        let centerCoordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate,
                                                                  zoom: 9.0))

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Allows the delegate to receive information about map events.
        mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
            guard let self = self else { return }
            self.setupExample()

            // The following line is just for testing purposes.
            self.finish()
        }.store(in: &cancelables)
    }

    private func setupExample() {

        // We want to display the annotation at the center of the map's current viewport
        let centerCoordinate = mapView.mapboxMap.cameraState.center

        // Make a `PointAnnotationManager` which will be responsible for managing
        // a collection of `PointAnnotion`s.
        // Annotation managers are kept alive by `AnnotationOrchestrator`
        // (`mapView.annotations`) until you explicitly destroy them
        // by calling `mapView.annotations.removeAnnotationManager(withId:)`
        let pointAnnotationManager = mapView.annotations.makePointAnnotationManager()

        // Initialize a point annotation with a geometry ("coordinate" in this case)
        // and configure it with a custom image (sourced from the asset catalogue)
        var customPointAnnotation = PointAnnotation(coordinate: centerCoordinate)
        customPointAnnotation.image = .init(image: customImage, name: "my-custom-image-name")
        customPointAnnotation.isDraggable = true
        customPointAnnotation.iconOffset = [0, 12]
        customPointAnnotation.tapHandler = { [id = customPointAnnotation.id] _ in
            print("tapped annotation: \(id)")
            return true
        }

        customPointAnnotation.dragBeginHandler = { annotation, _ in
            annotation.iconSize = 1.2
            return true // allow drag gesture begin
        }
        customPointAnnotation.dragEndHandler = { annotation, _ in
            annotation.iconSize = 1
        }

        // Add the annotation to the manager in order to render it on the map.
        pointAnnotationManager.annotations = [customPointAnnotation]
    }
}
