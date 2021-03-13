import UIKit
import MapboxMaps

@objc(BasicMapExample)

public class BasicMapExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(with: view.bounds, resourceOptions: resourceOptions())
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.update { (mapOptions) in
            mapOptions.ornaments.showsScale = true
        }

        view.addSubview(mapView)
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         // The below line is used for internal testing purposes only.
        finish()
    }
}
