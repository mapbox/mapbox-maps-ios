#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
import MapboxMaps

@objc(SelectAnnotationExample)
final class SelectAnnotationExample: UIViewController, ExampleProtocol {

    private var mapView: MapView!

    private var annotationSelected: Bool = false {
        didSet {
            if annotationSelected {
                label.backgroundColor = .systemGreen
                label.text = "Selected annotation!"
            } else {
                label.backgroundColor = .systemGray
                label.text = "Deselected annotation"
            }
        }
    }

    // Configure a label
    private var label: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .systemBlue
        label.layer.cornerRadius = 12.0
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 24.0)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the center coordinate and zoom level over southern Iceland.
        let centerCoordinate = CLLocationCoordinate2D(latitude: 63.982738,
                                                      longitude: -16.741790)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 12.0))

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Allow the view controller to receive information about map events.
        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            self.setupExample()
        }

        // Add the label on top of the map view controller.
        addLabel()
    }

    private func addLabel() {
        label.text = "Select the annotation"
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            label.heightAnchor.constraint(equalToConstant: 60.0)
        ])
    }

    // Wait for the style to load before adding an annotation.
    private func setupExample() {

        // Create the point annotation, which will be rendered with a custom image
        let coordinate = mapView.cameraState.center
        var pointAnnotation = PointAnnotation(coordinate: coordinate)
        pointAnnotation.image = .init(image: UIImage(named: "custom_marker")!, name: "custom_marker")

        // Create a point annotation manager
        // Annotation managers are kept alive by `AnnotationOrchestrator`
        // (`mapView.annotations`) until you explicitly destroy them
        // by calling `mapView.annotations.removeAnnotationManager(withId:)`
        let pointAnnotationManager = mapView.annotations.makePointAnnotationManager()

        // Allow the view controller to accept annotation selection events.
        pointAnnotationManager.delegate = self

        // Add the annotation to the map.
        pointAnnotationManager.annotations = [pointAnnotation]

        // The below line is used for internal testing purposes only.
        finish()
    }
}

// Change the label's text and style when it is selected or deselected.
extension SelectAnnotationExample: AnnotationInteractionDelegate {
    func annotationManager(_ manager: AnnotationManager,
                           didDetectTappedAnnotations annotations: [Annotation]) {
        if annotationSelected || !annotations.isEmpty {
            annotationSelected.toggle()
        }
    }
}
