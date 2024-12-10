import MapboxMaps
import UIKit

final class RasterColorExample: UIViewController, ExampleProtocol {
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
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions)

        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Once the map has finished loading, add the `RasterSource` and `RasterLayer` to the map's style.
        mapView.mapboxMap.onMapLoaded.observeNext { _ in
            self.setupExample()

            // The following line is just for testing purposes.
            self.finish()
        }.store(in: &cancelables)
    }

    func setupExample() {

        var rasterSource = RasterSource(id: "raster-source-id")
        rasterSource.url = "mapbox://mapbox.terrain-rgb"
        rasterSource.tileSize = 256

        var backgroundLayer = BackgroundLayer(id: "background-layer-id")
        backgroundLayer.backgroundColor = .constant(StyleColor(red: 4.0, green: 7.0, blue: 14.0, alpha: 1)!)

        var rasterLayer = RasterLayer(id: "raster-layer-id", source: rasterSource.id)
        rasterLayer.rasterColor = .expression(Exp(.interpolate) {
            Exp(.linear)
            Exp(.rasterValue)
            35.392
            "rgb(48, 167, 228)"
            44.24
            "rgb(57, 143, 83)"
            274.288
            "rgb(116, 166, 129)"
            486.64
            "rgb(178, 205, 174)"
            672.448
            "rgb(188, 195, 169)"
            955.584
            "rgb(221, 207, 153)"
            1353.744
            "rgb(211, 174, 114)"
            1813.84
            "rgb(207, 155, 103)"
            2450.896
            "rgb(179, 120, 85)"
            3318
            "rgb(227, 210, 197)"
            5839.68
            "rgb(255, 255, 255)"
        })
        rasterLayer.rasterColorMix = .constant([
            1667721.6,
            6553.6,
            25.6,
            -10000
        ])
        rasterLayer.rasterColorRange = .constant([0, 8848])

        do {
            try mapView.mapboxMap.addLayer(backgroundLayer)
            try mapView.mapboxMap.addLayer(rasterLayer)
            try mapView.mapboxMap.addSource(rasterSource)
        } catch {
            print(error)
        }
    }
}
