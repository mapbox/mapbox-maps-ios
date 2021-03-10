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

        self.mapView = MapView(with: view.bounds,
                               resourceOptions: resourceOptions,
                               styleURL: .custom(url: URL(string: "mapbox://styles/mapbox-map-design/ckhqrf2tz0dt119ny6azh975y")!))
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        self.view.addSubview(mapView)

        let centerCoordinate = CLLocationCoordinate2D(latitude: 32.6141, longitude: -114.34411)
        mapView.cameraManager.setCamera(centerCoordinate: centerCoordinate,
                                        zoom: 13.1,
                                        bearing: 80,
                                        pitch: 85)

        self.mapView.on(.styleLoadingFinished) { [weak self] _ in
            self?.addTerrain()
        }
    }

    func addTerrain() {
        var demSource = RasterDemSource()
        demSource.url = "mapbox://mapbox.mapbox-terrain-dem-v1"
        demSource.tileSize = 512
        demSource.maxzoom = 14.0
        _ = self.mapView.style.addSource(source: demSource, identifier: "mapbox-dem")

        var terrain = Terrain(sourceId: "mapbox-dem")
        terrain.exaggeration = .constant(1.5)

        _ = self.mapView.style.setTerrain(terrain)

        var skyLayer = SkyLayer(id: "sky-layer")
        skyLayer.paint?.skyType = .atmosphere
        skyLayer.paint?.skyAtmosphereSun = .constant([0.0, 0.0])
        skyLayer.paint?.skyAtmosphereSunIntensity = .constant(15.0)

        _ = self.mapView.style.addLayer(layer: skyLayer)
    }
}
