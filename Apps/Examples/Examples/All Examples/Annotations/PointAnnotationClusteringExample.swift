import UIKit
import MapboxMaps

@objc(PointAnnotationClusteringExample)
class PointAnnotationClusteringExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Center the map over Washington, DC.
        let center = CLLocationCoordinate2D(latitude: 38.889215, longitude: -77.039354)
        let cameraOptions = CameraOptions(center: center, zoom: 11)
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions, styleURI: .light)
        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(mapView)

        // Add the source and style layers once the map has loaded.
        mapView.mapboxMap.onNext(event: .mapLoaded) { _ in
            self.addPointAnnotations()
        }
    }

    func addPointAnnotations() {
        // The image named `fire-station-11` is included in the app's Assets.xcassets bundle.
        let image = UIImage(named: "fire-station-11")!
        // Fire_Hydrants.geojson contains information about fire hydrants in the District of Columbia.
        // It was downloaded on 6/10/21 from https://opendata.dc.gov/datasets/DCGIS::fire-hydrants/about
        // Decode the GeoJSON into a feature collection on a background thread
        _ = Bundle.main.url(forResource: "Fire_Hydrants", withExtension: "geojson")!
        DispatchQueue.global(qos: .userInitiated).async {
            guard let featureCollection = try? self.decodeGeoJSON(from: "Fire_Hydrants") else {
                return
            }

            // Create an array of annotations for each fire hydrant
            var annotations = [PointAnnotation]()
            for feature in featureCollection.features {
                guard let geometry = feature.geometry, case let Geometry.point(point) = geometry else {
                    return
                }
                var pointAnnotation = PointAnnotation(coordinate: point.coordinates)
                pointAnnotation.image = .init(image: image, name: "fire-station-11")
                annotations.append(pointAnnotation)
            }
            DispatchQueue.main.async {
                self.createClusters(annotations: annotations)
            }
        }
    }

    func createClusters(annotations: [PointAnnotation]) {
        // Use a step expressions (https://docs.mapbox.com/mapbox-gl-js/style-spec/#expressions-step)
        // with three steps to implement three sizes of circles:
        //   * 15 when point count is less than 50
        //   * 20 when point count is between 50 and 100
        //   * 25 when point count is greater than or equal to 100
        let circleRadiusExpression = Exp(.step) {
            Exp(.get) {"point_count"}
            15
            50
            20
            100
            25
        }

        // Use color levels to implement three colors of circles:
        //   * green when point count is less than 50
        //   * cyan when point count is between 50 and 100
        //   * red when point count is greater than or equal to 100
        let colorLevels = [
            (pointCount: 100, clusterColor: StyleColor(.red)),
            (pointCount: 50, clusterColor: StyleColor(.cyan)),
            (pointCount: 0, clusterColor: StyleColor(.green))]

        // Select the options for clustering and pass them to the PointAnnotationManager to display
        let clusterOptions = ClusterOptions(clusterRadius: 75, circleRadius: .expression(circleRadiusExpression), textColor: .constant(StyleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))), colorLevels: colorLevels)
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
