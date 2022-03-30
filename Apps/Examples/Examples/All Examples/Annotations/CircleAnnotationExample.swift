import Foundation
import MapboxMaps

@objc(CircleAnnotationExample)
final class CircleAnnotationExample: UIViewController, ExampleProtocol {
    private lazy var mapView: MapView = {
        MapView(frame: view.bounds)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Create the CircleAnnotationManager
        // Annotation managers are kept alive by `AnnotationOrchestrator`
        // (`mapView.annotations`) until you explicitly destroy them
        // by calling `mapView.annotations.removeAnnotationManager(withId:)`
        let circleAnnotationManager = mapView.annotations.makeCircleAnnotationManager()
        circleAnnotationManager.delegate = self

        var annotations = [CircleAnnotation]()
        for _ in 0...2000 {
            var annotation = CircleAnnotation(centerCoordinate: .random)
            annotation.circleColor = StyleColor(.random)
            annotation.circleRadius = 12
            annotations.append(annotation)
        }

        circleAnnotationManager.annotations = annotations
        // The following line is just for testing purposes.
        finish()
    }
}

extension CircleAnnotationExample: AnnotationInteractionDelegate {
    func annotationManager(_ manager: AnnotationManager, didDetectTappedAnnotations annotations: [Annotation]) {
        print("AnnotationManager did detect tapped annotations: \(annotations)")
    }
}
