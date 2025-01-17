import UIKit
@_spi(Experimental) import MapboxMaps

extension UIButton {
    static func exampleActionButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 4
        button.clipsToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return button
    }
}

final class BuildingExtrusionsExample: UIViewController, ExampleProtocol {
    private var cancelables = Set<AnyCancelable>()

    private lazy var lightPositionButton: UIButton = {
        let button = UIButton.exampleActionButton()
        button.setImage(UIImage(systemName: "flashlight.on.fill"), for: .normal)
        button.addTarget(self, action: #selector(lightPositionButtonTapped(_:)), for: .primaryActionTriggered)
        return button
    }()

    private lazy var lightColorButton: UIButton = {
        let button = UIButton.exampleActionButton()
        button.setImage(UIImage(systemName: "paintbrush.fill"), for: .normal)
        button.addTarget(self, action: #selector(lightColorButtonTapped(_:)), for: .primaryActionTriggered)
        return button
    }()

    private lazy var heightAlignmentButton: UIButton = {
        let button = UIButton.exampleActionButton()

        button.setImage(UIImage(systemName: "align.vertical.top"), for: .normal)
        button.setImage(UIImage(systemName: "align.vertical.top.fill"), for: .selected)
        button.addTarget(self, action: #selector(heightAlignmentButtonTapped(_:)), for: .primaryActionTriggered)
        return button
    }()

    private lazy var baseAlignmentButton: UIButton = {
        let button = UIButton.exampleActionButton()

        button.setImage(UIImage(systemName: "align.vertical.bottom"), for: .normal)
        button.setImage(UIImage(systemName: "align.vertical.bottom.fill"), for: .selected)
        button.addTarget(self, action: #selector(baseAlignmentButtonTapped(_:)), for: .primaryActionTriggered)
        return button
    }()

    private lazy var terrainSwitchButton: UIButton = {
        let button = UIButton.exampleActionButton()
        button.setImage(UIImage(systemName: "mountain.2"), for: .normal)
        button.setImage(UIImage(systemName: "mountain.2.fill"), for: .selected)

        button.addTarget(self, action: #selector(terrainButtonTapped(_:)), for: .primaryActionTriggered)
        return button
    }()

    lazy var buttons = [
        heightAlignmentButton,
        baseAlignmentButton,
        lightPositionButton,
        lightColorButton,
        terrainSwitchButton
    ]

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

        buttons.forEach(view.addSubview(_:))
        terrainSwitchButton.isSelected = isTerrainEnabled

        let accessoryButtonsStackView = UIStackView(arrangedSubviews: buttons)
        accessoryButtonsStackView.axis = .vertical
        accessoryButtonsStackView.spacing = 20
        accessoryButtonsStackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(accessoryButtonsStackView)

        NSLayoutConstraint.activate([
            mapView.ornaments.attributionButton.topAnchor.constraint(equalToSystemSpacingBelow: accessoryButtonsStackView.bottomAnchor, multiplier: 1),
            view.trailingAnchor
                .constraint(equalToSystemSpacingAfter: accessoryButtonsStackView.trailingAnchor, multiplier: 1)
        ])
    }

    internal func setupExample() {
        try! addTerrain()
        try! addBuildingExtrusions()

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
    internal func addBuildingExtrusions() throws {
        let wallOnlyThreshold = 20
        let extrudeFilter = Exp(.eq, Exp(.get, "extrude"), "true")
        var layer = FillExtrusionLayer(id: "3d-buildings", source: "composite")
            .minZoom(15)
            .sourceLayer("building")
            .fillExtrusionColor(.lightGray)
            .fillExtrusionOpacity(0.8)
            .fillExtrusionAmbientOcclusionIntensity(0.3)
            .fillExtrusionAmbientOcclusionRadius(3.0)
            .fillExtrusionHeight(Exp(.get, "height"))
            .fillExtrusionBase(Exp(.get, "min_height"))
            .fillExtrusionVerticalScale(Exp(.interpolate, Exp(.linear), Exp(.zoom), 15, 0, 15.05, 1))

        layer.filter = Exp(.all) {
            extrudeFilter
            Exp(.gt) {
                Exp(.get) { "height" }
                wallOnlyThreshold
            }
        }

        try mapView.mapboxMap.addLayer(layer)

        var wallsOnlyExtrusionLayer = layer
            .fillExtrusionLineWidth(2)
        wallsOnlyExtrusionLayer.id = "3d-buildings-wall"
        wallsOnlyExtrusionLayer.filter = Exp(.all) {
            extrudeFilter
            Exp(.lte) {
                Exp(.get) { "height" }
                wallOnlyThreshold
            }
        }

        try mapView.mapboxMap.addLayer(wallsOnlyExtrusionLayer)
    }

    func addTerrain() throws {
        let terrainSourceID = "mapbox-dem"

        if !mapView.mapboxMap.sourceExists(withId: terrainSourceID) {
            try addTerrainSource(id: terrainSourceID)
        }

        try mapView.mapboxMap.setTerrain(Terrain(sourceId: terrainSourceID)
            .exaggeration(1.5))
    }

    func addTerrainSource(id: String) throws {
        var demSource = RasterDemSource(id: id)
        demSource.url = "mapbox://mapbox.mapbox-terrain-dem-v1"
        // Setting the `tileSize` to 514 provides better performance and adds padding around the outside
        // of the tiles.
        demSource.tileSize = 514
        demSource.maxzoom = 14.0
        try mapView.mapboxMap.addSource(demSource)
    }

    // MARK: - Actions

    var isTerrainEnabled = true

    @objc private func terrainButtonTapped(_ sender: UIButton) {
        if isTerrainEnabled {
            mapView.mapboxMap.removeTerrain()
        } else {
            try! addTerrain()
        }

        isTerrainEnabled.toggle()
        sender.isSelected = isTerrainEnabled
    }

    var baseAlignment: FillExtrusionBaseAlignment = .flat
    var heightAlignment: FillExtrusionHeightAlignment = .flat

    @objc private func baseAlignmentButtonTapped(_ sender: UIButton) {
        if baseAlignment == .flat {
            baseAlignment = .terrain
        } else {
            baseAlignment = .flat
        }
        sender.backgroundColor = .systemBlue
        sender.isSelected = baseAlignment == .terrain

        try! mapView.mapboxMap.updateLayer(withId: "3d-buildings", type: FillExtrusionLayer.self) { layer in
            layer.fillExtrusionBaseAlignment = .constant(baseAlignment)
        }
    }

    @objc private func heightAlignmentButtonTapped(_ sender: UIButton) {
        if heightAlignment == .flat {
            heightAlignment = .terrain
        } else {
            heightAlignment = .flat
        }
        sender.isSelected = heightAlignment == .terrain

        try! mapView.mapboxMap.updateLayer(withId: "3d-buildings", type: FillExtrusionLayer.self) { layer in
            layer.fillExtrusionHeightAlignment = .constant(heightAlignment)
        }
    }

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
