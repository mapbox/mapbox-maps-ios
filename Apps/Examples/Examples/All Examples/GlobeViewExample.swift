import UIKit
@_spi(Experimental) import MapboxMaps

@objc(GlobeViewExample)
public class GlobeViewExample: UIViewController, ExampleProtocol {

    private enum Constants {
        static let flyDurationSeconds: Double = 10.0
        static let targetBearing: Double = 16.35586889454862
        static let targetZoom: CGFloat = 18.51596061886663
        static let targetPitch: CGFloat = 78.50097654853042
        static let targetPoint = CLLocationCoordinate2D(latitude: 40.71976882733935, longitude: -73.99429285004713)
    }

    internal var mapView: MapView!
    internal var currentProjection = StyleProjection(name: .globe)

    private lazy var infoLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 10)
        label.numberOfLines = 0
        label.textColor = .black
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var flyButton: UIButton = {
        let button = createGenericButton()
        button.setTitle("Fly animation", for: .normal)
        button.addTarget(self, action: #selector(flyPressed(sender:)), for: .touchUpInside)
        return button
    }()

    private lazy var switchProjectionButton: UIButton = {
        let button = createGenericButton()
        button.setTitle("Change mode", for: .normal)
        button.addTarget(self, action: #selector(projectionSwitched(sender:)), for: .touchUpInside)
        return button
    }()

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        try! mapView.mapboxMap.style.setProjection(currentProjection)
        mapView.mapboxMap.setCamera(to: .init(zoom: 1.0))

        mapView.mapboxMap.onNext(.styleLoaded) { [weak self] _ in
            self?.addSkyLayer()
        }
        mapView.mapboxMap.onEvery(.cameraChanged) { [weak self] _ in
            self?.updateInfoText()
        }

        view.addSubview(mapView)
        view.addSubview(infoLabel)
        view.addSubview(switchProjectionButton)
        view.addSubview(flyButton)

        // Set constraints
        NSLayoutConstraint.activate([
            infoLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            infoLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            infoLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 128)
        ])

        NSLayoutConstraint.activate([
            switchProjectionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            switchProjectionButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            switchProjectionButton.widthAnchor.constraint(equalToConstant: 128)
        ])

        NSLayoutConstraint.activate([
            flyButton.bottomAnchor.constraint(equalTo: switchProjectionButton.topAnchor, constant: -16),
            flyButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            flyButton.widthAnchor.constraint(equalToConstant: 128)
        ])

        updateInfoText()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         // The below line is used for internal testing purposes only.
        finish()
    }

    private func addSkyLayer() {
        var skyLayer = SkyLayer(id: "sky-layer")
        skyLayer.skyType = .constant(.atmosphere)
        skyLayer.skyAtmosphereSun = .constant([0, 0])
        skyLayer.skyAtmosphereSunIntensity = .constant(15.0)
        do {
            try mapView.mapboxMap.style.addLayer(skyLayer)
        } catch {
            print("Failed to add sky layer to the map's style.")
        }
    }

    private func createGenericButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 0.9882352941, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        return button
    }

    // MARK: - Action handlers

    @objc private func flyPressed(sender: UIButton) {
        mapView.camera.fly(
            to: CameraOptions(
                zoom: 5,
                bearing: Constants.targetBearing,
                pitch: Constants.targetPitch / 2),
            duration: Constants.flyDurationSeconds / 2) { _ in
                self.mapView.camera.fly(
                    to: CameraOptions(
                        center: Constants.targetPoint,
                        zoom: Constants.targetZoom,
                        pitch: Constants.targetPitch),
                    duration: Constants.flyDurationSeconds / 2)
        }
    }

    @objc private func projectionSwitched(sender: UIButton) {
        currentProjection.name = currentProjection.name == .globe ? .mercator : .globe
        try! mapView.mapboxMap.style.setProjection(currentProjection)
        updateInfoText()
    }

    private func updateInfoText() {
        let projectionName = mapView.mapboxMap.style.projection.name.rawValue
        let zoom = mapView.mapboxMap.cameraState.zoom
        infoLabel.text = """
        Zoom: \(zoom)
        Projection: \(projectionName)
        """
    }
}
