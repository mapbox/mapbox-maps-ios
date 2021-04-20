import UIKit
import MapboxMaps

@objc(TerrainExample)
public class TerrainExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds,
                          styleURI: .custom(url: URL(string: "mapbox://styles/mapbox-map-design/ckhqrf2tz0dt119ny6azh975y")!))
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(mapView)

        let centerCoordinate = CLLocationCoordinate2D(latitude: 32.6141, longitude: -114.34411)

        mapView.on(.styleLoaded) { [weak self] _ in

            self?.mapView.cameraManager.setCamera(to: CameraOptions(center: centerCoordinate,
                                                              zoom: 10,
                                                              bearing: 80))

            self?.addTerrain()
        }

        mapView.on(.mapLoaded) { [weak self](_) in
            var animator = self?.mapView.cameraManager.makeCameraAnimator(duration: 10, curve: .easeInOut, animations: { (transition) in
                transition.zoom.toValue = 14.5
                transition.pitch.toValue = 85
            })

            animator?.addCompletion({ (_) in
                animator = nil
            })

            animator?.startAnimation()
        }
    }

    func addTerrain() {
        var demSource = RasterDemSource()
        demSource.url = "mapbox://mapbox.mapbox-terrain-dem-v1"
        demSource.tileSize = 512
        demSource.maxzoom = 14.0
        _ = mapView.style.addSource(source: demSource, identifier: "mapbox-dem")

        var terrain = Terrain(sourceId: "mapbox-dem")
        terrain.exaggeration = .constant(2.0)

        _ = mapView.style.setTerrain(terrain)

        var skyLayer = SkyLayer(id: "sky-layer")
        skyLayer.paint?.skyType = .constant(.atmosphere)
        skyLayer.paint?.skyAtmosphereSun = .constant([0.0, 0.0])
        skyLayer.paint?.skyAtmosphereSunIntensity = .constant(15.0)

        _ = mapView.style.addLayer(layer: skyLayer)
    }
}
