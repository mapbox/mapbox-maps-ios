import Foundation
import MapboxMaps

@objc(AddOneMarkerSymbolExample)
final class AddOneMarkerSymbolExample: UIViewController, ExampleProtocol {
    private enum Constants {
        static let BLUE_ICON_ID = "blue"
        static let SOURCE_ID = "source_id"
        static let LAYER_ID = "layer_id"
        static let coordinate = CLLocationCoordinate2D(latitude: 55.665957, longitude: 12.550343)
    }

    private lazy var mapView: MapView = {
        let options = MapInitOptions(cameraOptions: CameraOptions(center: Constants.coordinate, zoom: 8))

        return MapView(frame: view.bounds, mapInitOptions: options)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.mapboxMap.loadStyleURI(.streets) { result in
            guard let style = try? result.get() else { return }

            self.addMarkerAnnotation(toStyle: style)
            // The following line is just for testing purposes.
            self.finish()
        }
    }

    private func addMarkerAnnotation(toStyle style: Style) {
        try? style.addImage(UIImage(named: "blue_marker_view")!, id: Constants.BLUE_ICON_ID, stretchX: [], stretchY: [])

        var source = GeoJSONSource()
        source.data = .geometry(Geometry.point(Point(Constants.coordinate)))
        try? style.addSource(source, id: Constants.SOURCE_ID)

        var layer = SymbolLayer(id: Constants.LAYER_ID)
        layer.source = Constants.SOURCE_ID
        layer.iconImage = .constant(.name(Constants.BLUE_ICON_ID))
        layer.iconAnchor = .constant(.bottom)
        try? style.addLayer(layer)
    }
}
