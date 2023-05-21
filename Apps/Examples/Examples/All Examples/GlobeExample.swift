import Foundation
import UIKit
import MapboxMaps

class GlobeExample: UIViewController, ExampleProtocol {
    internal var mapView: MapView!
    private var cancelables = Set<AnyCancelable>()

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds, mapInitOptions: .init(styleURI: .satelliteStreets))
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.mapboxMap.setCamera(to: .init(center: CLLocationCoordinate2D(latitude: 50, longitude: 30), zoom: 0.45))
        try! self.mapView.mapboxMap.style.setProjection(StyleProjection(name: .globe))

        mapView.mapboxMap.onStyleLoaded.observeNext { [weak self] _ in
            try! self?.mapView.mapboxMap.style.setAtmosphere(Atmosphere())
            self?.finish()
        }.store(in: &cancelables)

        view.addSubview(mapView)
    }
}
