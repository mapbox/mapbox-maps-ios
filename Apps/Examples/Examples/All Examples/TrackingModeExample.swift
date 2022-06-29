import UIKit
import MapboxMaps

@objc(TrackingModeExample)

public class TrackingModeExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!
    internal var cameraLocationConsumer: CameraLocationConsumer!
    internal let toggleBearingImageButton: UIButton = UIButton(frame: .zero)
    internal var showsBearingImage: Bool = false {
        didSet {
            syncPuckAndButton()
        }
    }
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Set initial camera settings
        let options = MapInitOptions(cameraOptions: CameraOptions(zoom: 15.0))

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        addStyleToggle()

        // Setup and create button for toggling show bearing image
        setupToggleShowBearingImageButton()

        cameraLocationConsumer = CameraLocationConsumer(mapView: mapView)

        // Add user position icon to the map with location indicator layer
        mapView.location.options.puckType = .puck2D()

        // Allows the delegate to receive information about map events.
        mapView.mapboxMap.onNext(event: .mapLoaded) { _ in
            // Register the location consumer with the map
            // Note that the location manager holds weak references to consumers, which should be retained
            self.mapView.location.addLocationConsumer(newConsumer: self.cameraLocationConsumer)

            self.finish() // Needed for internal testing purposes.
        }
    }

    @objc func showHideBearingImage() {
        showsBearingImage.toggle()
    }

    func syncPuckAndButton() {
        // Update puck config
        let configuration = Puck2DConfiguration.makeDefault(showBearing: showsBearingImage)

        mapView.location.options.puckType = .puck2D(configuration)

        // Update button title
        let title: String = showsBearingImage ? "Hide bearing image" : "Show bearing image"
        toggleBearingImageButton.setTitle(title, for: .normal)
    }

    private func setupToggleShowBearingImageButton() {
        // Styling
        toggleBearingImageButton.backgroundColor = .systemBlue
        toggleBearingImageButton.addTarget(self, action: #selector(showHideBearingImage), for: .touchUpInside)
        toggleBearingImageButton.setTitleColor(.white, for: .normal)
        syncPuckAndButton()
        toggleBearingImageButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toggleBearingImageButton)

        // Constraints
        toggleBearingImageButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0).isActive = true
        toggleBearingImageButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0).isActive = true
        toggleBearingImageButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70.0).isActive = true
    }

    @objc func switchStyle(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            // Set the map's style to the default Mapbox Streets style.
            // The map's `StyleURI` can be set to default Mapbox styles: `.light`, `.dark`, `.satellite`, `.satelliteStreets`, and `.outdoors`.
            mapView.mapboxMap.style.uri = .light
        case 1:
            // Set the map's style to Mapbox Satellite Streets.
            mapView.mapboxMap.style.uri = .streets
        case 2:
            // Set the map's style to Mapbox Satellite Streets.
            mapView.mapboxMap.style.uri = .dark
        default:
            mapView.mapboxMap.style.uri = .streets
        }
    }

    func addStyleToggle() {
        // Create a UISegmentedControl to toggle between map styles
        let styleToggle = UISegmentedControl(items: ["Light", "Streets", "Dark"])
        styleToggle.translatesAutoresizingMaskIntoConstraints = false
        styleToggle.tintColor = UIColor(red: 0.976, green: 0.843, blue: 0.831, alpha: 1)
        styleToggle.backgroundColor = .systemBlue
        styleToggle.layer.cornerRadius = 4
        styleToggle.clipsToBounds = true
        styleToggle.selectedSegmentIndex = 1
        view.insertSubview(styleToggle, aboveSubview: mapView)
        styleToggle.addTarget(self, action: #selector(switchStyle(sender:)), for: .valueChanged)

        // Configure autolayout constraints for the UISegmentedControl to align
        // at the bottom of the map view.
        NSLayoutConstraint(item: styleToggle, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mapView, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: 0.0).isActive = true
        styleToggle.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -60).isActive = true
    }
}

// Create class which conforms to LocationConsumer, update the camera's centerCoordinate when a locationUpdate is received
public class CameraLocationConsumer: LocationConsumer {
    weak var mapView: MapView?

    init(mapView: MapView) {
        self.mapView = mapView
    }

    public func locationUpdate(newLocation: Location) {
        mapView?.camera.ease(
            to: CameraOptions(center: newLocation.coordinate, zoom: 15),
            duration: 1.3)
    }
}
