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
        customPointAnnotation.textField = "test"
        customPointAnnotation.image = .init(image: "📍".image()! , name: "image")
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

extension String {
    func image() -> UIImage? {
        let nsString = (self as NSString)
        let font = UIFont.systemFont(ofSize: 24) // you can change your font size here
        let stringAttributes = [NSAttributedString.Key.font: font]
        let imageSize = nsString.size(withAttributes: stringAttributes)

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0) //  begin image context
        UIColor.clear.set() // clear background
        UIRectFill(CGRect(origin: CGPoint(), size: imageSize)) // set rect size
        nsString.draw(at: CGPoint.zero, withAttributes: stringAttributes) // draw text within rect
        let image = UIGraphicsGetImageFromCurrentImageContext() // create image from context
        UIGraphicsEndImageContext() //  end image context

        return image ?? UIImage()
    }
}
