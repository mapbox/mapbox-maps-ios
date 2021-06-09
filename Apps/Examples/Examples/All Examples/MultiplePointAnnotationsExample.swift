import UIKit
import MapboxMaps
import CoreLocation

@objc(MultiplePointAnnotationsExample)
public class MultiplePointAnnotationsExample: UIViewController, ExampleProtocol {
    internal var mapView: MapView!

    internal lazy var pointAnnotationManager: PointAnnotationManager = {
        return mapView.annotations.makePointAnnotationManager()
    }()

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(mapView)
        
        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            self.addAnnotations()
        }
    }
    
    func addAnnotations() {
        let coordinate1 = CLLocationCoordinate2D(latitude: 28.549545, longitude: 77.220154)
        var pointAnnotation1 = PointAnnotation(id: "first-annotation", coordinate: coordinate1)
        pointAnnotation1.image = .default
        
        let coordinate2 = CLLocationCoordinate2D(latitude: 19.0582239, longitude: 72.880554)
        var pointAnnotation2 = PointAnnotation(id: "second-annotation", coordinate: coordinate2)

        
        if let path = Bundle.main.path(forResource: "custom_marker", ofType: "png"), let image = UIImage(contentsOfFile: path) {
            pointAnnotation2.image = .custom(image: image, name: "custom-annotation")
        }
        
        pointAnnotationManager.delegate = self
        pointAnnotationManager.syncAnnotations([pointAnnotation2, pointAnnotation1])
        
        finish()
    }
}

extension MultiplePointAnnotationsExample: AnnotationInteractionDelegate {
    public func annotationManager(_ manager: AnnotationManager, didDetectTappedAnnotations annotations: [Annotation]) {
        guard let annotation = annotations.first else { return }
    }
}
