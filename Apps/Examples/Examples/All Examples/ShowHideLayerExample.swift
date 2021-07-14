import MapboxMaps

@objc(ShowHideLayerExample)

public class ShowHideLayerExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!
    var showsMuseumLayer = true
    var showsContourLayer = true

    // Specify the source IDs. They will be assigned to their respective sources when we
    // add the source to the map's style.
    let museumSourceId = "museum-source"
    let contourSourceId = "contour-source"

    override public func viewDidLoad() {
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
        // Create a custom vector tileset source. This source contains point features
        // that represent museums.
        var museumsSource = VectorSource()
        museumsSource.url = "mapbox://mapbox.2opop9hr"

        
        var museumLayer = CircleLayer(id: "museum-circle-layer")

        // Assign this layer's source.
        museumLayer.source = museumSourceId
        // Specify the layer within the vector source to render on the map.
        museumLayer.sourceLayer = "museum-cusco"

        // Use a constant circle radius and color to style the layer.
        museumLayer.circleRadius = .constant(8)
        let museumColor = UIColor(red: 0.22, green: 0.58, blue: 0.70, alpha: 1.00)
        museumLayer.circleColor = .constant(ColorRepresentable(color: museumColor))

        var contourSource = VectorSource()
        // Add the Mapbox Terrain v2 vector tileset. Documentation for this vector tileset
        // can be found at https://docs.mapbox.com/vector-tiles/reference/mapbox-terrain-v2/
        contourSource.url = "mapbox://mapbox.mapbox-terrain-v2"

        var contourLayer = LineLayer(id: "contour-line-layer")

        // Assign this layer's source and source layer ID.
        contourLayer.source = contourSourceId
        contourLayer.sourceLayer = "contour"

        // Style the contents of the source's contour layer.
        contourLayer.lineCap = .constant(.round)
        contourLayer.lineJoin = .constant(.round)
        let contourLineColor = UIColor(red: 0.53, green: 0.48, blue: 0.35, alpha: 1.00)
        contourLayer.lineColor = .constant(ColorRepresentable(color: contourLineColor))
        
        let style = mapView.mapboxMap.style
        do {
            try style.addSource(museumsSource, id: museumSourceId)
            try style.addSource(contourSource, id: contourSourceId)
            try style.addLayer(museumLayer)
            try style.addLayer(contourLayer)
        } catch {
            print("Error when adding sources and layers: \(error.localizedDescription)")
        }
    }

    @objc func toggleLayerVisibility(forLayer layer: String) {
        
    }

    func addVisibilitySwitches() {
        let museumSwitch = UISwitch()
        museumSwitch.target(forAction: #selector(toggleLayerVisibility(forLayer:)), withSender: self)
        museumSwitch.isOn = true
        museumSwitch.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(museumSwitch, aboveSubview: mapView)

        let contourSwitch = UISwitch()
        contourSwitch.isOn = true
        contourSwitch.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(contourSwitch, aboveSubview: mapView)

        // Add labels for the toggles.
        let museumLabel = UITextView()
        museumLabel.text = "Show museums"
        museumLabel.textColor = .black
        museumLabel.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(museumLabel, aboveSubview: mapView)

        let contourLabel = UITextView()
        contourLabel.text = "Show contour lines"
        contourLabel.textColor = .black
        contourLabel.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(contourLabel, aboveSubview: mapView)

        NSLayoutConstraint.activate([
            museumSwitch.topAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.topAnchor, constant: 20),
            museumSwitch.leadingAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            museumLabel.topAnchor.constraint(equalTo: museumSwitch.topAnchor),
            museumLabel.widthAnchor.constraint(equalToConstant: 40),
            museumLabel.leadingAnchor.constraint(equalTo: museumSwitch.trailingAnchor, constant: 10),
            museumLabel.heightAnchor.constraint(equalTo: museumSwitch.heightAnchor),
            contourSwitch.topAnchor.constraint(equalTo: museumSwitch.bottomAnchor, constant: 40),
            contourSwitch.centerYAnchor.constraint(equalTo: museumSwitch.centerYAnchor, constant: 10),
            contourSwitch.leadingAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            contourLabel.centerYAnchor.constraint(equalTo: contourSwitch.centerYAnchor),
            contourLabel.leadingAnchor.constraint(equalTo: contourSwitch.trailingAnchor, constant: 10),
            contourLabel.widthAnchor.constraint(equalToConstant: 40),
            contourLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
}
