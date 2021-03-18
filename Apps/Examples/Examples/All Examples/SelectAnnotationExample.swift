import UIKit
import MapboxMaps

@objc(SelectAnnotationExample)

public class SelectAnnotationExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

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

        mapView = MapView(with: view.bounds, resourceOptions: resourceOptions())
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Set the center coordinate and zoom level over southern Iceland.
        let centerCoordinate = CLLocationCoordinate2D(latitude: 63.982738,
                                                      longitude: -16.741790)

        mapView.cameraManager.setCamera(centerCoordinate: centerCoordinate,
                                        zoom: 12.0)

        // Allow the view controller to receive information about map events.
        mapView.on(.mapLoaded) { [weak self] _ in
            guard let self = self else { return }
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
        let coordinate = mapView.cameraView.centerCoordinate
        let pointAnnotation = PointAnnotation(coordinate: coordinate)

        // Allow the view controller to accept annotation selection events.
        mapView.annotationManager.interactionDelegate = self

        // Add the annotation to the map.
        mapView.annotationManager.addAnnotation(pointAnnotation)

        // The below line is used for internal testing purposes only.
        finish()
    }
}

// Change the label's text and style when it is selected or deselected.
extension SelectAnnotationExample: AnnotationInteractionDelegate {
    public func didDeselectAnnotation(annotation: Annotation) {
        label.backgroundColor = UIColor.systemGray
        label.text = "Deselected annotation"
    }

    public func didSelectAnnotation(annotation: Annotation) {
        label.backgroundColor = UIColor.systemGreen
        label.text = "Selected annotation!"
    }
}
