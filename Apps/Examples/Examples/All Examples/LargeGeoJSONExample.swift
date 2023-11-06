import UIKit
import MapboxMaps

final class LargeGeoJSONPerformanceExample: UIViewController, ExampleProtocol {
    private static let largeSourceCount = 5

    private var mapView: MapView!
    private var geoJSON = ""
    private var jsonUpdateCounter = 0
    private var cancelables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.ornaments.options.scaleBar.visibility = .visible

        view.addSubview(mapView)

        let asset = NSDataAsset(name: "long_route")
        geoJSON = String(data: asset!.data, encoding: .utf8)!

        mapView.mapboxMap.onStyleLoaded.observeNext { [weak self] _ in
            try! self?.setupExample()
        }.store(in: &cancelables)

        // Print updates when sources with added dataIds are updated
        mapView.mapboxMap.onSourceDataLoaded.observe { event in
            if let dataId = event.dataId {
                print("GeoJsonSource was updated, data-id: \(dataId)")
            }
        }.store(in: &cancelables)
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
            var source = GeoJSONSource(id: "source_\(i)")
            source.data = .string(geoJSON)

            var lineLayer = LineLayer(id: "line_layer_\(i)", source: source.id)
            lineLayer.lineColor = .constant(StyleColor(.systemBlue))
            lineLayer.lineOffset = .constant(Double(5 * i))

            // Add the geoJSONSourceData with a dataId, which will be returned when that data source is updated
            try mapView.mapboxMap.addSource(source, dataId: String(jsonUpdateCounter))
            try mapView.mapboxMap.addLayer(lineLayer)

            jsonUpdateCounter += 1
        }

        try mapView.mapboxMap.addImage(UIImage(named: "intermediate-pin")!, id: "icon")

        var source = GeoJSONSource(id: "source_marker")
        source.data = .feature(Feature(geometry: Point(cameraCenter).geometry))

        // Add the geoJSONSourceData with a dataId, which will be returned when that data source is updated
        try mapView.mapboxMap.addSource(source, dataId: String(jsonUpdateCounter))
        jsonUpdateCounter += 1

        var symbolLayer = SymbolLayer(id: "layer_marker", source: source.id)
        symbolLayer.iconImage = .constant(.name("icon"))
        symbolLayer.iconAnchor = .constant(.bottom)
        symbolLayer.iconOffset = .constant([0, 12])

        try mapView.mapboxMap.addLayer(symbolLayer)

        try loadAdditionalGeoJSON()
    }

    private func loadAdditionalGeoJSON() throws {
        var source = GeoJSONSource(id: "source_\(Self.largeSourceCount)")
        source.data = .string(geoJSON)

        // Add the geoJSONSourceData with a dataId, which will be returned when that data source is updated
        try mapView.mapboxMap.addSource(source, dataId: String(jsonUpdateCounter))
        jsonUpdateCounter += 1

        var lineLayer = LineLayer(id: "line_layer_\(Self.largeSourceCount)", source: source.id)
        lineLayer.lineColor = .constant(StyleColor(.systemGreen))
        lineLayer.lineOffset = .constant(Double(5 * Self.largeSourceCount))

        try mapView.mapboxMap.addLayer(lineLayer)
    }
}
