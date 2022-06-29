import UIKit
import MapboxMaps

@objc(TrackingModeExample)

public class TrackingModeExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!
    internal var cameraLocationConsumer: CameraLocationConsumer!
    internal let toggleBearingImageButton: UIButton = UIButton(frame: .zero)
    internal var styleToggle: UISegmentedControl!
    internal var showsBearingImage: Bool = false {
        didSet {
            syncPuckAndButton()
        }
    }

    enum Style: Int, CaseIterable, CustomStringConvertible {
        var description: String {
            switch self {
            case .light:
                return "light".capitalized
            case .satelliteStreets:
                return "s. streets".capitalized
            case .customUri:
                return "custom".capitalized
            }
        }

        var name: String {
            switch self {
            case .light:
                return "light".capitalized
            case .satelliteStreets:
                return "s. streets".capitalized
            case .customUri:
                return "custom".capitalized
            }
        }

        var uri: StyleURI {
            switch self {
            case .light:
                return .light
            case .satelliteStreets:
                return .satelliteStreets
            case .customUri:
                let localStyleURL = Bundle.main.url(forResource: "blueprint_style", withExtension: "json")!
                return .init(url: localStyleURL)!
            }
        }

        case light
        case satelliteStreets
        case customUri
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Set initial camera settings
        let options = MapInitOptions(cameraOptions: CameraOptions(zoom: 15.0), styleURI: .satelliteStreets)

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        addStyleToggle()

        // Setup and create button for toggling show bearing image
        setupToggleShowBearingImageButton()

        installConstraints()

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
        guard let style = Style(rawValue: sender.selectedSegmentIndex) else { return }

        mapView.mapboxMap.style.uri = style.uri
    }

    func addStyleToggle() {
        // Create a UISegmentedControl to toggle between map styles
        styleToggle = UISegmentedControl(items: Style.allCases.map(\.name))
        styleToggle.tintColor = .white
        styleToggle.backgroundColor = .systemBlue
        styleToggle.selectedSegmentIndex = Style.satelliteStreets.rawValue
        view.insertSubview(styleToggle, aboveSubview: mapView)
        styleToggle.addTarget(self, action: #selector(switchStyle(sender:)), for: .valueChanged)
        styleToggle.translatesAutoresizingMaskIntoConstraints = false
    }

    func installConstraints() {
        // Configure autolayout constraints for the UISegmentedControl to align
        // at the bottom of the map view.
        NSLayoutConstraint.activate([
            styleToggle.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -60),
            styleToggle.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
            toggleBearingImageButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0),
            toggleBearingImageButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0),
            toggleBearingImageButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100.0)
        ])
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
