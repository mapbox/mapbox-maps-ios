import UIKit
import MapboxMaps

@objc(SymbolClusteringExample)

public class SymbolClusteringExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(mapView)
        
        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            self.addSymbolClusteringLayer()
        }
    }

    func addSymbolClusteringLayer() {
        let style = self.mapView.mapboxMap.style
        guard let url = Bundle.main.url(forResource: "Fire-Hydrants", withExtension: "geojson") else {
            return
        }

        var source = GeoJSONSource()
        source.data = .url(url)
        
        source.cluster = true
        source.clusterRadius = 50
        let sourceID = "fire-hydrant-source"
        
        var clusteredLayer = createClusteredLayer()
        clusteredLayer.source = sourceID
        
        try! style.addSource(source, id: sourceID)
        try! style.addLayer(clusteredLayer)
        
    }

    func createClusteredLayer() -> CircleLayer {
        var clusteredLayer = CircleLayer(id: "clustered-fire-hydrant-layer")
        clusteredLayer.filter = Exp(.has) { "point_count" }
        
        clusteredLayer.circleColor = .expression(Exp(.step) {
            Exp(.get) { "point_count" }
            UIColor.green
            0
            UIColor.blue
            50
            UIColor.red
            100
        })
        return clusteredLayer
    }
    
    func createUnclusteredLayer() {
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         // The below line is used for internal testing purposes only.
        finish()
    }
}
