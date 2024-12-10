import UIKit
import MapboxMaps

final class AddOneMarkerSymbolExample: UIViewController, ExampleProtocol {
    private lazy var mapView: MapView = {
        let options = MapInitOptions(cameraOptions: CameraOptions(center: Constants.coordinate, zoom: 8))

        return MapView(frame: view.bounds, mapInitOptions: options)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.mapboxMap.loadStyle(.standard) { [weak self] error in
            guard error == nil else { return }

            self?.addMarkerAnnotation()
            // The following line is just for testing purposes.
            self?.finish()
        }
    }

    private func addMarkerAnnotation() {
        try? mapView.mapboxMap.addImage(UIImage(named: "dest-pin")!, id: Constants.RED_ICON_ID)

        var source = GeoJSONSource(id: Constants.SOURCE_ID)
        source.data = .geometry(Geometry.point(Point(Constants.coordinate)))
        try? mapView.mapboxMap.addSource(source)

        var layer = SymbolLayer(id: Constants.LAYER_ID, source: Constants.SOURCE_ID)
        layer.iconImage = .constant(.name(Constants.RED_ICON_ID))
        layer.iconAnchor = .constant(.bottom)
        layer.iconOffset = .constant([0, 12])
        try? mapView.mapboxMap.addLayer(layer)
    }
}

extension AddOneMarkerSymbolExample {
    private enum Constants {
        static let RED_ICON_ID = "red"
        static let SOURCE_ID = "source_id"
        static let LAYER_ID = "layer_id"
        static let coordinate = CLLocationCoordinate2D(latitude: 55.665957, longitude: 12.550343)
    }
}
