import Foundation
import UIKit
@_spi(Experimental) import MapboxMaps

@objc(GlobeExample)
class GlobeExample: UIViewController, ExampleProtocol {
    internal var mapView: MapView!
    internal var currentProjection = StyleProjection(name: .globe)
    internal var currentAtmosphere = Atmosphere()

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds, mapInitOptions: .init(styleURI: .satelliteStreets))
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        try! mapView.mapboxMap.style.setProjection(currentProjection)
        try! mapView.mapboxMap.style.setAtmosphere(currentAtmosphere)
        mapView.mapboxMap.setCamera(to: .init(center: CLLocationCoordinate2D(latitude: 50, longitude: 30), zoom: 0.45))

        mapView.mapboxMap.onNext(event: .styleLoaded) { _ in
            try! self.mapView.mapboxMap.style.setAtmosphere(self.currentAtmosphere)
        }

        view.addSubview(mapView)
    }
}
