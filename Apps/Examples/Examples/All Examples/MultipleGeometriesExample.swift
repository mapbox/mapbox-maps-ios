import UIKit
import MapboxMaps

@objc(MultipleGeometriesExample)

public class MultipleGeometriesExample: UIViewController, ExampleProtocol {
    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Set the center coordinate and zoom level.
        let centerCoordinate = CLLocationCoordinate2D(latitude: 18.239785,
                                                      longitude: -66.302490)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 6.9))

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Allow the view controller to receive information about map events.
        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            self.setupExample()
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
            featureCollection = try GeoJSON.parse(FeatureCollection.self, from: data)
        } catch {
            print("Error parsing data: \(error)")
        }

        return featureCollection
    }

    public func setupExample() {

        // Attempt to decode GeoJSON from file bundled with application.
        guard let featureCollection = try? decodeGeoJSON(from: "GeoJSONSourceExample") else { return }

        let geoJSONDataSourceIdentifier = "geoJSON-data-source"

        // Create a GeoJSON data source.
        var geoJSONSource = GeoJSONSource()
        geoJSONSource.data = .featureCollection(featureCollection)

        // Create a circle layer associated with the GeoJSON data source,
        // filter it so that only the point data is shown,
        // and apply basic styling to it.
        var circleLayer = CircleLayer(id: "circle-layer")
        circleLayer.filter = Exp(.eq) {
            "$type"
            "Point"
        }
        circleLayer.source = geoJSONDataSourceIdentifier
        circleLayer.circleColor = .constant(StyleColor(.yellow))
        circleLayer.circleOpacity = .constant(0.6)
        circleLayer.circleRadius = .constant(8.0)
        // Follow the same steps to create a line layer
        var lineLayer = LineLayer(id: "line-layer")
        lineLayer.filter = Exp(.eq) {
            "$type"
            "LineString"
        }
        lineLayer.source = geoJSONDataSourceIdentifier
        lineLayer.lineColor = .constant(StyleColor(.red))
        lineLayer.lineWidth = .constant(1.4)
        // Follow the same steps to create a polygon (fill) layer
        var polygonLayer = FillLayer(id: "fill-layer")
        polygonLayer.filter = Exp(.eq) {
            "$type"
            "Polygon"
        }
        polygonLayer.source = geoJSONDataSourceIdentifier
        polygonLayer.fillColor = .constant(StyleColor(.green))
        polygonLayer.fillOpacity = .constant(0.3)
        polygonLayer.fillOutlineColor = .constant(StyleColor(.purple))
        // Add the source and style layers to the map style.
        try! mapView.mapboxMap.style.addSource(geoJSONSource, id: geoJSONDataSourceIdentifier)
        try! mapView.mapboxMap.style.addLayer(circleLayer)
        try! mapView.mapboxMap.style.addLayer(lineLayer)
        try! mapView.mapboxMap.style.addLayer(polygonLayer)

        // The below line is used for internal testing purposes only.
        finish()
    }
}
