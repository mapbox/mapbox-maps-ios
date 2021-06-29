import UIKit
import MapboxMaps

@objc(TerrainExample)
public class TerrainExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        let centerCoordinate = CLLocationCoordinate2D(latitude: 32.6141, longitude: -114.34411)
        let camera = CameraOptions(center: centerCoordinate,
                                   zoom: 13.1,
                                   bearing: 80,
                                   pitch: 85)
        let options = MapInitOptions(
            cameraOptions: camera,
            styleURI: StyleURI(rawValue: "mapbox://styles/mapbox-map-design/ckhqrf2tz0dt119ny6azh975y")!)

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(mapView)

        mapView.mapboxMap.onNext(.styleLoaded) { _ in
            self.addTerrain()
        }
    }

    func addTerrain() {
        var demSource = RasterDemSource()
        demSource.url = "mapbox://mapbox.mapbox-terrain-dem-v1"
        // Setting the `tileSize` to 514 provides better performance and adds padding around the outside
        // of the tiles.
        demSource.tileSize = 514
        demSource.maxzoom = 14.0
        try! mapView.mapboxMap.style.addSource(demSource, id: "mapbox-dem")

        var terrain = Terrain(sourceId: "mapbox-dem")
        terrain.exaggeration = .constant(1.5)

        try! mapView.mapboxMap.style.setTerrain(terrain)

        var skyLayer = SkyLayer(id: "sky-layer")
        skyLayer.skyType = .constant(.atmosphere)
        skyLayer.skyAtmosphereSun = .constant([0.0, 0.0])
        skyLayer.skyAtmosphereSunIntensity = .constant(15.0)

        try! mapView.mapboxMap.style.addLayer(skyLayer)
    }
}
