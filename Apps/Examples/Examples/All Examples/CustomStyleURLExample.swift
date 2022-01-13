#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
import MapboxMaps

@objc(CustomStyleURLExample)
internal class CustomStyleURLExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

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

        mapView.mapboxMap.onNext(.styleLoaded) { [weak self] _ in
            // The below line is used for internal testing purposes only.
            self?.finish()
        }
    }
}
