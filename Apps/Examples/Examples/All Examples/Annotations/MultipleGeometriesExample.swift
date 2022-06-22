import UIKit
import MapboxMaps

@objc(MultipleGeometriesExample)
public class MultipleGeometriesExample: UIViewController, ExampleProtocol {
    enum Constants {
        static let geoJSONDataSourceIdentifier = "geoJSON-data-source"
    }
    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Set the center coordinate and zoom level.
        let centerCoordinate = CLLocationCoordinate2D(latitude: 38.93490939383946, longitude: -77.03619251024163)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 11))

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Allow the view controller to receive information about map events.
        mapView.mapboxMap.onNext(event: .mapLoaded) { _ in
            self.addGeoJSONSource()
            self.addPolygonLayer()
            self.addLineStringLayer()
            self.addPointLayer()

            // The below line is used for internal testing purposes only.
            self.finish()
        }
    }

    // Load GeoJSON file from local bundle and decode into a `FeatureCollection`.
    internal func decodeGeoJSON(from fileName: String) throws -> FeatureCollection? {
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
        var geoJSONSource = GeoJSONSource()
        geoJSONSource.data = .featureCollection(featureCollection)
        try! mapView.mapboxMap.style.addSource(geoJSONSource, id: Constants.geoJSONDataSourceIdentifier)
    }

    /// Create and style a FillLayer that uses the Polygon Feature's coordinates in the GeoJSON data
    private func addPolygonLayer() {
        var polygonLayer = FillLayer(id: "fill-layer")
        polygonLayer.filter = Exp(.eq) {
            "$type"
            "Polygon"
        }
        polygonLayer.source = Constants.geoJSONDataSourceIdentifier
        polygonLayer.fillColor = .constant(StyleColor(red: 68, green: 105, blue: 247, alpha: 1)!)
        polygonLayer.fillOpacity = .constant(0.3)
        try! mapView.mapboxMap.style.addLayer(polygonLayer)
    }

    private func addLineStringLayer() {
        // Create and style a LineLayer that uses the Line String Feature's coordinates in the GeoJSON data
        var lineLayer = LineLayer(id: "line-layer")
        lineLayer.filter = Exp(.eq) {
            "$type"
            "LineString"
        }
        lineLayer.source = Constants.geoJSONDataSourceIdentifier
        lineLayer.lineColor = .constant(StyleColor(.red))
        lineLayer.lineWidth = .constant(2)
        try! mapView.mapboxMap.style.addLayer(lineLayer)
    }

    public func addPointLayer() {
        // Create a circle layer associated with the GeoJSON data source,
        // filter it so that only the point data is shown,
        // and apply basic styling to it.
        var circleLayer = CircleLayer(id: "circle-layer")
        circleLayer.filter = Exp(.eq) {
            "$type"
            "Point"
        }
        circleLayer.source = Constants.geoJSONDataSourceIdentifier
        circleLayer.circleColor = .constant(StyleColor(.red))
        circleLayer.circleRadius = .constant(6.0)
        circleLayer.circleStrokeWidth = .constant(2.0)
        circleLayer.circleStrokeColor = .constant(StyleColor(.black))
        try! mapView.mapboxMap.style.addLayer(circleLayer)
    }
}
