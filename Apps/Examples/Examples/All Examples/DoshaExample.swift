import MapboxMaps

@objc(DoshaExample)

class DoshaExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create an initial camera that is centered over Cusco, Peru and use it
        // when initializing the `MapView`.
        let center = CLLocationCoordinate2D(
            latitude: 35.676,
            longitude: 139.6503)
        let cameraOptions = CameraOptions(center: center, zoom: 12)
        let styleUrl = StyleURI(rawValue: "mapbox://styles/takutosuzukimapbox/ckr0l9cln5b5e18n0x970lxnt")
        let mapInitOptions = MapInitOptions(
            cameraOptions: cameraOptions,
            styleURI: styleUrl
        )
        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Once the map has finished loading, add the museum and contour layers to the map's style,
        // then add switches that toggle the visibility for those two layers.
        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            self.addStyleLayers()
        }
    }

    func addStyleLayers() {
        let doshaSourceId = "dosha"

        // Create a custom vector tileset source. This source contains point features
        // that represent museums.
        var doshaSource = VectorSource()
        doshaSource.url = "mapbox://takutosuzukimapbox.dosha2"

        var doshaLayer = FillLayer(id: doshaSourceId)
        // Assign this layer's source.
        doshaLayer.source = doshaSourceId
        // Specify the layer within the vector source to render on the map.
        doshaLayer.sourceLayer = "dosha"

        doshaLayer.fillColor = .expression(
            Exp(.match) {
                Exp(.get) {
                    "A33_002"
                }
                "1"
                "hsl(45, 96%, 56%)"
                "2"
                "hsl(0, 95%, 53%)"
                "hsl(0, 0%, 100%)"
            }
        )
        doshaLayer.fillOpacity = .expression(Exp(.literal) {
            0.5
        })
        let style = mapView.mapboxMap.style

        // Add the sources and layers to the map's style.
        do {
            try style.addSource(doshaSource, id: doshaSourceId)
            try style.addLayer(doshaLayer)
        } catch {
            print("Error when adding sources and layers: \(error.localizedDescription)")
        }
    }
}
