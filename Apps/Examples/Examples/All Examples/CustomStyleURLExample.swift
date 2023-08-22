import UIKit
import MapboxMaps

internal class CustomStyleURLExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!
    private var cancelables = Set<AnyCancelable>()

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Create a URL for a custom style created in Mapbox Studio.
        guard let customStyleURI = StyleURI(rawValue: "mapbox://styles/examples/cke97f49z5rlg19l310b7uu7j") else {
            fatalError("Style URI is invalid")
        }

        let options = MapInitOptions(styleURI: customStyleURI)
        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.mapboxMap.onStyleLoaded.observeNext { [weak self] _ in
            // The below line is used for internal testing purposes only.
            self?.finish()
        }.store(in: &cancelables)
    }
}
