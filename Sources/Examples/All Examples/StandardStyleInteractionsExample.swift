import MapboxMaps
import UIKit

final class StandardStyleInteractionsExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var cancelables = Set<AnyCancelable>()
    var lightPreset = StandardLightPreset.day
    var theme = StandardTheme.default
    var buildingSelectColor = StyleColor("hsl(214, 94%, 59%)") // default color

    override func viewDidLoad() {
        super.viewDidLoad()

        let cameraCenter = CLLocationCoordinate2D(latitude: 60.1718, longitude: 24.9453)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: cameraCenter, zoom: 16.35, bearing: 49.92, pitch: 40))
        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(mapView)
        mapView.mapboxMap.onStyleLoaded.observe { [weak self] _ in
            guard let self = self else { return }
            self.setupInteractions()
            finish()
        }.store(in: &cancelables)

        // Add UI elements for debug panel
        setupDebugPanel()
    }

    private func setupInteractions() {
        /// When a POI feature in the Standard POI featureset is tapped replace it with a ViewAnnotation
        mapView.mapboxMap.addInteraction(TapInteraction(.standardPoi) { [weak self] poi, _ in
            guard let self = self else { return false }
            self.addViewAnnotation(for: poi)
            self.mapView.mapboxMap.setFeatureState(poi, state: .init(hide: true))
            return true /// Returning true stops propagation to features below or the map itself.
        })

        /// When a building in the Standard Buildings featureset is tapped, set that building as selected to color it.
        mapView.mapboxMap.addInteraction(TapInteraction(.standardBuildings) { [weak self] building, _ in
            guard let self = self else { return false }
            self.mapView.mapboxMap.setFeatureState(building, state: .init(select: true))
            return true
        })

        /// When a place label in the Standard Place Labels featureset is tapped, set that place label as selected.
        mapView.mapboxMap.addInteraction(TapInteraction(.standardPlaceLabels) { [weak self] placeLabel, _ in
            guard let self = self else { return false }
            self.mapView.mapboxMap.setFeatureState(placeLabel, state: .init(select: true))
            return true
        })

        /// When the map is long-pressed, reset all selections
        mapView.mapboxMap.addInteraction(LongPressInteraction { [weak self] _ in
            guard let self = self else { return false }
            self.mapView.mapboxMap.resetFeatureStates(featureset: .standardBuildings, callback: nil)
            self.mapView.mapboxMap.resetFeatureStates(featureset: .standardPoi, callback: nil)
            self.mapView.mapboxMap.resetFeatureStates(featureset: .standardPlaceLabels, callback: nil)
            self.mapView.viewAnnotations.removeAll()
            return true
        })
    }

    private func addViewAnnotation(for poi: StandardPoiFeature) {
        let view = UIImageView(image: UIImage(named: "intermediate-pin"))
        view.contentMode = .scaleAspectFit
        let annotation = ViewAnnotation(coordinate: poi.coordinate, view: view)
        annotation.variableAnchors = [.init(anchor: .bottom, offsetY: 12)]
        mapView.viewAnnotations.add(annotation)
    }

    private func setupDebugPanel() {
        let debugPanel = UIView()
        debugPanel.translatesAutoresizingMaskIntoConstraints = false
        debugPanel.backgroundColor = .white
        debugPanel.layer.cornerRadius = 10
        debugPanel.layer.shadowColor = UIColor.black.cgColor
        debugPanel.layer.shadowOpacity = 0.2
        debugPanel.layer.shadowOffset = CGSize(width: 0, height: 2)
        debugPanel.layer.shadowRadius = 4
        view.addSubview(debugPanel)

        let buildingSelectLabel = UILabel()
        buildingSelectLabel.text = "Building Select"
        buildingSelectLabel.translatesAutoresizingMaskIntoConstraints = false
        debugPanel.addSubview(buildingSelectLabel)

        let buildingSelectControl = UISegmentedControl(items: ["Default", "Yellow", "Red"])
        buildingSelectControl.selectedSegmentIndex = 0
        buildingSelectControl.addTarget(self, action: #selector(buildingSelectColorChanged(_:)), for: .valueChanged)
        buildingSelectControl.translatesAutoresizingMaskIntoConstraints = false
        debugPanel.addSubview(buildingSelectControl)

        let lightLabel = UILabel()
        lightLabel.text = "Light"
        lightLabel.translatesAutoresizingMaskIntoConstraints = false
        debugPanel.addSubview(lightLabel)

        let lightControl = UISegmentedControl(items: ["Dawn", "Day", "Dusk", "Night"])
        lightControl.selectedSegmentIndex = 1
        lightControl.addTarget(self, action: #selector(lightPresetChanged(_:)), for: .valueChanged)
        lightControl.translatesAutoresizingMaskIntoConstraints = false
        debugPanel.addSubview(lightControl)

        let themeLabel = UILabel()
        themeLabel.text = "Theme"
        themeLabel.translatesAutoresizingMaskIntoConstraints = false
        debugPanel.addSubview(themeLabel)

        let themeControl = UISegmentedControl(items: ["Default", "Faded", "Monochrome"])
        themeControl.selectedSegmentIndex = 0
        themeControl.addTarget(self, action: #selector(themeChanged(_:)), for: .valueChanged)
        themeControl.translatesAutoresizingMaskIntoConstraints = false
        debugPanel.addSubview(themeControl)

        NSLayoutConstraint.activate([
            debugPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            debugPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            debugPanel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),

            buildingSelectLabel.topAnchor.constraint(equalTo: debugPanel.topAnchor, constant: 10),
            buildingSelectLabel.leadingAnchor.constraint(equalTo: debugPanel.leadingAnchor, constant: 10),

            buildingSelectControl.topAnchor.constraint(equalTo: buildingSelectLabel.bottomAnchor, constant: 5),
            buildingSelectControl.leadingAnchor.constraint(equalTo: debugPanel.leadingAnchor, constant: 10),
            buildingSelectControl.trailingAnchor.constraint(equalTo: debugPanel.trailingAnchor, constant: -10),

            lightLabel.topAnchor.constraint(equalTo: buildingSelectControl.bottomAnchor, constant: 10),
            lightLabel.leadingAnchor.constraint(equalTo: debugPanel.leadingAnchor, constant: 10),

            lightControl.topAnchor.constraint(equalTo: lightLabel.bottomAnchor, constant: 5),
            lightControl.leadingAnchor.constraint(equalTo: debugPanel.leadingAnchor, constant: 10),
            lightControl.trailingAnchor.constraint(equalTo: debugPanel.trailingAnchor, constant: -10),

            themeLabel.topAnchor.constraint(equalTo: lightControl.bottomAnchor, constant: 10),
            themeLabel.leadingAnchor.constraint(equalTo: debugPanel.leadingAnchor, constant: 10),

            themeControl.topAnchor.constraint(equalTo: themeLabel.bottomAnchor, constant: 5),
            themeControl.leadingAnchor.constraint(equalTo: debugPanel.leadingAnchor, constant: 10),
            themeControl.trailingAnchor.constraint(equalTo: debugPanel.trailingAnchor, constant: -10),

            themeControl.bottomAnchor.constraint(equalTo: debugPanel.bottomAnchor, constant: -10)
        ])
    }

    @objc private func buildingSelectColorChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            buildingSelectColor = StyleColor("hsl(214, 94%, 59%)")
        case 1:
            buildingSelectColor = StyleColor("yellow")
        case 2:
            buildingSelectColor = StyleColor(.red)
        default:
            break
        }
        applyStyleChanges()
    }

    @objc private func lightPresetChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            lightPreset = .dawn
        case 1:
            lightPreset = .day
        case 2:
            lightPreset = .dusk
        case 3:
            lightPreset = .night
        default:
            break
        }
        applyStyleChanges()
    }

    @objc private func themeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            theme = .default
        case 1:
            theme = .faded
        case 2:
            theme = .monochrome
        default:
            break
        }
        applyStyleChanges()
    }

    private func applyStyleChanges() {
        mapView.mapboxMap.mapStyle = .standard(theme: theme, lightPreset: lightPreset, colorBuildingSelect: buildingSelectColor)
    }
}
