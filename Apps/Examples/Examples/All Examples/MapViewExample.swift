import UIKit
import MapboxMaps

@objc(MapViewExample)
public class MapViewExample: UIViewController, ExampleProtocol {

    override public func viewDidLoad() {
        super.viewDidLoad()

        let mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        mapView.style.uri = StyleURI.custom(url: URL(string: "mapbox://styles/examples/cke97f49z5rlg19l310b7uu7j")!)

        mapView.mapboxMap.onNext(.styleLoaded) { _ in
            // The below line is used for internal testing purposes only.
            self.finish()
        }
    }
}
