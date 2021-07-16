import UIKit
import MapboxMaps

@objc(PointClusteringExample)

public class PointClusteringExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Initialize a map view centered over the United States and using the Mapbox Dark style.
        let center = CLLocationCoordinate2D(latitude: 40.669957, longitude: -103.5917968)
        let cameraOptions = CameraOptions(center: center, zoom: 2)
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions, styleURI: .dark)

        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.tintColor = .lightGray

        view.addSubview(mapView)

        mapView.mapboxMap.onNext(.styleLoaded) { _ in
            self.addPointClusters()
        }
    }

    func addPointClusters() {
        let style = self.mapView.mapboxMap.style
        // Parse GeoJSON data. This example uses all M1.0+ earthquakes from 12/22/15 to 1/21/16 as logged by USGS' Earthquake hazards program.
        guard let url = URL(string: "https://www.mapbox.com/mapbox-gl-js/assets/earthquakes.geojson") else { return }

        // Create a GeoJSONSource from the earthquake data URL.
        var source = GeoJSONSource()
        source.data = .url(url)

        // Set the clustering properties directly on the source.
        source.cluster = true
        source.clusterRadius = 50

        // The maximum zoom level where points will be clustered.
        source.clusterMaxZoom = 14
        let sourceID = "earthquake-source"

        // Create three separate layers from the same source.
        // `clusteredLayer` contains clustered point features.
        var clusteredLayer = createClusteredLayer()
        clusteredLayer.source = sourceID

        // `unclusteredLayer` contains individual point features that do not represent clusters.
        var unclusteredLayer = createUnclusteredLayer()
        unclusteredLayer.source = sourceID

        // `clusterCountLayer` is a `SymbolLayer` that represents the point count within individual clusters.
        var clusterCountLayer = createNumberLayer()
        clusterCountLayer.source = sourceID

        // Add source and layers to the map view's style.
        try! style.addSource(source, id: sourceID)
        try! style.addLayer(clusteredLayer)
        try! style.addLayer(unclusteredLayer, layerPosition: .below(clusteredLayer.id))
        try! style.addLayer(clusterCountLayer)
    }

    func createClusteredLayer() -> CircleLayer {
        // Create a `CircleLayer` that only contains clustered points.
        var clusteredLayer = CircleLayer(id: "clustered-earthquake-layer")
        clusteredLayer.filter = Exp(.has) { "point_count" }

        // Set the circle's color and radius based on the number of points within each cluster.
        clusteredLayer.circleColor =  .expression(Exp(.step) {
            Exp(.get) { "point_count" }
            UIColor(red: 0.32, green: 0.73, blue: 0.84, alpha: 1.00)
            100
            UIColor(red: 0.95, green: 0.94, blue: 0.46, alpha: 1.00)
            750
            UIColor(red: 0.95, green: 0.55, blue: 0.69, alpha: 1.00)
        })

        clusteredLayer.circleRadius = .expression(Exp(.step) {
            Exp(.get) { "point_count" }
            20
            100
            30
            750
            40
        })

        return clusteredLayer
    }

    func createUnclusteredLayer() -> CircleLayer {
        var unclusteredLayer = CircleLayer(id: "unclusteredPointLayer")

        // Filter out clusters by checking for point_count.
        unclusteredLayer.filter = Exp(.not) {
        Exp(.has) { "point_count" }
        }

        unclusteredLayer.circleColor = .constant(ColorRepresentable(color: UIColor(red: 0.07, green: 0.71, blue: 0.85, alpha: 1.00)))
        unclusteredLayer.circleRadius = .constant(4)
        unclusteredLayer.circleStrokeWidth = .constant(1)
        unclusteredLayer.circleStrokeColor = .constant(ColorRepresentable(color: .black))
        return unclusteredLayer
    }

    func createNumberLayer() -> SymbolLayer {
        var numberLayer = SymbolLayer(id: "cluster-count-layer")

        // Check whether the point feature is clustered.
        numberLayer.filter = Exp(.has) { "point_count" }

        // Display the value for 'point_count' in the text field.
        numberLayer.textField = .expression(Exp(.get) { "point_count" })
        numberLayer.textSize = .constant(12)
        return numberLayer
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         // The below line is used for internal testing purposes only.
        finish()
    }
}
