import Foundation
import MapboxMaps

@objc(CircleAnnotationExample)
final class CircleAnnotationExample: UIViewController, ExampleProtocol {
    private lazy var mapView: MapView = MapView(frame: view.bounds)
    var annotation: CircleAnnotation!
    var circleAnnotationManager: CircleAnnotationManager? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Create the CircleAnnotationManager
        // Annotation managers are kept alive by `AnnotationOrchestrator`
        // (`mapView.annotations`) until you explicitly destroy them
        // by calling `mapView.annotations.removeAnnotationManager(withId:)`
        circleAnnotationManager = mapView.annotations.makeCircleAnnotationManager()
        circleAnnotationManager?.delegate = self

        var annotations = [CircleAnnotation]()
        for _ in 0...2000 {
            annotation = CircleAnnotation(centerCoordinate: .random)
            annotation.circleColor = StyleColor(.random)
            annotation.circleRadius = 12
            annotation.isDraggable = true
            annotations.append(annotation)
        }


        self.circleAnnotationManager?.annotations = annotations
        // The following line is just for testing purposes.

        mapView.mapboxMap.onNext(event: .mapLoaded) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.annotation.circleColor = StyleColor(.black)
                self.circleAnnotationManager?.syncSourceAndLayerIfNeeded()

            }
        }
    }
}

extension CircleAnnotationExample: AnnotationInteractionDelegate {
    func annotationManager(_ manager: AnnotationManager, didDetectTappedAnnotations annotations: [Annotation]) {
        print("AnnotationManager did detect tapped annotations: \(annotations)")

    }
}
