import UIKit
import MapboxMaps

@objc(SymbolClusteringExample)

public class SymbolClusteringExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Create a map view centered over Washington, DC.
        let center = CLLocationCoordinate2D(latitude: 38.889215, longitude: -77.039354)
        let cameraOptions = CameraOptions(center: center, zoom: 11)
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions, styleURI: .dark)
        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(mapView)

        // Add the source and style layers once the
        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            self.addSymbolClusteringLayers()
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        mapView.addGestureRecognizer(tap)
    }

    func addSymbolClusteringLayers() {
        let style = self.mapView.mapboxMap.style
        // The image named `fire-station-11` is included in the app's Assets.xcassets bundle.
        let image = UIImage(named: "fire-station-11")!.withRenderingMode(.alwaysTemplate)
        try! style.addImage(image, id: "fire-station-icon")

        // Fire_Hydrants.geojson contains information about fire hydrants in the District of Columbia.
        // It was downloaded on 6/10/21 from https://opendata.dc.gov/datasets/DCGIS::fire-hydrants/about
        guard let url = Bundle.main.url(forResource: "Fire_Hydrants", withExtension: "geojson") else {
            return
        }

        // Create a GeoJSONSource using the previously specified URL.
        var source = GeoJSONSource()
        source.data = .url(url)

        // Enable clustering for this source.
        source.cluster = true
        source.clusterRadius = 75
        let sourceID = "fire-hydrant-source"

        var clusteredLayer = createClusteredLayer()
        clusteredLayer.source = sourceID

        var unclusteredLayer = createUnclusteredLayer()
        unclusteredLayer.source = sourceID

        // Add the source and two layers to the map.
        try! style.addSource(source, id: sourceID)
        try! style.addLayer(clusteredLayer)
        try! style.addLayer(unclusteredLayer, layerPosition: .below(clusteredLayer.id))

        finish()
    }

    func createClusteredLayer() -> SymbolLayer {
        // Create a symbol layer to represent the clustered points.
        var clusteredLayer = SymbolLayer(id: "clustered-fire-hydrant-layer")
        clusteredLayer.filter = Exp(.has) { "point_count" }

        clusteredLayer.iconImage = .constant(.name("fire-station-icon"))

        // Set the color of the icons based on the number of points within
        // a given cluster. The first value is a default value.
        /**
         This JSON expression is transformed to swift below:
         [
           "interpolate",
           ["step"],
           ["get", "point_count"],
           ["rgba", "30.6", "229.5", "145.35", 1], 50, ["rgba", "30.6", "135.15", "229.5", 1], 100, ["rgba", "216.75", "28.05", "96.9", 1]
         ]
         */
        clusteredLayer.iconColor = .expression(Exp(.step) {
            Exp(.get) { "point_count" }
            UIColor(red: 0.12, green: 0.90, blue: 0.57, alpha: 1.00)
            50
            UIColor(red: 0.12, green: 0.53, blue: 0.90, alpha: 1.00)
            100
            UIColor(red: 0.85, green: 0.11, blue: 0.38, alpha: 1.00)
        })

        // Add an outline to the icons.
//        clusteredLayer.iconHaloColor = .constant(.init(color: .black))
//        clusteredLayer.iconHaloWidth = .constant(4)

        // Adjust the scale of the icons based on the number of points within an
        // individual cluster. The first value is a default value.
        clusteredLayer.iconSize = .expression(Exp(.step) {
            Exp(.get) { "point_count" }
            2.5
            0
            2.5
            50
            3
            100
            3.5
        })
        print(try! clusteredLayer.jsonObject())
        return clusteredLayer
    }
    
    func createUnclusteredLayer() -> SymbolLayer {
        // Create a symbol layer to represent the points that aren't clustered.
        var unclusteredLayer = SymbolLayer(id: "unclustered-point-layer")

        // Filter out clusters by checking for point_count.
        unclusteredLayer.filter = Exp(.not) {
        Exp(.has) { "point_count" }
        }
        unclusteredLayer.iconImage = .constant(.name("fire-station-icon"))
        unclusteredLayer.iconColor = .constant(.init(color: UIColor(red: 0.12, green: 0.90, blue: 0.57, alpha: 1.00)))
        // Rotate the icon image based on the recorded water flow.
        // The `mod` operator allows you to use the remainder after dividing
        // the specified values.
        unclusteredLayer.iconRotate = .expression(Exp(.mod) {
            Exp(.get) { "FLOW" }
            360
        })
        
        // Double the size of the icon image.
        unclusteredLayer.iconSize = .constant(2)
        return unclusteredLayer
    }
    
    @objc func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        let point = gestureRecognizer.location(in: mapView)

        // Look for features at the tap location within the unclustered layer.
        mapView.mapboxMap.queryRenderedFeatures(at: point,
                                                options: RenderedQueryOptions(layerIds: ["unclustered-point-layer", "clustered-fire-hydrant-layer"],
                                                filter: nil)) { [weak self] result in
            switch result {
            case .success(let queriedfeatures):
                // Return the first feature at that location, then pass attributes to the alert controller.
                if let firstFeature = queriedfeatures.first?.feature.properties,
                   let feature = firstFeature["ASSETNUM"] as? String, let location = firstFeature["LOCATIONDETAIL"] as? String {
                    self?.showAlert(with: "Hydrant \(feature)", and: "\(location)")
                } else if let firstFeature = queriedfeatures.first?.feature.properties,
                          let pointCount = firstFeature["point_count"],
                          let clusterId = firstFeature["cluster_id"] {
                    // If the tap landed on a cluster, pass the cluster ID and point count to the alert.
                    self?.showAlert(with: "Cluster ID \(clusterId)", and: "There are \(pointCount) points in this cluster")
                }
            case .failure(let error):
                self?.showAlert(with: "An error occurred: \(error.localizedDescription)", and: "Please try another hydrant")
            }
        }
    }

    // Present an alert with a given title and message.
    public func showAlert(with title: String, and message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
}
