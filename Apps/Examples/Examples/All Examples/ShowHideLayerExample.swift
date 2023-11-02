import MapboxMaps
import UIKit

final class ShowHideLayerExample: UIViewController, ExampleProtocol {
    private static let museumLayerId = "museum-circle-layer"
    private static let contourLayerId = "contour-line-layer"

    private var mapView: MapView!
    private var cancelables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create an initial camera that is centered over Cusco, Peru and use it
        // when initializing the `MapView`.
        let center = CLLocationCoordinate2D(latitude: -13.517379, longitude: -71.977221)
        let cameraOptions = CameraOptions(center: center, zoom: 15)
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions)

        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.ornaments.options.scaleBar.visibility = .hidden
        view.addSubview(mapView)

        // Once the map has finished loading, add the museum and contour layers to the map's style,
        // then add switches that toggle the visibility for those two layers.
        mapView.mapboxMap.onStyleLoaded.observeNext { [weak self] _ in
            self?.addStyleLayers()
            self?.addVisibilitySwitches()

            // The following line is just for testing purposes.
            self?.finish()
        }.store(in: &cancelables)
    }

    func addStyleLayers() {
        // Create a custom vector tileset source. This source contains point features
        // that represent museums.
        var museumsSource = VectorSource(id: "museum-source")
        museumsSource.url = "mapbox://mapbox.2opop9hr"

        // Create CircleLayer with id and source identifier.
        var museumLayer = CircleLayer(id: Self.museumLayerId, source: museumsSource.id)

        // Specify the layer within the vector source to render on the map.
        museumLayer.sourceLayer = "museum-cusco"

        // Use a constant circle radius and color to style the layer.
        museumLayer.circleRadius = .constant(8)

        // `visibility` is `nil` by default. Set to `visible`.
        museumLayer.visibility = .constant(.visible)

        let museumColor = UIColor(red: 0.22, green: 0.58, blue: 0.70, alpha: 1.00)
        museumLayer.circleColor = .constant(StyleColor(museumColor))

        var contourSource = VectorSource(id: "contour-source")
        // Add the Mapbox Terrain v2 vector tileset. Documentation for this vector tileset
        // can be found at https://docs.mapbox.com/vector-tiles/reference/mapbox-terrain-v2/
        contourSource.url = "mapbox://mapbox.mapbox-terrain-v2"

        var contourLayer = LineLayer(id: Self.contourLayerId, source: contourSource.id)

        // Assign this layer's source layer ID.
        contourLayer.sourceLayer = "contour"

        // Style the contents of the source's contour layer.
        contourLayer.lineCap = .constant(.round)
        contourLayer.lineJoin = .constant(.round)

        // `visibility` is `nil` by default. Set to `visible`.
        contourLayer.visibility = .constant(.visible)

        let contourLineColor = UIColor(red: 0.53, green: 0.48, blue: 0.35, alpha: 1.00)
        contourLayer.lineColor = .constant(StyleColor(contourLineColor))

        // Add the sources and layers to the map's style.
        do {
            try mapView.mapboxMap.addSource(museumsSource)
            try mapView.mapboxMap.addSource(contourSource)
            try mapView.mapboxMap.addLayer(museumLayer)
            try mapView.mapboxMap.addLayer(contourLayer)
        } catch {
            print("Error when adding sources and layers: \(error.localizedDescription)")
        }
    }

    @objc func toggleMuseumLayerVisibility(sender: UISwitch) {
        // Update the museum layer's visibility based on whether the switch
        // is on. `visibility` is `nil` by default.
        do {
            try mapView.mapboxMap.updateLayer(withId: Self.museumLayerId, type: CircleLayer.self) { layer in
                layer.visibility = .constant(sender.isOn ? .visible : .none)
            }
        } catch {
            print("Failed to update the visibility for layer with id \(Self.museumLayerId). Error: \(error.localizedDescription)")
        }
    }

    @objc func toggleContourLayerVisibility(sender: UISwitch) {
        // Update the contour layer's visibility based on whether the switch
        // is on.
        do {
            try mapView.mapboxMap.updateLayer(withId: Self.contourLayerId, type: CircleLayer.self) { layer in
                layer.visibility = .constant(sender.isOn ? .visible : .none)
            }
        } catch {
            print("Failed to update the visibility for layer with id \(Self.contourLayerId). Error: \(error.localizedDescription)")
        }
    }

    func addVisibilitySwitches() {
        // Create switches to toggle the layers' visibility.
        let museumSwitch = UISwitch()
        museumSwitch.addTarget(self, action: #selector(toggleMuseumLayerVisibility(sender:)), for: .valueChanged)
        museumSwitch.isOn = true
        museumSwitch.translatesAutoresizingMaskIntoConstraints = false

        let contourSwitch = UISwitch()
        contourSwitch.addTarget(self, action: #selector(toggleContourLayerVisibility(sender:)), for: .valueChanged)
        contourSwitch.isOn = true
        contourSwitch.translatesAutoresizingMaskIntoConstraints = false

        // Add labels for the toggles.
        let museumLabel = UILabel()
        museumLabel.text = "Show museums"
        museumLabel.translatesAutoresizingMaskIntoConstraints = false

        let contourLabel = UILabel()
        contourLabel.text = "Show contours"
        contourLabel.translatesAutoresizingMaskIntoConstraints = false

        let museumStackView = UIStackView(arrangedSubviews: [museumLabel, museumSwitch])
        museumStackView.translatesAutoresizingMaskIntoConstraints = false
        let contourStackView = UIStackView(arrangedSubviews: [contourLabel, contourSwitch])
        contourStackView.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [museumStackView, contourStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = UIStackView.spacingUseSystem
        stackView.axis = .vertical
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = .init(top: 10, leading: 10, bottom: 10, trailing: 10)

        let backdropView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        backdropView.translatesAutoresizingMaskIntoConstraints = false
        backdropView.layer.cornerRadius = 10
        backdropView.clipsToBounds = true

        stackView.insertSubview(backdropView, at: 0)
        view.addSubview(stackView)

        // Layout the switches and labels.
        NSLayoutConstraint.activate([
            mapView.ornaments.logoView.topAnchor.constraint(equalToSystemSpacingBelow: stackView.bottomAnchor, multiplier: 1),
            stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: mapView.safeAreaLayoutGuide.leadingAnchor, multiplier: 1),
            mapView.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 1),

            stackView.topAnchor.constraint(equalTo: backdropView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: backdropView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: backdropView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: backdropView.trailingAnchor)
        ])
    }
}
