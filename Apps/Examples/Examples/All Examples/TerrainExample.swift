import UIKit
import MapboxMaps

@objc(TerrainExample)
public class TerrainExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        guard let accessToken = AccountManager.shared.accessToken else {
            fatalError("Access token not set")
        }

        let resourceOptions = ResourceOptions(accessToken: accessToken)

        mapView = MapView(with: view.bounds,
                          resourceOptions: resourceOptions,
                          styleURI: .custom(url: URL(string: "mapbox://styles/mapbox-map-design/ckhqrf2tz0dt119ny6azh975y")!))
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(mapView)

        let centerCoordinate = CLLocationCoordinate2D(latitude: 32.6141, longitude: -114.34411)
        mapView.cameraManager.setCamera(centerCoordinate: centerCoordinate,
                                        zoom: 13.1,
                                        bearing: 80,
                                        pitch: 85)

        mapView.on(.styleLoaded) { [weak self] _ in
            self?.addTerrain()
        }
    }

    func addTerrain() {
        var demSource = RasterDemSource()
        demSource.url = "mapbox://mapbox.mapbox-terrain-dem-v1"
        demSource.tileSize = 512
        demSource.maxzoom = 14.0
        _ = mapView.style.addSource(source: demSource, identifier: "mapbox-dem")

        var terrain = Terrain(sourceId: "mapbox-dem")
        terrain.exaggeration = .constant(1.5)

        _ = mapView.style.setTerrain(terrain)

        var skyLayer = SkyLayer(id: "sky-layer")
        skyLayer.paint?.skyType = .constant(.atmosphere)
        skyLayer.paint?.skyAtmosphereSun = .constant([0.0, 0.0])
        skyLayer.paint?.skyAtmosphereSunIntensity = .constant(15.0)

        _ = mapView.style.addLayer(layer: skyLayer)
    }
}
