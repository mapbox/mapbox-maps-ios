import UIKit
import MapboxMaps

final class TrackingModeExample: UIViewController, ExampleProtocol {
    private var cancelables = Set<AnyCancelable>()
    private var locationTrackingCancellation: AnyCancelable?

    private var mapView: MapView!
    private lazy var toggleBearingImageButton = UIButton(frame: .zero)
    private lazy var trackingButton = UIButton(frame: .zero)
    private lazy var styleToggle = UISegmentedControl(items: Style.allCases.map(\.name))
    private var style: Style = .standard {
        didSet {
            mapView.mapboxMap.styleURI = style.uri
        }
    }
    private var showsBearingImage: Bool = false {
        didSet {
            syncPuckAndButton()
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Set initial camera settings
        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 37.26301831966747, longitude: -121.97647612483807), zoom: 10)
        let options = MapInitOptions(cameraOptions: cameraOptions, styleURI: style.uri)

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        addStyleToggle()

        // Setup and create button for toggling show bearing image
        setupToggleShowBearingImageButton()
        setupLocationButton()

        // Add user position icon to the map with location indicator layer
        mapView.location.options.puckType = .puck2D()
        mapView.location.options.puckBearingEnabled = true

        mapView.gestures.delegate = self

        // Update the camera's centerCoordinate when a locationUpdate is received.
        startTracking()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The below line is used for internal testing purposes only.
        finish()
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
        toggleBearingImageButton.layer.cornerRadius = 4
        toggleBearingImageButton.clipsToBounds = true
        toggleBearingImageButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

        toggleBearingImageButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toggleBearingImageButton)

        // Constraints
        toggleBearingImageButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0).isActive = true
        toggleBearingImageButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0).isActive = true
        toggleBearingImageButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70.0).isActive = true

        syncPuckAndButton()
    }

    private func setupLocationButton() {
        trackingButton.addTarget(self, action: #selector(switchTracking), for: .touchUpInside)

        if #available(iOS 13.0, *) {
            trackingButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        } else {
            trackingButton.setTitle("No tracking", for: .normal)
        }

        let buttonWidth = 44.0
        trackingButton.translatesAutoresizingMaskIntoConstraints = false
        trackingButton.backgroundColor = UIColor(white: 0.97, alpha: 1)
        trackingButton.layer.cornerRadius = buttonWidth/2
        trackingButton.layer.shadowOffset = CGSize(width: -1, height: 1)
        trackingButton.layer.shadowColor = UIColor.black.cgColor
        trackingButton.layer.shadowOpacity = 0.5
        view.addSubview(trackingButton)

        NSLayoutConstraint.activate([
            trackingButton.trailingAnchor.constraint(equalTo: toggleBearingImageButton.trailingAnchor),
            trackingButton.bottomAnchor.constraint(equalTo: toggleBearingImageButton.topAnchor, constant: -20),
            trackingButton.widthAnchor.constraint(equalTo: trackingButton.heightAnchor),
            trackingButton.widthAnchor.constraint(equalToConstant: buttonWidth)
        ])
    }

    @objc func switchStyle(sender: UISegmentedControl) {
        style = Style(rawValue: sender.selectedSegmentIndex) ?? . satelliteStreets
    }

    @objc func switchTracking() {
        let isTrackingNow = locationTrackingCancellation != nil
        if isTrackingNow {
            stopTracking()
        } else {
            startTracking()
        }
    }

    private func startTracking() {
        locationTrackingCancellation = mapView.location.onLocationChange.observe { [weak mapView] newLocation in
            guard let location = newLocation.last, let mapView else { return }
            mapView.camera.ease(
                to: CameraOptions(center: location.coordinate, zoom: 15),
                duration: 1.3)
        }

        if #available(iOS 13.0, *) {
            trackingButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        } else {
            trackingButton.setTitle("No tracking", for: .normal)
        }
    }

    func stopTracking() {
        if #available(iOS 13.0, *) {
            trackingButton.setImage(UIImage(systemName: "location"), for: .normal)
        } else {
            trackingButton.setTitle("Track", for: .normal)
        }
        locationTrackingCancellation = nil
    }

    func addStyleToggle() {
        // Create a UISegmentedControl to toggle between map styles
        styleToggle.selectedSegmentIndex = style.rawValue
        styleToggle.addTarget(self, action: #selector(switchStyle(sender:)), for: .valueChanged)
        styleToggle.translatesAutoresizingMaskIntoConstraints = false

        // set the segmented control as the title view
        navigationItem.titleView = styleToggle
    }
}

extension TrackingModeExample: GestureManagerDelegate {
    public func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didBegin gestureType: MapboxMaps.GestureType) {
        stopTracking()
    }

    public func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didEnd gestureType: MapboxMaps.GestureType, willAnimate: Bool) {}

    public func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didEndAnimatingFor gestureType: MapboxMaps.GestureType) {}
}

extension TrackingModeExample {
    private enum Style: Int, CaseIterable {
        var name: String {
            switch self {
            case .standard:
                return "Standard"
            case .light:
                return "Light"
            case .satelliteStreets:
                return "Satellite"
            case .customUri:
                return "Custom"
            }
        }

        var uri: StyleURI {
            switch self {
            case .standard:
                return .standard
            case .light:
                return .light
            case .satelliteStreets:
                return .satelliteStreets
            case .customUri:
                let localStyleURL = Bundle.main.url(forResource: "blueprint_style", withExtension: "json")!
                return .init(url: localStyleURL)!
            }
        }

        case standard
        case light
        case satelliteStreets
        case customUri
    }
}
