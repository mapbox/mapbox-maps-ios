import UIKit
import MapboxMaps

@objc(PointAnnotationClusteringExample)
class PointAnnotationClusteringExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Center the map over Washington, D.C.
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
        // Fire_Hydrants.geojson contains information about fire hydrants in Washington, D.C.
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
        //   * 25 when point count is less than 50
        //   * 30 when point count is between 50 and 100
        //   * 35 when point count is greater than or equal to 100
        let circleRadiusExpression = Exp(.step) {
            Exp(.get) {"point_count"}
            25
            50
            30
            100
            35
        }

        // Use a similar expression to get different colors of circles:
        //   * yellow when point count is less than 10
        //   * green when point count is between 10 and 50
        //   * cyan when point count is between 50 and 100
        //   * red when point count is between 100 and 150
        //   * orange when point count is between 150 and 250
        //   * light pink when point count is greater than or equal to 250
        let circleColorExpression = Exp(.step) {
            Exp(.get) {"point_count"}
            UIColor.yellow
            10
            UIColor.green
            50
            UIColor.cyan
            100
            UIColor.red
            150
            UIColor.orange
            250
            UIColor.lightPink
        }

        // Create a cluster property to add to each cluster feature
        // This will be added to the cluster textField below
        let clusterProperty: [String: Expression] = ["pointString": Exp(.string) { "Count:\n" }]

        // Select the options for clustering and pass them to the PointAnnotationManager to display
        let clusterOptions = ClusterOptions(circleRadius: .expression(circleRadiusExpression),
                                            circleColor: .expression(circleColorExpression),
                                            textColor: .constant(StyleColor(.black)),
                                            textField: .expression(Exp(.concat) {
                                                Exp(.get) {"pointString"}
                                                Exp(.get) {"point_count"}
                                            }),
                                            clusterRadius: 75,
                                            clusterProperties: clusterProperty)
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
