import UIKit
import MapboxMaps

final class CircleAnnotationExample: UIViewController, ExampleProtocol {
    private lazy var mapView: MapView = MapView(frame: view.bounds)

    override func viewDidLoad() {
        super.viewDidLoad()

        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), zoom: 2)
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions)
        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        /// Create the CircleAnnotationManager
        /// Annotation managers are kept alive by `AnnotationOrchestrator`
        /// (`mapView.annotations`) until you explicitly destroy them
        /// by calling `mapView.annotations.removeAnnotationManager(withId:)`
        let circleAnnotationManager = mapView.annotations.makeCircleAnnotationManager()

        var annotations = [CircleAnnotation]()
        for _ in 0...2000 {
            var annotation = CircleAnnotation(centerCoordinate: .random)
            annotation.circleColor = StyleColor(.random)
            annotation.circleStrokeColor = StyleColor(UIColor.black)
            annotation.circleRadius = 12
            annotation.isDraggable = true
            annotation.circleStrokeWidth = 0

            /// The following handlers add tap and longpress gesture handlers. The `context` parameter
            /// contains the `point` of the gesture in view coordinate system and a geographical `coordinate`.
            annotation.tapHandler = { [id = annotation.id] context in
                let latlon = String(format: "lat: %.3f, lon: %.3f", context.coordinate.latitude, context.coordinate.longitude)
                print("annotation tap: \(id), \(latlon)")
                return true // don't propagate tap to annotations below
            }
            annotation.longPressHandler = { [id = annotation.id] context in
                let latlon = String(format: "lat: %.3f, lon: %.3f", context.coordinate.latitude, context.coordinate.longitude)
                print("annotation longpress: \(id), \(latlon)")
                return true // don't propagate tap to annotations below
            }

            /// The following gesture handlers create the dragging effect.
            /// The dragged annotation becomes larger and receives a stroke.
            ///
            /// - Important: In order to modify the annotation while it is being dragged,
            /// use the inout `annotation` that comes as the first argument to the handler.
            /// Don't use the source annotation that you used to configure it initially.
            /// The annotations are value types.
            ///
            /// The second `context` argument is similar to tap and longpress gestures.
            annotation.dragBeginHandler = { annotation, _ in
                annotation.circleRadius = 22
                annotation.circleStrokeWidth = 2
                print("annotation drag begin: \(annotation.id)")
                return true // allow drag gesture begin
            }
            annotation.dragChangeHandler = { annotation, context in
                let latlon = String(format: "lat: %.3f, lon: %.3f", context.coordinate.latitude, context.coordinate.longitude)
                print("annotation drag: \(annotation.id), \(latlon)")
            }
            annotation.dragEndHandler = { annotation, _ in
                annotation.circleRadius = 12
                annotation.circleStrokeWidth = 0
                print("annotation drag ended: \(annotation.id)")
            }
            annotations.append(annotation)
        }

        circleAnnotationManager.annotations = annotations
        // The following line is just for testing purposes.
        finish()
    }
}
