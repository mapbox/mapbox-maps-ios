import MapboxMaps

@objc(RasterTileSourceExample)
class RasterTileSourceExample: UIViewController, ExampleProtocol {
    var mapView: MapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize a `MapView` that is centered over the southeastern United States.
        let centerCoordinate = CLLocationCoordinate2D(latitude: 40, longitude: -74.5)
        let cameraOptions = CameraOptions(center: centerCoordinate, zoom: 2)
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions)

        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            self.addRasterSource()
        }
    }

    func addRasterSource() {
        let style = mapView.mapboxMap.style
    
        // This URL points to raster tiles designed by Stamen Design.
        let sourceUrl = "https://stamen-tiles.a.ssl.fastly.net/watercolor/{z}/{x}/{y}.jpg"

        // Create a `RasterSource` and set the source's URL to the Stamen watercolor raster tiles.
        var rasterSource = RasterSource()
        rasterSource.url = sourceUrl

        // Specify the tile size for the `RasterSource`.
        rasterSource.tileSize = 256

        var sourceId = "raster-source"
        var rasterLayer = RasterLayer(id: "raster-layer")

        // Specify that the layer should use the source with the ID `raster-source`. This ID will be
        // assigned to the `RasterSource` when it is added to the style.
        rasterLayer.source = sourceId

//
//        rasterLayer.minZoom = 0
//        rasterLayer.maxZoom = 22
        do {
            try style.addSource(rasterSource, id: sourceId)
            try style.addLayer(rasterLayer)
        } catch {
            print("Failed to update the style. Error: \(error)")
        }
    }
}
