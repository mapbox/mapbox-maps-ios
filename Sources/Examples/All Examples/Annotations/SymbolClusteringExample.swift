import UIKit
import MapboxMaps

final class SymbolClusteringExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var cancelables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create a `MapView` centered over Washington, DC.
        let center = CLLocationCoordinate2D(latitude: 38.889215, longitude: -77.039354)
        let cameraOptions = CameraOptions(center: center, zoom: 11)
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions, styleURI: .dark)
        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(mapView)

        // Add the source and style layers once the map has loaded.
        mapView.mapboxMap.onMapLoaded.observeNext { _ in
            self.addSymbolClusteringLayers()
        }.store(in: &cancelables)

        // Add tap handers to and clustered and unclustered layers.
        for layer in ["unclustered-point-layer", "clustered-circle-layer"] {
            mapView.mapboxMap.addInteraction(TapInteraction(.layer(layer)) { [weak self] feature, _ in
                return self?.handleTap(feature: feature) ?? false
            })
        }
    }

    func addSymbolClusteringLayers() {
        // The image named `fire-station-11` is included in the app's Assets.xcassets bundle.
        // In order to recolor an image, you need to add a template image to the map's style.
        // The image's rendering mode can be set programmatically or in the asset catalogue.
        let image = UIImage(named: "fire-station-11")!.withRenderingMode(.alwaysTemplate)

        // Add the image tp the map's style. Set `sdf` to `true`. This allows the icon images to be recolored.
        // For more information about `SDF`, or Signed Distance Fields, see
        // https://docs.mapbox.com/help/troubleshooting/using-recolorable-images-in-mapbox-maps/#what-are-signed-distance-fields-sdf
        try! mapView.mapboxMap.addImage(image, id: "fire-station-icon", sdf: true)

        // Fire_Hydrants.geojson contains information about fire hydrants in the District of Columbia.
        // It was downloaded on 6/10/21 from https://opendata.dc.gov/datasets/DCGIS::fire-hydrants/about
        let url = Bundle.main.url(forResource: "Fire_Hydrants", withExtension: "geojson")!

        // Create a GeoJSONSource using the previously specified URL.
        var source = GeoJSONSource(id: "fire-hydrant-source")
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
        let clusterProperties: [String: Exp] = [
            "max": maxExpression,
            "in_e9": ine9Expression,
            "sum": sumExpression
        ]
        source.clusterProperties = clusterProperties

        let clusteredLayer = createClusteredLayer(source: source.id)
        let unclusteredLayer = createUnclusteredLayer(source: source.id)

        // `clusterCountLayer` is a `SymbolLayer` that represents the point count within individual clusters.
        let clusterCountLayer = createNumberLayer(source: source.id)

        // Add the source and two layers to the map.
        try! mapView.mapboxMap.addSource(source)
        try! mapView.mapboxMap.addLayer(clusteredLayer)
        try! mapView.mapboxMap.addLayer(unclusteredLayer, layerPosition: .below(clusteredLayer.id))
        try! mapView.mapboxMap.addLayer(clusterCountLayer)

        // This is used for internal testing purposes only and can be excluded
        // from your implementation.
        finish()
    }

    func createClusteredLayer(source: String) -> CircleLayer {
        // Create a symbol layer to represent the clustered points.
        var clusteredLayer = CircleLayer(id: "clustered-circle-layer", source: source)

        // Filter out unclustered features by checking for `point_count`. This
        // is added to clusters when the cluster is created. If your source
        // data includes a `point_count` property, consider checking
        // for `cluster_id`.
        clusteredLayer.filter = Exp(.has) { "point_count" }

        // Set the color of the icons based on the number of points within
        // a given cluster. The first value is a default value.
        clusteredLayer.circleColor = .expression(Exp(.step) {
            Exp(.get) { "point_count" }
            UIColor.systemGreen
            50
            UIColor.systemBlue
            100
            UIColor.systemRed
        })

        clusteredLayer.circleRadius = .constant(25)

        return clusteredLayer
    }

    func createUnclusteredLayer(source: String) -> SymbolLayer {
        // Create a symbol layer to represent the points that aren't clustered.
        var unclusteredLayer = SymbolLayer(id: "unclustered-point-layer", source: source)

        // Filter out clusters by checking for `point_count`.
        unclusteredLayer.filter = Exp(.not) {
            Exp(.has) { "point_count" }
        }
        unclusteredLayer.iconImage = .constant(.name("fire-station-icon"))
        unclusteredLayer.iconColor = .constant(StyleColor(.white))

        // Rotate the icon image based on the recorded water flow.
        // The `mod` operator allows you to use the remainder after dividing
        // the specified values.
        unclusteredLayer.iconRotate = .expression(Exp(.mod) {
            Exp(.get) { "FLOW" }
            360
        })

        return unclusteredLayer
    }

    func createNumberLayer(source: String) -> SymbolLayer {
        var numberLayer = SymbolLayer(id: "cluster-count-layer", source: source)

        // check whether the point feature is clustered
        numberLayer.filter = Exp(.has) { "point_count" }

        // Display the value for 'point_count' in the text field
        numberLayer.textField = .expression(Exp(.get) { "point_count" })
        numberLayer.textSize = .constant(12)
        return numberLayer
    }

    // Shows cluster or hydrant info. Returns false if couldn't parse data.
    private func handleTap(feature: FeaturesetFeature) -> Bool {
        let selectedFeatureProperties = feature.properties
        if case let .string(featureInformation) = selectedFeatureProperties["ASSETNUM"],
           case let .string(location) = selectedFeatureProperties["LOCATIONDETAIL"] {
            showAlert(withTitle: "Hydrant \(featureInformation)", and: "\(location)")
            // If the feature is a cluster, it will have `point_count` and `cluster_id` properties.
            // These are assigned when the cluster is created.
            return true
        }

        if case let .number(pointCount) = selectedFeatureProperties["point_count"],
           case let .number(clusterId) = selectedFeatureProperties["cluster_id"],
           case let .number(maxFlow) = selectedFeatureProperties["max"],
           case let .number(sum) = selectedFeatureProperties["sum"],
           case let .boolean(in_e9) = selectedFeatureProperties["in_e9"] {
            // If the tap landed on a cluster, pass the cluster ID and point count to the alert.
            let inEngineNine = in_e9 ? "Some hydrants belong to Engine 9." : "No hydrants belong to Engine 9."
            showAlert(withTitle: "Cluster ID \(Int(clusterId))", and: "There are \(Int(pointCount)) hydrants in this cluster. The highest water flow is \(Int(maxFlow)) and the collective flow is \(Int(sum)). \(inEngineNine)")
            return true
        }
        return false
    }
}
