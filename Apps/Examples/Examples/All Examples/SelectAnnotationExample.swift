import UIKit
import MapboxMaps

@objc(SelectAnnotationExample)

public class SelectAnnotationExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    /// Keep a reference to the `PointAnnotationManager` since the annotations will only show if their corresponding manager is alive
    internal lazy var pointAnnotationManager: PointAnnotationManager = {
        return mapView.annotations.makePointAnnotationManager()
    }()

    internal var annotationSelected: Bool = false {
        didSet {
            if annotationSelected {
                label.backgroundColor = UIColor.systemGreen
                label.text = "Selected annotation!"
            } else {
                label.backgroundColor = UIColor.systemGray
                label.text = "Deselected annotation"
            }
        }
    }

    // Configure a label
    public lazy var label: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.systemBlue
        label.layer.cornerRadius = 12.0
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 24.0)
        return label
    }()

    override public func viewDidLoad() {
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

    public func addLabel() {
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
    public func setupExample() {

        // Create the point annotation, which will be rendered with the default red pin.
        let coordinate = mapView.cameraState.center
        var pointAnnotation = PointAnnotation(coordinate: coordinate)
        pointAnnotation.image = .default

        // Allow the view controller to accept annotation selection events.
        pointAnnotationManager.delegate = self

        // Add the annotation to the map.
        pointAnnotationManager.syncAnnotations([pointAnnotation])

        // The below line is used for internal testing purposes only.
        finish()
    }
}

// Change the label's text and style when it is selected or deselected.
extension SelectAnnotationExample: AnnotationInteractionDelegate {
    public func annotationManager(_ manager: AnnotationManager,
                                  didDetectTappedAnnotations annotations: [Annotation]) {
        if annotationSelected || !annotations.isEmpty {
            annotationSelected.toggle()
        }
    }
}
