import UIKit
import MapboxMaps

@objc(PointAnnotationClusteringExample)
class PointAnnotationClusteringExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Create a `MapView` centered over Washington, DC.
        let center = CLLocationCoordinate2D(latitude: 38.889215, longitude: -77.039354)
        let cameraOptions = CameraOptions(center: center, zoom: 11)
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions, styleURI: .light)
        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(mapView)

        // Add the source and style layers once the map has loaded.
        mapView.mapboxMap.onNext(event: .mapLoaded) { _ in
            self.addSymbolClusteringLayers()
        }
    }

    func addSymbolClusteringLayers() {
        // The image named `fire-station-11` is included in the app's Assets.xcassets bundle.
        let image = UIImage(named: "fire-station-11")!
        // Fire_Hydrants.geojson contains information about fire hydrants in the District of Columbia.
        // It was downloaded on 6/10/21 from https://opendata.dc.gov/datasets/DCGIS::fire-hydrants/about
        _ = Bundle.main.url(forResource: "Fire_Hydrants", withExtension: "geojson")!
        guard let featureCollection = try? decodeGeoJSON(from: "Fire_Hydrants") else {
            return
        }

        var annotations = [PointAnnotation]()
        for feature in featureCollection.features {
            guard let geometry = feature.geometry, case let Geometry.point(point) = geometry else {
                return
            }
            var pointAnnotation = PointAnnotation(coordinate: point.coordinates)
            pointAnnotation.image = .init(image: image, name: "fire-station-11")
            annotations.append(pointAnnotation)
        }

        let clusterOptions = ClusterOptions(clusterRadius: 75, circleRadius: .constant(18), colorLevels: [(100, StyleColor(.red)), (50, StyleColor(.cyan)), (0, StyleColor(.green))])
        let pointAnnotationManager = mapView.annotations.makePointAnnotationManager(clusterOptions: clusterOptions)
        pointAnnotationManager.annotations = annotations

        finish()
    }

    // Load GeoJSON file from local bundle and decode into a `FeatureCollection`.
    func decodeGeoJSON(from fileName: String) throws -> FeatureCollection? {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "geojson") else {
            preconditionFailure("File '\(fileName)' not found.")
        }
        let filePath = URL(fileURLWithPath: path)
        var featureCollection: FeatureCollection?
        do {
            let data = try Data(contentsOf: filePath)
            featureCollection = try JSONDecoder().decode(FeatureCollection.self, from: data)
        } catch {
            print("Error parsing data: \(error)")
        }
        return featureCollection
    }
}
