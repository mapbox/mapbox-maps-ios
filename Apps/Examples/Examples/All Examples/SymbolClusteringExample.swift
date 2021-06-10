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
        guard let url = Bundle.main.url(forResource: "Fire-Hydrants", withExtension: "geojson") else {
            return
        }

        var source = GeoJSONSource()
        source.data = .url(url)
        
        source.cluster = true
        source.clusterRadius
        let sourceID = "fire-hydrant-source"
        
        
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         // The below line is used for internal testing purposes only.
        finish()
    }
}
