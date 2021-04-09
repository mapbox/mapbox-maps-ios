import UIKit
import MapboxMaps
import Turf

@objc(GeoJSONSourceExample)

public class GeoJSONSourceExample: UIViewController, ExampleProtocol {
    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds, resourceOptions: resourceOptions())
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Set the center coordinate and zoom level.
        let centerCoordinate = CLLocationCoordinate2D(latitude: 18.239785,
                                                      longitude: -66.302490)
        mapView.centerCoordinate = centerCoordinate
        mapView.zoom = 6.9

        // Allow the view controller to receive information about map events.
        mapView.on(.mapLoaded) { [weak self] _ in
            guard let self = self else { return }
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
        circleLayer.paint?.circleColor = .constant(ColorRepresentable(color: UIColor.yellow))
        circleLayer.paint?.circleOpacity = .constant(0.6)
        circleLayer.paint?.circleRadius = .constant(8.0)
        // Follow the same steps to create a line layer
        var lineLayer = LineLayer(id: "line-layer")
        lineLayer.filter = Exp(.eq) {
            "$type"
            "LineString"
        }
        lineLayer.source = geoJSONDataSourceIdentifier
        lineLayer.paint?.lineColor = .constant(ColorRepresentable(color: UIColor.red))
        lineLayer.paint?.lineWidth = .constant(1.4)
        // Follow the same steps to create a polygon (fill) layer
        var polygonLayer = FillLayer(id: "fill-layer")
        polygonLayer.filter = Exp(.eq) {
            "$type"
            "Polygon"
        }
        polygonLayer.source = geoJSONDataSourceIdentifier
        polygonLayer.paint?.fillColor = .constant(ColorRepresentable(color: UIColor.green))
        polygonLayer.paint?.fillOpacity = .constant(0.3)
        polygonLayer.paint?.fillOutlineColor = .constant(ColorRepresentable(color: UIColor.purple))
        // Add the source and style layers to the map style.
        _ = mapView.style.addSource(source: geoJSONSource, identifier: geoJSONDataSourceIdentifier)
        _ = mapView.style.addLayer(layer: circleLayer, layerPosition: nil)
        _ = mapView.style.addLayer(layer: lineLayer, layerPosition: nil)
        _ = mapView.style.addLayer(layer: polygonLayer, layerPosition: nil)

        // The below line is used for internal testing purposes only.
        finish()
    }
}
