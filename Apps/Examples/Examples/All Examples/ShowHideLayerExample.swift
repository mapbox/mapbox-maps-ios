import MapboxMaps

@objc(ShowHideLayerExample)

class ShowHideLayerExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    let museumLayerId = "museum-circle-layer"
    let contourLayerId = "contour-line-layer"
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
        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            self.addStyleLayers()
            self.addVisibilitySwitches()
        }
    }

    func addStyleLayers() {
        // Specify the source IDs. They will be assigned to their respective sources when we
        // add the source to the map's style.
        let museumSourceId = "museum-source"
        let contourSourceId = "contour-source"

        // Create a custom vector tileset source. This source contains point features
        // that represent museums.
        var museumsSource = VectorSource()
        museumsSource.url = "mapbox://mapbox.2opop9hr"

        var museumLayer = CircleLayer(id: museumLayerId)

        // Assign this layer's source.
        museumLayer.source = museumSourceId
        // Specify the layer within the vector source to render on the map.
        museumLayer.sourceLayer = "museum-cusco"

        // Use a constant circle radius and color to style the layer.
        museumLayer.circleRadius = .constant(8)

        // `visibility` is `nil` by default. Set to `visible`.
        museumLayer.visibility = .constant(.visible)

        let museumColor = UIColor(red: 0.22, green: 0.58, blue: 0.70, alpha: 1.00)
        museumLayer.circleColor = .constant(ColorRepresentable(color: museumColor))

        var contourSource = VectorSource()
        // Add the Mapbox Terrain v2 vector tileset. Documentation for this vector tileset
        // can be found at https://docs.mapbox.com/vector-tiles/reference/mapbox-terrain-v2/
        contourSource.url = "mapbox://mapbox.mapbox-terrain-v2"

        var contourLayer = LineLayer(id: contourLayerId)

        // Assign this layer's source and source layer ID.
        contourLayer.source = contourSourceId
        contourLayer.sourceLayer = "contour"

        // Style the contents of the source's contour layer.
        contourLayer.lineCap = .constant(.round)
        contourLayer.lineJoin = .constant(.round)

        // `visibility` is `nil` by default. Set to `visible`.
        contourLayer.visibility = .constant(.visible)
        let contourLineColor = UIColor(red: 0.53, green: 0.48, blue: 0.35, alpha: 1.00)
        contourLayer.lineColor = .constant(ColorRepresentable(color: contourLineColor))

        let style = mapView.mapboxMap.style

        // Add the sources and layers to the map's style.
        do {
            try style.addSource(museumsSource, id: museumSourceId)
            try style.addSource(contourSource, id: contourSourceId)
            try style.addLayer(museumLayer)
            try style.addLayer(contourLayer)
        } catch {
            print("Error when adding sources and layers: \(error.localizedDescription)")
        }
    }

    @objc func toggleMuseumLayerVisibility(sender: UISwitch) {
        let style = mapView.mapboxMap.style
        // Update the museum layer's visibility based on whether the switch
        // is on. `visibility` is `nil` by default.
        do {
            try style.updateLayer(withId: museumLayerId) { (layer: inout CircleLayer) in
                layer.visibility = .constant(sender.isOn ? .visible : .none)
            }
        } catch {
            print("Failed to update the visibility for layer with id \(museumLayerId). Error: \(error.localizedDescription)")
        }
    }

    @objc func toggleContourLayerVisibility(sender: UISwitch) {
        let style = mapView.mapboxMap.style
        // Update the contour layer's visibility based on whether the switch
        // is on.
        do {
            try style.updateLayer(withId: contourLayerId) { (layer: inout CircleLayer) in
                layer.visibility = .constant(sender.isOn ? .visible : .none)
            }
        } catch {
            print("Failed to update the visibility for layer with id \(contourLayerId). Error: \(error.localizedDescription)")
        }
    }

    func addVisibilitySwitches() {
        // Create switches to toggle the layers' visibility.
        let museumSwitch = UISwitch()
        museumSwitch.addTarget(self, action: #selector(toggleMuseumLayerVisibility(sender:)), for: .valueChanged)
        museumSwitch.isOn = true
        museumSwitch.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(museumSwitch)

        let contourSwitch = UISwitch()
        contourSwitch.addTarget(self, action: #selector(toggleContourLayerVisibility(sender:)), for: .valueChanged)
        contourSwitch.isOn = true
        contourSwitch.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contourSwitch)

        // Add labels for the toggles.
        let museumLabel = UILabel()
        museumLabel.text = "Show museums"
        museumLabel.backgroundColor = .white
        museumLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(museumLabel)

        let contourLabel = UILabel()
        contourLabel.text = "Show contours"
        contourLabel.backgroundColor = .white
        contourLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contourLabel)

        // Layout the switches and labels.
        NSLayoutConstraint.activate([
            museumSwitch.topAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.topAnchor, constant: 20),
            museumSwitch.leadingAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            museumLabel.leadingAnchor.constraint(equalTo: museumSwitch.trailingAnchor, constant: 10),
            museumLabel.centerYAnchor.constraint(equalTo: museumSwitch.centerYAnchor),
            contourSwitch.topAnchor.constraint(equalTo: museumSwitch.bottomAnchor, constant: 20),
            contourSwitch.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 20),
            contourLabel.centerYAnchor.constraint(equalTo: contourSwitch.centerYAnchor),
            contourLabel.leadingAnchor.constraint(equalTo: contourSwitch.trailingAnchor, constant: 10)
        ])
    }
}
