import UIKit
import MapboxMaps

@objc(SkyLayerExample)

public class SkyLayerExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!
    internal var skyLayer: SkyLayer!

    override public func viewDidLoad() {
        super.viewDidLoad()

//        let mapInitOptions = MapInitOptions(cameraOptions: <#T##CameraOptions?#>, styleURI: <#T##StyleURI?#>)
        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(mapView)
        mapView.mapboxMap.onNext(.styleLoaded) { _ in

        }
    }

    func addSkyLayer() {

    }
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         // The below line is used for internal testing purposes only.
        finish()
    }
}
