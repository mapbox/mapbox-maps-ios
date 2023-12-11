import UIKit
import MapboxMaps

final class ColorExpressionExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var cancelables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Center the map over the United States.
        let centerCoordinate = CLLocationCoordinate2D(latitude: 40.58058466412761,
                                                      longitude: -97.734375)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 3), styleURI: .streets)

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Allows the view controller to receive information about map events.
        mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
            self?.setupExample()
        }.store(in: &cancelables)

    }

    // Wait for the style to load before adding data to it.
    func setupExample() {
        /**
         This JSON expression is transformed to swift below:
         [
           "interpolate",
           ["linear"],
           ["zoom"],
           0,
           "hsl(0, 79%, 53%)",
           14,
           "hsl(233, 80%, 47%)"
         ]
         */

        let stops: [Double: UIColor] = [
            0: .red,
            14: .blue
        ]

        let exp = Exp(.interpolate) {
            Exp(.linear)
            Exp(.zoom)
            stops
        }

        if let data = try? JSONEncoder().encode(exp.self),
           let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) {
            try! mapView.mapboxMap.setLayerProperty(for: "land",
                                                          property: "background-color",
                                                          value: jsonObject)
        }

        // The below line is used for internal testing purposes only.
        finish()
    }
}
