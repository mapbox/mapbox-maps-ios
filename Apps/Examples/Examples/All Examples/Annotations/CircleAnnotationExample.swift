import Foundation
import MapboxMaps

@objc(CircleAnnotationExample)
final class CircleAnnotationExample: UIViewController, ExampleProtocol {
    private lazy var mapView: MapView = MapView(frame: view.bounds)

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Create the CircleAnnotationManager
        // Annotation managers are kept alive by `AnnotationOrchestrator`
        // (`mapView.annotations`) until you explicitly destroy them
        // by calling `mapView.annotations.removeAnnotationManager(withId:)`
        let circleAnnotationManager = mapView.annotations.makeCircleAnnotationManager()

        var annotations = [CircleAnnotation]()
        for _ in 0...2000 {
            var annotation = CircleAnnotation(centerCoordinate: .random)
            annotation.circleColor = StyleColor(.random)
            annotation.circleRadius = 12
            annotation.isDraggable = true
            annotations.append(annotation)
        }

        circleAnnotationManager.annotations = annotations
        // The following line is just for testing purposes.
        finish()
    }
}
