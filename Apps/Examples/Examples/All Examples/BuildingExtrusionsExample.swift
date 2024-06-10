import UIKit
@_spi(Experimental) import MapboxMaps

final class BuildingExtrusionsExample: UIViewController, ExampleProtocol {
    private var cancelables = Set<AnyCancelable>()

    private lazy var lightPositionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 4
        button.clipsToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "flashlight.on.fill"), for: .normal)
        } else {
            button.setTitle("Position", for: .normal)
        }
        button.addTarget(self, action: #selector(lightPositionButtonTapped(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var lightColorButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 4
        button.clipsToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "paintbrush.fill"), for: .normal)
        } else {
            button.setTitle("Color", for: .normal)
        }
        button.addTarget(self, action: #selector(lightColorButtonTapped(_:)), for: .touchUpInside)
        return button
    }()

    private var ambientLight: AmbientLight = {
        var light = AmbientLight()
        light.color = .constant(StyleColor(.blue))
        light.intensity = .constant(0.9)
        return light
    }()

    private var directionalLight: DirectionalLight = {
        var light = DirectionalLight()
        light.color = .constant(StyleColor(.white))
        light.intensity = .constant(0.9)
        light.castShadows = .constant(true)
        light.direction = .constant([0.0, 15.0])
        return light
    }()

    private var mapView: MapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let options = MapInitOptions(styleURI: .light)
        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.mapboxMap.onStyleLoaded.observeNext { _ in
            self.setupExample()
        }.store(in: &cancelables)

        view.addSubview(lightPositionButton)
        view.addSubview(lightColorButton)

        NSLayoutConstraint.activate([
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: lightPositionButton.trailingAnchor, multiplier: 1),
            view.bottomAnchor.constraint(equalTo: lightPositionButton.bottomAnchor, constant: 100),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: lightColorButton.trailingAnchor, multiplier: 1),
            lightPositionButton.topAnchor.constraint(equalToSystemSpacingBelow: lightColorButton.bottomAnchor, multiplier: 1),
            lightColorButton.widthAnchor.constraint(equalTo: lightPositionButton.widthAnchor),
            lightColorButton.heightAnchor.constraint(equalTo: lightPositionButton.heightAnchor)
        ])
    }

    internal func setupExample() {
        addBuildingExtrusions()

        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 40.7135, longitude: -74.0066),
                                          zoom: 15.5,
                                          bearing: -17.6,
                                          pitch: 45)
        mapView.mapboxMap.setCamera(to: cameraOptions)

        try! mapView.mapboxMap.setLights(ambient: ambientLight, directional: directionalLight)

        // The below lines are used for internal testing purposes only.
        finish()
    }

    // See https://docs.mapbox.com/mapbox-gl-js/example/3d-buildings/ for equivalent gl-js example
    internal func addBuildingExtrusions() {
        var layer = FillExtrusionLayer(id: "3d-buildings", source: "composite")

        layer.minZoom                     = 15
        layer.sourceLayer                 = "building"
        layer.fillExtrusionColor   = .constant(StyleColor(.lightGray))
        layer.fillExtrusionOpacity = .constant(0.6)

        layer.filter = Exp(.eq) {
            Exp(.get) {
                "extrude"
            }
            "true"
        }

        layer.fillExtrusionHeight = .expression(
            Exp(.get) {
                "height"
            }
        )

        layer.fillExtrusionBase = .expression(
            Exp(.get) {
                "min_height"
            }
        )

        layer.fillExtrusionVerticalScale = .expression(
            Exp(.interpolate) {
                Exp(.linear)
                Exp(.zoom)
                15
                0
                15.05
                1
            }
        )

        layer.fillExtrusionAmbientOcclusionIntensity = .constant(0.3)

        layer.fillExtrusionAmbientOcclusionRadius = .constant(3.0)

        try! mapView.mapboxMap.addLayer(layer)
    }

    // MARK: - Actions

    @objc private func lightColorButtonTapped(_ sender: UIButton) {
        if case .constant(let color) = ambientLight.color, color == StyleColor(.red) {
            ambientLight.color = .constant(StyleColor(.blue))
            sender.tintColor = .blue
        } else {
            ambientLight.color = .constant(StyleColor(.red))
            sender.tintColor = .red
        }

        try! mapView.mapboxMap.setLights(ambient: ambientLight, directional: directionalLight)
    }

    @objc private func lightPositionButtonTapped(_ sender: UIButton) {
        let firstPosition: [Double] = [0, 15]
        let secondPosition: [Double] = [90, 60]

        if case .constant(let position) = directionalLight.direction, position == firstPosition {
            directionalLight.direction = .constant(secondPosition)
            sender.imageView?.transform = .identity
        } else {
            directionalLight.direction = .constant(firstPosition)
            sender.imageView?.transform = CGAffineTransform(rotationAngle: 2.0 * .pi / 3.0)
        }

        try! mapView.mapboxMap.setLights(ambient: ambientLight, directional: directionalLight)
    }
}
