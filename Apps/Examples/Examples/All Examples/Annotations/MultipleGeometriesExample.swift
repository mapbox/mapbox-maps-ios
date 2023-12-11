import UIKit
import MapboxMaps

final class MultipleGeometriesExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var cancelables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the center coordinate and zoom level.
        let centerCoordinate = CLLocationCoordinate2D(latitude: 38.93490939383946, longitude: -77.03619251024163)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 11))

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Allow the view controller to receive information about map events.
        mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
            guard let self = self else { return }
            self.addGeoJSONSource()
            self.addPolygonLayer()
            self.addLineStringLayer()
            self.addPointLayer()

            // The below line is used for internal testing purposes only.
            self.finish()
        }.store(in: &cancelables)
    }

    // Load GeoJSON file from local bundle and decode into a `FeatureCollection`.
    private func decodeGeoJSON(from fileName: String) throws -> FeatureCollection? {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "geojson") else {
            preconditionFailure("File '\(fileName)' not found.")
        }

        let filePath = URL(fileURLWithPath: path)

        var featureCollection: FeatureCollection?

        do {
            let data = try Data(contentsOf: filePath)
            featureCollection = try JSONDecoder().decode(FeatureCollection.self, from: data)
        } catch {
            print("Error parsing data: \(error)")
        }

        return featureCollection
    }

    private func addGeoJSONSource() {
        // Attempt to decode GeoJSON from file bundled with application.
        guard let featureCollection = try? decodeGeoJSON(from: "GeoJSONSourceExample") else { return }

        // Create a GeoJSON data source.
        var geoJSONSource = GeoJSONSource(id: Constants.geoJSONDataSourceIdentifier)
        geoJSONSource.data = .featureCollection(featureCollection)
        try! mapView.mapboxMap.addSource(geoJSONSource)
    }

    /// Create and style a FillLayer that uses the Polygon Feature's coordinates in the GeoJSON data
    private func addPolygonLayer() {
        var polygonLayer = FillLayer(id: "fill-layer", source: Constants.geoJSONDataSourceIdentifier)
        polygonLayer.filter = Exp(.eq) {
            "$type"
            "Polygon"
        }
        polygonLayer.fillColor = .constant(StyleColor(red: 68, green: 105, blue: 247, alpha: 1)!)
        polygonLayer.fillOpacity = .constant(0.3)
        try! mapView.mapboxMap.addLayer(polygonLayer)
    }

    private func addLineStringLayer() {
        // Create and style a LineLayer that uses the Line String Feature's coordinates in the GeoJSON data
        var lineLayer = LineLayer(id: "line-layer", source: Constants.geoJSONDataSourceIdentifier)
        lineLayer.filter = Exp(.eq) {
            "$type"
            "LineString"
        }
        lineLayer.lineColor = .constant(StyleColor(.red))
        lineLayer.lineWidth = .constant(2)
        try! mapView.mapboxMap.addLayer(lineLayer)
    }

    private func addPointLayer() {
        // Create a circle layer associated with the GeoJSON data source,
        // filter it so that only the point data is shown,
        // and apply basic styling to it.
        var circleLayer = CircleLayer(id: "circle-layer", source: Constants.geoJSONDataSourceIdentifier)
        circleLayer.filter = Exp(.eq) {
            "$type"
            "Point"
        }
        circleLayer.circleColor = .constant(StyleColor(.red))
        circleLayer.circleRadius = .constant(6.0)
        circleLayer.circleStrokeWidth = .constant(2.0)
        circleLayer.circleStrokeColor = .constant(StyleColor(.black))
        try! mapView.mapboxMap.addLayer(circleLayer)
    }
}

extension MultipleGeometriesExample {
    private enum Constants {
        static let geoJSONDataSourceIdentifier = "geoJSON-data-source"
    }
}
