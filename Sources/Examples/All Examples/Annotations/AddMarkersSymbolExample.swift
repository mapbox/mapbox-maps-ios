import UIKit
import MapboxMaps

final class AddMarkersSymbolExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var cancelables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        let centerCoordinate = CLLocationCoordinate2D(latitude: 55.70651, longitude: 12.554729)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 8))

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
            guard let self = self else { return }
            self.prepareStyle()

            // The following line is just for testing purposes.
            self.finish()
        }.store(in: &cancelables)
    }

    // MARK: - Style management

    private func prepareStyle() {
        try? mapView.mapboxMap.addImage(UIImage(named: "intermediate-pin")!, id: Constants.BLUE_ICON_ID)
        try? mapView.mapboxMap.addImage(UIImage(named: "dest-pin")!, id: Constants.RED_ICON_ID)

        // SF Symbols example
        var sfSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 36, weight: .bold)
            .applying(UIImage.SymbolConfiguration(paletteColors: [.white, .darkGray]))
        if #available(iOS 26.0, *) {
            sfSymbolConfiguration = sfSymbolConfiguration.applying(UIImage.SymbolConfiguration(colorRenderingMode: .gradient))
        }
        let sfSymbolImage = UIImage(systemName: "mappin.circle.fill", withConfiguration: sfSymbolConfiguration)!
        try? mapView.mapboxMap.addImage(sfSymbolImage, id: Constants.SF_SYMBOL_ICON_ID)

        var features = [Feature]()
        var feature = Feature(geometry: Point(LocationCoordinate2D(latitude: 55.608166, longitude: 12.65147)))
        feature.properties = [Constants.ICON_KEY: .string(Constants.BLUE_MARKER_PROPERTY)]
        features.append(feature)

        var feature1 = Feature(geometry: Point(LocationCoordinate2D(latitude: 55.70651, longitude: 12.554729)))
        feature1.properties = [Constants.ICON_KEY: .string(Constants.RED_MARKER_PROPERTY)]
        features.append(feature1)

        var feature2 = Feature(geometry: Point(LocationCoordinate2D(latitude: 55.6600, longitude: 12.3200)))
        feature2.properties = [Constants.ICON_KEY: .string(Constants.SF_SYMBOL_MARKER_PROPERTY)]
        features.append(feature2)

        var source = GeoJSONSource(id: Constants.SOURCE_ID)
        source.data = .featureCollection(FeatureCollection(features: features))
        try? mapView.mapboxMap.addSource(source)

        let rotateExpression = Exp(.match) {
            Exp(.get) { Constants.ICON_KEY }
            Constants.BLUE_MARKER_PROPERTY
            45
            Constants.SF_SYMBOL_MARKER_PROPERTY
            -25
            0
        }
        let imageExpression = Exp(.match) {
            Exp(.get) { Constants.ICON_KEY }
            Constants.BLUE_MARKER_PROPERTY
            Constants.BLUE_ICON_ID
            Constants.RED_MARKER_PROPERTY
            Constants.RED_ICON_ID
            Constants.SF_SYMBOL_MARKER_PROPERTY
            Constants.SF_SYMBOL_ICON_ID
            Constants.RED_ICON_ID
        }
        var layer = SymbolLayer(id: Constants.LAYER_ID, source: Constants.SOURCE_ID)
        layer.iconImage = .expression(imageExpression)
        layer.iconAnchor = .constant(.bottom)
        layer.iconAllowOverlap = .constant(false)
        layer.iconRotate = .expression(rotateExpression)
        // Add Y-offset so icon will point to exact location.
        layer.iconOffset = .constant([0, 12])
        try? mapView.mapboxMap.addLayer(layer)
    }
}

extension AddMarkersSymbolExample {
    private enum Constants {
        static let ICON_KEY = "icon_key"
        static let BLUE_MARKER_PROPERTY = "icon_blue_property"
        static let RED_MARKER_PROPERTY = "icon_red_property"
        static let BLUE_ICON_ID = "blue"
        static let RED_ICON_ID = "red"
        static let SF_SYMBOL_MARKER_PROPERTY = "icon_sf_symbol_property"
        static let SF_SYMBOL_ICON_ID = "sf-symbol"
        static let SOURCE_ID = "source_id"
        static let LAYER_ID = "layer_id"
    }
}
