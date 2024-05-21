import UIKit
@_spi(Experimental) import MapboxMaps

final class StandardStyleExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var cancelables = Set<AnyCancelable>()
    private var lightPreset = StandardLightPreset.night
    private var labelsSetting = true
    private var showRealEstate = true

    private var mapStyle: MapStyle {
        .standard(
            lightPreset: lightPreset,
            showPointOfInterestLabels: labelsSetting,
            showTransitLabels: labelsSetting,
            showPlaceLabels: labelsSetting,
            showRoadLabels: labelsSetting
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the camera options to center on New York City
        let options = MapInitOptions(cameraOptions: CameraOptions(center: CLLocationCoordinate2D(latitude: 40.72, longitude: -73.99), zoom: 11, pitch: 45))
        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.mapboxMap.mapStyle = mapStyle
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // When the style has finished loading add a line layer representing the border between New York and New Jersey
        mapView.mapboxMap.onStyleLoaded.observe { [weak self] _ in
            guard let self else { return }

            // Create and apply basic styling to the line layer, assign the layer to the "bottom" slot
            var layer = LineLayer(id: "line-layer", source: "line-layer")
            layer.lineColor = .constant(StyleColor.init(UIColor.orange))
            layer.lineWidth = .constant(8)
            // The borders renders in the same "bottom" slot with water, but added later, so it renders above.
            layer.slot = .bottom

            // Create a new GeoJSON data source of the line's coordinates
            var source = GeoJSONSource(id: "line-layer")
            source.data = .geometry(.lineString(LineString([
                CLLocationCoordinate2D(latitude: 40.913503418907936, longitude: -73.91912400100642),
                CLLocationCoordinate2D(latitude: 40.82943110786286, longitude: -73.9615887363045),
                CLLocationCoordinate2D(latitude: 40.75461056309348, longitude: -74.01409059085539),
                CLLocationCoordinate2D(latitude: 40.69522028220487, longitude: -74.02798814058939),
                CLLocationCoordinate2D(latitude: 40.65188756398558, longitude: -74.05655532615407),
                CLLocationCoordinate2D(latitude: 40.64339339389301, longitude: -74.13916853846217),
            ])))

            do {
                try mapView.mapboxMap.addSource(source)
                try mapView.mapboxMap.addLayer(layer)
            } catch {
                print(error)
            }

            toggleRealEstate(isOn: showRealEstate)

            // The below line is used for internal testing purposes only.
            finish()
        }.store(in: &cancelables)

        // Add buttons to control the light presets and labels
        let lightButton = changeLightButton()
        let labelsButton = changeLabelsButton()
        let realEstateButton = changeRealEstateButton()
        navigationItem.rightBarButtonItems = [lightButton, labelsButton, realEstateButton]
    }

    private func changeLightButton() -> UIBarButtonItem {
        if #available(iOS 13, *) {
            return UIBarButtonItem(image: UIImage(systemName: "sun.max.fill"), style: .plain, target: self, action: #selector(changeLightSetting))
        } else {
            return UIBarButtonItem(title: "Sun", style: .plain, target: self, action: #selector(changeLightSetting))
        }
    }

    private func changeLabelsButton() -> UIBarButtonItem {
        if #available(iOS 13, *) {
            return UIBarButtonItem(image: UIImage(systemName: "signpost.right"), style: .plain, target: self, action: #selector(changeLabelsSetting))
        } else {
            return UIBarButtonItem(title: "star", style: .plain, target: self, action: #selector(changeLabelsSetting))
        }
    }

    private func changeRealEstateButton() -> UIBarButtonItem {
        if #available(iOS 13, *) {
            return UIBarButtonItem(image: UIImage(systemName: "building.2.fill"), style: .plain, target: self, action: #selector(changeRealEstateSettings))
        } else {
            return UIBarButtonItem(title: "Build", style: .plain, target: self, action: #selector(changeLabelsSetting))
        }
    }

    @objc private func changeLightSetting() {
        // When a user clicks the light setting button change the `lightPreset` config property on the Standard style import.

        let presets = [StandardLightPreset.dawn, .day, .dusk, .night]
        let currentIndex = presets.firstIndex(of: lightPreset) ?? presets.startIndex
        lightPreset = presets[(currentIndex + 1) % presets.endIndex] // select next preset

        mapView.mapboxMap.mapStyle = mapStyle
    }

    @objc private func changeLabelsSetting() {
        // When a user clicks the labels setting button change the label config properties on the Standard style import to show/hide them
        labelsSetting.toggle()

        mapView.mapboxMap.mapStyle = mapStyle
    }

    @objc private func changeRealEstateSettings() {
        // When a user clicks show real estate button. Style import with real estate is added or deleted.
        showRealEstate.toggle()
        toggleRealEstate(isOn: showRealEstate)
    }

    private func toggleRealEstate(isOn: Bool) {
        do {
            if isOn {
                try mapView.mapboxMap.addStyleImport(withId: "real-estate", uri: StyleURI(url: styleURL)!)
            } else {
                try mapView.mapboxMap.removeStyleImport(withId: "real-estate")
            }
        } catch {
            print(error)
        }
    }
}

private let styleURL = Bundle.main.url(forResource: "fragment-realestate-NY", withExtension: "json")!
