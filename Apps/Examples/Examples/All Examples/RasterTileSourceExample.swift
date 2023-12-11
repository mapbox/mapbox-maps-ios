import MapboxMaps
import UIKit

final class RasterTileSourceExample: UIViewController, ExampleProtocol {
    private var cancelables = Set<AnyCancelable>()
    private var mapView: MapView!
    private var isTileRequestDelayEnabled = false
    private let button = UIButton(type: .system)
    private let sourceId = "raster-source"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize a `MapView` that is centered over the southeastern United States.
        let centerCoordinate = CLLocationCoordinate2D(latitude: 40, longitude: -74.5)
        let cameraOptions = CameraOptions(center: centerCoordinate, zoom: 2)
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions, styleURI: .satellite)

        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Once the map has finished loading, add the `RasterSource` and `RasterLayer` to the map's style.
        mapView.mapboxMap.onMapLoaded.observeNext { _ in
            self.addRasterSource()

            // The following line is just for testing purposes.
            self.finish()
        }.store(in: &cancelables)

        button.setTitle("Enable tile request delay", for: .normal)
        button.backgroundColor = .white
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        NSLayoutConstraint.activate([button.centerXAnchor.constraint(equalTo: view.centerXAnchor), button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)])
        button.addTarget(self, action: #selector(toggleTileRequestDelay), for: .touchUpInside)
    }

    @objc func toggleTileRequestDelay() {
        isTileRequestDelayEnabled.toggle()
        try? mapView.mapboxMap.setSourceProperty(for: sourceId, property: "tile-requests-delay", value: isTileRequestDelayEnabled ? 5000 : 0)
        button.setTitle(isTileRequestDelayEnabled ? "Disable tile request delay" : "Enable tile request delay", for: .normal)
    }

    func addRasterSource() {

        // This URL points to raster tiles from OpenStreetMap
        let sourceUrl = "https://tile.openstreetmap.org/{z}/{x}/{y}.png"

        // Create a `RasterSource` and set the source's `tiles` to the Stamen watercolor raster tiles.
        var rasterSource = RasterSource(id: sourceId)
        rasterSource.tiles = [sourceUrl]

        // Specify the tile size for the `RasterSource`.
        rasterSource.tileSize = 256

        // Specify that the layer should use the source with the ID `raster-source`. This ID will be
        // assigned to the `RasterSource` when it is added to the style.
        let rasterLayer = RasterLayer(id: "raster-layer", source: sourceId)

        do {
            try mapView.mapboxMap.addSource(rasterSource)
            try mapView.mapboxMap.addLayer(rasterLayer)
        } catch {
            print("Failed to update the style. Error: \(error)")
        }
    }
}
