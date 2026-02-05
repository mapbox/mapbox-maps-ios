import UIKit
@_spi(Experimental) import MapboxMaps

// EXPERIMENTAL: Not intended for usage in current stata. Subject to change or deletion.
final class IndoorExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var styleURI: String?
    private var cancellables = Set<AnyCancelable>()
    private let styleTextField = UITextField()
    private let loadStyleButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        let cameraOptions = CameraOptions(
            center: CLLocationCoordinate2D(latitude: 35.5483, longitude: 139.7780),
            zoom: 16,
            bearing: 12,
            pitch: 60)

        let options = MapInitOptions(cameraOptions: cameraOptions)
        mapView = MapView(frame: view.bounds, mapInitOptions: options)

        mapView.ornaments.options.scaleBar.visibility = .visible
        mapView.ornaments.options.indoorSelector.visibility = .visible

        var puckConfiguration = Puck2DConfiguration.makeDefault(showBearing: true)
        puckConfiguration.pulsing = nil
        mapView.location.options.puckType = .puck2D(puckConfiguration)

        mapView.location.onLocationChange.observeNext { [weak mapView] newLocation in
            guard let mapView, let location = newLocation.last else { return }
            mapView.mapboxMap.setCamera(to: .init(center: location.coordinate, zoom: 18))
        }.store(in: &cancellables)

        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        mapView.mapboxMap.indoor.onIndoorUpdated.sink { indoorState in
             print("Selected floor id: \(indoorState.selectedFloorId)")
        }.store(in: &cancellables)
        view.addSubview(mapView)

        setupStyleInputUI()
    }

    private func setupStyleInputUI() {
        styleTextField.borderStyle = .roundedRect
        styleTextField.backgroundColor = .white
        styleTextField.autocapitalizationType = .none
        styleTextField.autocorrectionType = .no
        styleTextField.text = "mapbox://styles/mapbox/standard"
        styleTextField.placeholder = "Enter Style URI or JSON"
        styleTextField.translatesAutoresizingMaskIntoConstraints = false

        loadStyleButton.setTitle("Load Style", for: .normal)
        loadStyleButton.backgroundColor = .systemBlue
        loadStyleButton.setTitleColor(.white, for: .normal)
        loadStyleButton.layer.cornerRadius = 5
        loadStyleButton.addTarget(self, action: #selector(loadStyleTapped), for: .touchUpInside)
        loadStyleButton.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [styleTextField, loadStyleButton])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.backgroundColor = UIColor.white.withAlphaComponent(0.8)

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            loadStyleButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }

    @objc private func loadStyleTapped() {
        guard let text = styleTextField.text, !text.isEmpty else { return }
        loadStyle(from: text)
        styleTextField.resignFirstResponder()
    }

    private func loadStyle(from text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if let url = URL(string: trimmed), url.scheme != nil {
             if let styleURI = StyleURI(rawValue: trimmed) {
                 mapView.mapboxMap.styleURI = styleURI
             }
        } else {
            mapView.mapboxMap.styleJSON = trimmed
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The below line is used for internal testing purposes only.
        finish()
    }
}
