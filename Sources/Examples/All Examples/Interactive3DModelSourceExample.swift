import UIKit
import MapboxMaps

@objc(Interactive3DModelSourceExample)
final class Interactive3DModelSourceExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var cancelables = Set<AnyCancelable>()

    private let sourceId = "3d-model-source"
    private let carModelKey = "car"

    // Vehicle parameters
    private var doorsFrontLeft: Double = 0.5
    private var doorsFrontRight: Double = 0.0
    private var trunk: Double = 0.0
    private var hood: Double = 0.0
    private var brakeLights: Double = 0.0
    private var vehicleColor: UIColor = .white

    private var controlsStackView: UIStackView!
    private var containerView: UIVisualEffectView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let cameraOptions = CameraOptions(
            center: CLLocationCoordinate2D(latitude: 40.7155, longitude: -74.0132),
            zoom: 19.4,
            bearing: 35,
            pitch: 60
        )

        mapView = MapView(
            frame: view.bounds,
            mapInitOptions: MapInitOptions(mapStyle: .standard(show3dObjects: false), cameraOptions: cameraOptions)
        )
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.mapboxMap.setMapStyleContent {
            // Add lights
            AmbientLight(id: "environment")
                .intensity(0.4)

            DirectionalLight(id: "sun_light")
                .castShadows(true)

            // Add model source
            ModelSource(id: sourceId)
                .models([createCarModel()])

            // Add model layer
            ModelLayer(id: "3d-model-layer", source: sourceId)
                .modelScale(x: 10, y: 10, z: 10)
                .modelType(.locationIndicator)
        }

        setupControlsPanel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        finish()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCameraPadding()
    }

    private func updateCameraPadding() {
        guard let containerView = containerView else { return }

        let panelHeight = containerView.frame.height

        mapView.mapboxMap.setCamera(to: .init(padding: .init(top: 0, left: 0, bottom: panelHeight, right: 0)))
        mapView.ornaments.options.attributionButton.margins.y = panelHeight + 16
        mapView.ornaments.options.logo.margins.y = panelHeight +  16
    }

    private func setupControlsPanel() {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.layer.cornerRadius = 12
        blurEffectView.clipsToBounds = true
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurEffectView)

        containerView = blurEffectView

        controlsStackView = UIStackView()
        controlsStackView.axis = .vertical
        controlsStackView.spacing = 12
        controlsStackView.translatesAutoresizingMaskIntoConstraints = false

        containerView.contentView.addSubview(controlsStackView)

        let titleLabel = UILabel()
        titleLabel.text = "Car Controls"
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.textAlignment = .center
        controlsStackView.addArrangedSubview(titleLabel)

        addColorPickerControl()

        addSliderControl(title: "Trunk", systemIcon: "car.side.rear.open", initialValue: trunk) { [weak self] value in
            self?.trunk = value
            self?.updateModel(nodeOverrides: [
                ModelNodeOverride(name: "trunk", orientation: [self?.mix(value, 0, -60) ?? 0, 0.0, 0.0])
            ])
        }

        addSliderControl(title: "Hood", systemIcon: "car.side.front.open", initialValue: hood) { [weak self] value in
            self?.hood = value
            self?.updateModel(nodeOverrides: [
                ModelNodeOverride(name: "hood", orientation: [self?.mix(value, 0, 45) ?? 0, 0.0, 0.0])
            ])
        }

        addSliderControl(title: "Left door", systemIcon: "car.top.door.front.left.open", initialValue: doorsFrontLeft) { [weak self] value in
            self?.doorsFrontLeft = value
            self?.updateModel(nodeOverrides: [
                ModelNodeOverride(name: "doors_front-left", orientation: [0.0, self?.mix(value, 0, -80) ?? 0, 0.0])
            ])
        }

        addSliderControl(title: "Right door", systemIcon: "car.top.door.front.right.open", initialValue: doorsFrontRight) { [weak self] value in
            self?.doorsFrontRight = value
            self?.updateModel(nodeOverrides: [
                ModelNodeOverride(name: "doors_front-right", orientation: [0.0, self?.mix(value, 0, 80) ?? 0, 0.0])
            ])
        }

        addSliderControl(title: "Brake lights", systemIcon: "exclamationmark.brakesignal", initialValue: brakeLights) { [weak self] value in
            self?.brakeLights = value
            let brakeColor = StyleColor(UIColor(red: 0.88, green: 0.0, blue: 0.0, alpha: 1.0))
            self?.updateModel(materialOverrides: [
                ModelMaterialOverride(
                    name: "lights_brakes",
                    modelColor: brakeColor,
                    modelColorMixIntensity: value,
                    modelEmissiveStrength: value,
                    modelOpacity: nil
                ),
                ModelMaterialOverride(
                    name: "lights-brakes_reverse",
                    modelColor: brakeColor,
                    modelColorMixIntensity: value,
                    modelEmissiveStrength: value,
                    modelOpacity: nil
                ),
                ModelMaterialOverride(
                    name: "lights_brakes_volume",
                    modelColor: brakeColor,
                    modelColorMixIntensity: 1.0,
                    modelEmissiveStrength: 0.8,
                    modelOpacity: value
                ),
                ModelMaterialOverride(
                    name: "lights-brakes_reverse_volume",
                    modelColor: brakeColor,
                    modelColorMixIntensity: 1.0,
                    modelEmissiveStrength: 0.8,
                    modelOpacity: value
                )
            ])
        }

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),

            controlsStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            controlsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            controlsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            controlsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }

    private func addColorPickerControl() {
        let rowStack = UIStackView()
        rowStack.axis = .horizontal
        rowStack.spacing = 12
        rowStack.alignment = .center

        let label = UILabel()
        label.text = "Vehicle color"
        label.font = .systemFont(ofSize: 14)

        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let iconConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .large)
        let iconImage = UIImage(systemName: "paintpalette", withConfiguration: iconConfig)
        let iconImageView = UIImageView(image: iconImage)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .label
        iconImageView.widthAnchor.constraint(equalToConstant: 28).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 28).isActive = true

        let colorButton = UIButton(type: .system)
        colorButton.layer.cornerRadius = 20
        colorButton.layer.borderWidth = 2
        colorButton.layer.borderColor = UIColor.systemGray.cgColor
        colorButton.backgroundColor = vehicleColor
        colorButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        colorButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        colorButton.addTarget(self, action: #selector(colorButtonTapped), for: .touchUpInside)

        rowStack.addArrangedSubview(label)
        rowStack.addArrangedSubview(spacer)
        rowStack.addArrangedSubview(iconImageView)
        rowStack.addArrangedSubview(colorButton)

        controlsStackView.addArrangedSubview(rowStack)
    }

    @objc private func colorButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Vehicle Color", message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = sender

        let colors: [(String, UIColor)] = [
            ("White", .white),
            ("Black", .black),
            ("Red", .red),
            ("Blue", UIColor(red: 0, green: 100/255, blue: 200/255, alpha: 1)),
            ("Green", UIColor(red: 0, green: 150/255, blue: 0, alpha: 1)),
            ("Yellow", .yellow),
            ("Brown", UIColor(red: 150/255, green: 75/255, blue: 0, alpha: 1)),
            ("Gray", .gray)
        ]

        for (name, color) in colors {
            alert.addAction(UIAlertAction(title: name, style: .default) { [weak self] _ in
                self?.vehicleColor = color
                sender.backgroundColor = color
                self?.updateModel(materialOverrides: [
                    ModelMaterialOverride(
                        name: "body",
                        modelColor: StyleColor(color),
                        modelColorMixIntensity: 1.0,
                        modelEmissiveStrength: nil,
                        modelOpacity: nil
                    )
                ])
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func addSliderControl(title: String, systemIcon: String, initialValue: Double, onChange: @escaping (Double) -> Void) {
        let rowStack = UIStackView()
        rowStack.axis = .horizontal
        rowStack.spacing = 12
        rowStack.alignment = .center

        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 14)
        label.widthAnchor.constraint(equalToConstant: 80).isActive = true

        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = Float(initialValue)
        slider.addAction(UIAction { action in
            if let slider = action.sender as? UISlider {
                onChange(Double(slider.value))
            }
        }, for: .valueChanged)

        let iconConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .large)
        let iconImage = UIImage(systemName: systemIcon, withConfiguration: iconConfig)
        let iconImageView = UIImageView(image: iconImage)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .label
        iconImageView.widthAnchor.constraint(equalToConstant: 28).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 28).isActive = true

        rowStack.addArrangedSubview(label)
        rowStack.addArrangedSubview(slider)
        rowStack.addArrangedSubview(iconImageView)

        controlsStackView.addArrangedSubview(rowStack)
    }

    // Create initial model with all overrides
    private func createCarModel() -> Model {
        let brakeColor = StyleColor(UIColor(red: 0.88, green: 0.0, blue: 0.0, alpha: 1.0))

        let materialOverrides: [ModelMaterialOverride] = [
            ModelMaterialOverride(
                name: "body",
                modelColor: StyleColor(vehicleColor),
                modelColorMixIntensity: 1.0,
                modelEmissiveStrength: nil,
                modelOpacity: nil
            ),
            ModelMaterialOverride(
                name: "lights_brakes",
                modelColor: brakeColor,
                modelColorMixIntensity: brakeLights,
                modelEmissiveStrength: brakeLights,
                modelOpacity: nil
            ),
            ModelMaterialOverride(
                name: "lights-brakes_reverse",
                modelColor: brakeColor,
                modelColorMixIntensity: brakeLights,
                modelEmissiveStrength: brakeLights,
                modelOpacity: nil
            ),
            ModelMaterialOverride(
                name: "lights_brakes_volume",
                modelColor: brakeColor,
                modelColorMixIntensity: 1.0,
                modelEmissiveStrength: 0.8,
                modelOpacity: brakeLights
            ),
            ModelMaterialOverride(
                name: "lights-brakes_reverse_volume",
                modelColor: brakeColor,
                modelColorMixIntensity: 1.0,
                modelEmissiveStrength: 0.8,
                modelOpacity: brakeLights
            )
        ]

        let nodeOverrides: [ModelNodeOverride] = [
            ModelNodeOverride(
                name: "doors_front-left",
                orientation: [0.0, mix(doorsFrontLeft, 0, -80), 0.0]
            ),
            ModelNodeOverride(
                name: "doors_front-right",
                orientation: [0.0, mix(doorsFrontRight, 0, 80), 0.0]
            ),
            ModelNodeOverride(
                name: "hood",
                orientation: [mix(hood, 0, 45), 0.0, 0.0]
            ),
            ModelNodeOverride(
                name: "trunk",
                orientation: [mix(trunk, 0, -60), 0.0, 0.0]
            )
        ]

        return Model(
            id: carModelKey,
            uri: URL(string: "https://docs.mapbox.com/mapbox-gl-js/assets/ego_car.glb")!,
            position: [-74.0132, 40.7155],
            orientation: [0, 0, 0],
            nodeOverrides: nodeOverrides,
            nodeOverrideNames: nil,
            materialOverrides: materialOverrides,
            materialOverrideNames: nil,
            featureProperties: nil
        )
    }

    // Update model with only changed overrides (incremental update)
    private func updateModel(materialOverrides: [ModelMaterialOverride]? = nil, nodeOverrides: [ModelNodeOverride]? = nil) {
        guard mapView.mapboxMap.styleURI != nil else { return }

        let model = Model(
            id: carModelKey,
            uri: URL(string: "https://docs.mapbox.com/mapbox-gl-js/assets/ego_car.glb")!,
            position: [-74.0132, 40.7155],
            orientation: [0, 0, 0],
            nodeOverrides: nodeOverrides,
            nodeOverrideNames: nil,
            materialOverrides: materialOverrides,
            materialOverrideNames: nil,
            featureProperties: nil
        )

        try? mapView.mapboxMap.setSourceProperty(
            for: sourceId,
            property: "models",
            value: [carModelKey: model.jsonObject()]
        )
    }

    // Helper function to mix values (linear interpolation)
    private func mix(_ t: Double, _ a: Double, _ b: Double) -> Double {
        return b * t - a * (t - 1)
    }
}
