import UIKit
import MapboxMaps

@objc(SymbolClusteringExample)

public class SymbolClusteringExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        let center = CLLocationCoordinate2D(latitude: 38.87031, longitude: -77.00897)
        let cameraOptions = CameraOptions(center: center, zoom: 10)
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions, styleURI: .dark)
        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(mapView)
        
        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            self.addSymbolClusteringLayer()
        }
    }

    func addSymbolClusteringLayer() {
        let style = self.mapView.mapboxMap.style
        guard let url = Bundle.main.url(forResource: "Fire_Hydrants", withExtension: "geojson") else {
            return
        }

        // Add 
        var source = GeoJSONSource()
        source.data = .url(url)

        source.cluster = true
        source.clusterRadius = 75
        let sourceID = "fire-hydrant-source"
        
        var clusteredLayer = createClusteredLayer()
        clusteredLayer.source = sourceID
        
        var unclusteredLayer = createUnclusteredLayer()
        unclusteredLayer.source = sourceID
        
        try! style.addSource(source, id: sourceID)
        try! style.addLayer(clusteredLayer)
        try! style.addLayer(unclusteredLayer, layerPosition: .below(clusteredLayer.id))
        
    }

    func createClusteredLayer() -> CircleLayer {
        var clusteredLayer = CircleLayer(id: "clustered-fire-hydrant-layer")
        clusteredLayer.filter = Exp(.has) { "point_count" }

        clusteredLayer.circleColor = .expression(Exp(.step) {
            Exp(.get) { "point_count" }
            UIColor(red: 0.85, green: 0.11, blue: 0.38, alpha: 1.00)
            0
            UIColor(red: 0.12, green: 0.90, blue: 0.57, alpha: 1.00)
            50
            UIColor(red: 0.12, green: 0.53, blue: 0.90, alpha: 1.00)
            100
            UIColor(red: 0.85, green: 0.11, blue: 0.38, alpha: 1.00)
        })
        clusteredLayer.circleRadius = .constant(25)
        return clusteredLayer
    }
    
    func createUnclusteredLayer() -> SymbolLayer {
        
        var unclusteredLayer = SymbolLayer(id: "unclusteredPointLayer")

        // Filter out clusters by checking for point_count.
        unclusteredLayer.filter = Exp(.not) {
        Exp(.has) { "point_count" }
        }

        unclusteredLayer.iconImage = .constant(.name("fire-station-11"))
        unclusteredLayer.iconSize = .constant(2)
        unclusteredLayer.iconHaloColor = .constant(ColorRepresentable(color: UIColor(red: 0.85, green: 0.11, blue: 0.38, alpha: 1.00)))
        return unclusteredLayer
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         // The below line is used for internal testing purposes only.
        finish()
    }
}
