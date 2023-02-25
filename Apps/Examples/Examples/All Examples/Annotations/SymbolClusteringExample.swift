import UIKit
import MapboxMaps

@objc(SymbolClusteringExample)
class SymbolClusteringExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Create a `MapView` centered over Washington, DC.
        let center = CLLocationCoordinate2D(latitude: 38.889215, longitude: -77.039354)
        let cameraOptions = CameraOptions(center: center, zoom: 11)
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions, styleURI: .dark)
        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(mapView)

        // Add the source and style layers once the map has loaded.
        mapView.mapboxMap.onNext(event: .mapLoaded) { _ in
            self.addSymbolClusteringLayers()
        }

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        mapView.addGestureRecognizer(tapGestureRecognizer)
    }

    func addSymbolClusteringLayers() {
        let style = mapView.mapboxMap.style
        // The image named `fire-station-11` is included in the app's Assets.xcassets bundle.
        // In order to recolor an image, you need to add a template image to the map's style.
        // The image's rendering mode can be set programmatically or in the asset catalogue.
        let image = UIImage(named: "fire-station-11")!.withRenderingMode(.alwaysTemplate)

        // Add the image tp the map's style. Set `sdf` to `true`. This allows the icon images to be recolored.
        // For more information about `SDF`, or Signed Distance Fields, see
        // https://docs.mapbox.com/help/troubleshooting/using-recolorable-images-in-mapbox-maps/#what-are-signed-distance-fields-sdf
        try! style.addImage(image, id: "fire-station-icon", sdf: true)

        // Fire_Hydrants.geojson contains information about fire hydrants in the District of Columbia.
        // It was downloaded on 6/10/21 from https://opendata.dc.gov/datasets/DCGIS::fire-hydrants/about
        let url = Bundle.main.url(forResource: "Fire_Hydrants", withExtension: "geojson")!

        // Create a GeoJSONSource using the previously specified URL.
        var source = GeoJSONSource()
        source.generateId = true
        source.data = .url(url)

        // Enable clustering for this source.
        source.cluster = true
        source.clusterRadius = 75

        // Create expression to identify the max flow rate of one hydrant in the cluster
        // ["max", ["get", "FLOW"]]
        let maxExpression = Exp(.max) {Exp(.get) { "FLOW" }}

        // Create expression to determine if a hydrant with EngineID E-9 is in the cluster
        // ["any", ["==", ["get", "ENGINEID"], "E-9"]]
        let ine9Expression = Exp(.any) {
            Exp(.eq) {
                Exp(.get) { "ENGINEID" }
                "E-9"
            }
        }

        // Create expression to get the sum of all of the flow rates in the cluster
        // [["+", ["accumulated"], ["get", "sum"]], ["get", "FLOW"]]
        let sumExpression = Exp {
            Exp(.sum) {
                Exp(.accumulated)
                Exp(.get) { "sum" }
            }
            Exp(.get) { "FLOW" }
        }

        // Add the expressions to the cluster as ClusterProperties so they can be accessed below
        let clusterProperties: [String: Expression] = [
            "max": maxExpression,
            "in_e9": ine9Expression,
            "sum": sumExpression
        ]
        source.clusterProperties = clusterProperties

        let sourceID = "fire-hydrant-source"

        var clusteredLayer = createClusteredLayer()
        clusteredLayer.source = sourceID

        var unclusteredLayer = createUnclusteredLayer()
        unclusteredLayer.source = sourceID

        // `clusterCountLayer` is a `SymbolLayer` that represents the point count within individual clusters.
        var clusterCountLayer = createNumberLayer()
        clusterCountLayer.source = sourceID

        // Add the source and two layers to the map.
        try! style.addSource(source, id: sourceID)
        try! style.addLayer(clusteredLayer)
        try! style.addLayer(unclusteredLayer, layerPosition: .below(clusteredLayer.id))
        try! style.addLayer(clusterCountLayer)

        // This is used for internal testing purposes only and can be excluded
        // from your implementation.
        finish()
    }

    func createClusteredLayer() -> CircleLayer {
        // Create a symbol layer to represent the clustered points.
        var clusteredLayer = CircleLayer(id: "clustered-circle-layer")

        // Filter out unclustered features by checking for `point_count`. This
        // is added to clusters when the cluster is created. If your source
        // data includes a `point_count` property, consider checking
        // for `cluster_id`.
        clusteredLayer.filter = Exp(.has) { "point_count" }

        // Set the color of the icons based on the number of points within
        // a given cluster. The first value is a default value.
        clusteredLayer.circleColor = .expression(
            Exp(.switchCase) {
                Exp(.boolean) {
                    Exp(.featureState) { "selected" }
                    false
                }
                UIColor.systemGreen
                UIColor.systemBlue
            }
        )

        clusteredLayer.circleRadius = .constant(25)

        return clusteredLayer
    }

    func createUnclusteredLayer() -> CircleLayer {
        // Create a symbol layer to represent the points that aren't clustered.
        var unclusteredLayer = CircleLayer(id: "unclustered-point-layer")

        // Filter out clusters by checking for `point_count`.
        unclusteredLayer.filter = Exp(.not) {
            Exp(.has) { "point_count" }
        }
        unclusteredLayer.circleColor = .expression(
            Exp(.switchCase) {
                Exp(.boolean) {
                    Exp(.featureState) { "selected" }
                    false
                }
                UIColor.systemGreen
                UIColor.systemBlue
            }
        )


        return unclusteredLayer
    }

    func createNumberLayer() -> SymbolLayer {
        var numberLayer = SymbolLayer(id: "cluster-count-layer")

        // check whether the point feature is clustered
        numberLayer.filter = Exp(.has) { "point_count" }

        // Display the value for 'point_count' in the text field
        numberLayer.textField = .expression(Exp(.get) { "point_count" })
        numberLayer.textSize = .constant(12)
        return numberLayer
    }

    @objc func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        let point = gestureRecognizer.location(in: mapView)

        // Look for features at the tap location within the clustered and
        // unclustered layers.
        mapView.mapboxMap.queryRenderedFeatures(with: point,
                                                options: RenderedQueryOptions(layerIds: ["unclustered-point-layer", "clustered-circle-layer"],
                                                filter: nil)) { [weak self] result in
            switch result {
            case .success(let queriedFeatures):

                if case .number(let featureId) = queriedFeatures.first?.feature.identifier {            
                    self!.mapView.mapboxMap.setFeatureState(
                        sourceId: "fire-hydrant-source",
                        featureId: Int(featureId).description,
                        state: ["selected": true])
                }
            case .failure(let error):
                self?.showAlert(withTitle: "An error occurred: \(error.localizedDescription)", and: "Please try another hydrant")
            }
        }
    }

    // Present an alert with a given title and message.
    func showAlert(withTitle title: String, and message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
}
