import UIKit
import MapboxMaps

@objc(CustomPointAnnotationExample)
final class CustomPointAnnotationExample: UIViewController, ExampleProtocol {

    private var mapView: MapView!
    private let customImage = UIImage(named: "star")!

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
        mapView.mapboxMap.onNext(event: .mapLoaded) { [weak self] _ in
            guard let self = self else { return }
            self.setupExample()

            // The following line is just for testing purposes.
            self.finish()
        }
    }

    private func setupExample() {

        // We want to display the annotation at the center of the map's current viewport
        let centerCoordinate = mapView.cameraState.center

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

        pointAnnotationManager.delegate = self
        // Add the annotation to the manager in order to render it on the map.
        pointAnnotationManager.annotations = [customPointAnnotation]
    }
}

extension CustomPointAnnotationExample: AnnotationInteractionDelegate {
    func annotationManager(_ manager: MapboxMaps.AnnotationManager, didDetectTappedAnnotations annotations: [MapboxMaps.Annotation]) {
        print("AnnotationManager did detect tapped annotations: \(annotations)")
    }
}
