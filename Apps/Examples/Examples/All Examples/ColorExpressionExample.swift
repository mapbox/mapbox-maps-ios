import UIKit
import MapboxMaps

@objc(ColorExpressionExample)

public class ColorExpressionExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(with: view.bounds, resourceOptions: resourceOptions())
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Center the map over the United States.
        let centerCoordinate = CLLocationCoordinate2D(latitude: 40.58058466412761,
                                                      longitude: -97.734375)

        mapView.cameraManager.setCamera(centerCoordinate: centerCoordinate,
                                        zoom: 3)

        // Allows the view controller to receive information about map events.
        mapView.on(.mapLoadingFinished) { [weak self] _ in
            guard let self = self else { return }
            self.setupExample()
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

        if let jsonObject = try? exp.jsonObject() {
            try! mapView.__map.setStyleLayerPropertyForLayerId("land",
                                                               property: "background-color",
                                                               value: jsonObject)
        }

        // The below line is used for internal testing purposes only.
        finish()
    }
}
