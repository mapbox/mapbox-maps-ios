import UIKit
import MapboxMaps

@objc(ColorExpressionExample)

public class ColorExpressionExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Center the map over the United States.
        let centerCoordinate = CLLocationCoordinate2D(latitude: 40.58058466412761,
                                                      longitude: -97.734375)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate,
                                                                  zoom: 3))

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Allows the view controller to receive information about map events.
        mapView.mapboxMap.onNext(event: .mapLoaded) { [weak self] _ in
            self?.setupExample()
        }

    }

    // Wait for the style to load before adding data to it.
    public func setupExample() {
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
            try! mapView.mapboxMap.style.setLayerProperty(for: "land",
                                                          property: "background-color",
                                                          value: jsonObject)
        }

        // The below line is used for internal testing purposes only.
        finish()
    }
}
