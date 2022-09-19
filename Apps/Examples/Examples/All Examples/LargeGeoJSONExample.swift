import UIKit
import MapboxMaps

final class LargeGeoJSONPerformanceExample: UIViewController, ExampleProtocol {
    private static let largeSourceCount = 5

    private var mapView: MapView!
    private var routePoints: Feature!

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.ornaments.options.scaleBar.visibility = .visible

        view.addSubview(mapView)

        let lineStringAsset = NSDataAsset(name: "long_route")
        routePoints = try! JSONDecoder().decode(Feature.self, from: lineStringAsset!.data)

        mapView.mapboxMap.onNext(event: .styleLoaded) { _ in
            try! self.setupExample()
        }
    }

    private func setupExample() throws {
        let cameraCenter = CLLocationCoordinate2D(latitude: 51.1079, longitude: 17.0385)
        let cameraOptions = CameraOptions(center: cameraCenter, zoom: 6)
        mapView.mapboxMap.setCamera(to: cameraOptions)

        mapView.camera.fly(to: CameraOptions(zoom: 2), duration: 10) { [weak self] _ in
            // The below line is used for internal testing purposes only.
            self?.finish()
        }

        for i in 0..<Self.largeSourceCount {
            var source = GeoJSONSource()
            let sourceId = "source_\(i)"
            source.data = .feature(routePoints)

            var lineLayer = LineLayer(id: "line_layer_\(i)")
            lineLayer.source = sourceId
            lineLayer.lineColor = .constant(StyleColor(.systemBlue))
            lineLayer.lineOffset = .constant(Double(5 * i))

            try mapView.mapboxMap.style.addSource(source, id: sourceId)
            try mapView.mapboxMap.style.addLayer(lineLayer)
        }

        try mapView.mapboxMap.style.addImage(UIImage(named: "blue_marker_view")!, id: "icon")

        var source = GeoJSONSource()
        let sourceId = "source_marker"
        source.data = .feature(Feature(geometry: Point(cameraCenter).geometry))

        try mapView.mapboxMap.style.addSource(source, id: sourceId)

        var symbolLayer = SymbolLayer(id: "layer_marker")
        symbolLayer.source = sourceId
        symbolLayer.iconImage = .constant(.name("icon"))
        symbolLayer.iconAnchor = .constant(.bottom)

        try mapView.mapboxMap.style.addLayer(symbolLayer)

        try loadAdditionalGeoJSON()
    }

    private func loadAdditionalGeoJSON() throws {
        var source = GeoJSONSource()
        let sourceId = "source_\(Self.largeSourceCount)"
        source.data = .feature(routePoints)

        try mapView.mapboxMap.style.addSource(source, id: sourceId)

        var lineLayer = LineLayer(id: "line_layer_\(Self.largeSourceCount)")
        lineLayer.source = sourceId
        lineLayer.lineColor = .constant(StyleColor(.systemGreen))
        lineLayer.lineOffset = .constant(Double(5 * Self.largeSourceCount))

        try mapView.mapboxMap.style.addLayer(lineLayer)
    }
}
