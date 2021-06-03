import UIKit
import MapboxMaps

@objc(SkyLayerExample)

public class SkyLayerExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!
    internal var skyLayer: SkyLayer!

    override public func viewDidLoad() {
        super.viewDidLoad()

        let center = CLLocationCoordinate2D(latitude: 35.67283, longitude: 127.60597)
        let cameraOptions = CameraOptions(center: center, zoom: 14, pitch: 83)
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions, styleURI: .satelliteStreets)
        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(mapView)
        mapView.mapboxMap.onNext(.styleLoaded) { _ in
            self.addSkyLayer()
        }
    }

    func addSkyLayer() {

    }
    
    func updateSkyLayer() {
        
    }
    // Add a `UISlider` to control the gradient of the sky layer
    @objc func addSlider() {
        
    }
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         // The below line is used for internal testing purposes only.
        finish()
    }
}
