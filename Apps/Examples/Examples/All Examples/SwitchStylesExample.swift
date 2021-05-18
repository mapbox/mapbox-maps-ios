import UIKit
import MapboxMaps

@objc(SwitchStylesExample)

public class SwitchStylesExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.ornaments.options.scaleBar.visibility = .visible

        view.addSubview(mapView)
    }


    @objc func switchStyle(sender: UISegmentedControl) {
        // A local style JSON (https://www.mapbox.com/mapbox-gl-style-spec/) from Mapillary: <https://d25uarhxywzl1j.cloudfront.net/v0.1/{z}/{x}/{y}.mvt>
        let localStyleURL = Bundle.main.url(forResource: "third_party_vector_style", withExtension: "json")!
        // A custom style design
//        let customStyleURL = StyleURI(rawValue: "mapbox://styles/examples/cke97f49z5rlg19l310b7uu7j")!

    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         // The below line is used for internal testing purposes only.
        finish()
    }
}
