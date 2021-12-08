import MapboxMaps
import UIKit

@objc(RasterTileSourceExample)
class RasterTileSourceExample: UIViewController, ExampleProtocol {
    var mapView: MapView!
    var isTileRequestDelayEnabled = false

    let button = UIButton(type: .system)
    let sourceId = "raster-source"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize a `MapView` that is centered over the southeastern United States.
        let centerCoordinate = CLLocationCoordinate2D(latitude: 40, longitude: -74.5)
        let cameraOptions = CameraOptions(center: centerCoordinate, zoom: 2)
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions)

        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Once the map has finished loading, add the `RasterSource` and `RasterLayer` to the map's style.
        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            self.addRasterSource()
        }

        button.setTitle("Enable tile request delay", for: .normal)
        button.backgroundColor = .white
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        NSLayoutConstraint.activate([button.centerXAnchor.constraint(equalTo: view.centerXAnchor), button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)])
        button.addTarget(self, action: #selector(toggleTileRequestDelay), for: .touchUpInside)
    }

    @objc
    func toggleTileRequestDelay() {
        isTileRequestDelayEnabled.toggle()
        try? mapView.mapboxMap.style.setSourceProperty(for: sourceId, property: "tile-requests-delay", value: isTileRequestDelayEnabled ? 5000 : 0)
        button.setTitle(isTileRequestDelayEnabled ? "Disable tile request delay" : "Enable tile request delay", for: .normal)
    }

    func addRasterSource() {
        let style = mapView.mapboxMap.style

        // This URL points to raster tiles designed by Stamen Design.
        let sourceUrl = "https://stamen-tiles.a.ssl.fastly.net/watercolor/{z}/{x}/{y}.jpg"

        // Create a `RasterSource` and set the source's `tiles` to the Stamen watercolor raster tiles.
        var rasterSource = RasterSource()
        rasterSource.tiles = [sourceUrl]

        // Specify the tile size for the `RasterSource`.
        rasterSource.tileSize = 256

        var rasterLayer = RasterLayer(id: "raster-layer")

        // Specify that the layer should use the source with the ID `raster-source`. This ID will be
        // assigned to the `RasterSource` when it is added to the style.

        rasterLayer.source = sourceId

        do {
            try style.addSource(rasterSource, id: sourceId)
            try style.addLayer(rasterLayer)
        } catch {
            print("Failed to update the style. Error: \(error)")
        }
    }
}
