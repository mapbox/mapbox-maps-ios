import Foundation
import MapboxMaps
import Turf

@objc(LineGradientExample)
public class LineGradientExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        let options = MapInitOptions(styleURI: .light)
        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.on(.mapLoaded) { [weak self] _ in

            self?.setupExample()

            // Set the center coordinate and zoom level.
            let centerCoordinate = CLLocationCoordinate2D(latitude: 38.875, longitude: -77.035)
            let camera = CameraOptions(center: centerCoordinate, zoom: 12.0)
            self?.mapView.camera.setCamera(to: camera)
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

    internal func setupExample() {
        // The below lines are used for internal testing purposes only.
        DispatchQueue.main.asyncAfter(deadline: .now()+5.0) {
            self.finish()
        }

        // Attempt to decode GeoJSON from file bundled with application.
        guard let featureCollection = try? decodeGeoJSON(from: "GradientLine") else { return }
        let geoJSONDataSourceIdentifier = "geoJSON-data-source"

        // Create a GeoJSON data source.
        var geoJSONSource = GeoJSONSource()
        geoJSONSource.data = .featureCollection(featureCollection)
        geoJSONSource.lineMetrics = true // MUST be `true` in order to use `lineGradient` expression

        // Create a line layer
        var lineLayer = LineLayer(id: "line-layer")
        lineLayer.filter = Exp(.eq) {
            "$type"
            "LineString"
        }

        // Setting the source
        lineLayer.source = geoJSONDataSourceIdentifier

        // Styling the line
        lineLayer.paint?.lineColor = .constant(ColorRepresentable(color: UIColor.red))
        lineLayer.paint?.lineGradient = .expression(
            Exp(.interpolate) {
                Exp(.linear)
                Exp(.lineProgress)
                0
                UIColor.blue
                0.1
                UIColor.purple
                0.3
                UIColor.cyan
                0.5
                UIColor.green
                0.7
                UIColor.yellow
                1
                UIColor.red
            }
        )

        let lowZoomWidth = 10
        let highZoomWidth = 20
        lineLayer.paint?.lineWidth = .expression(
            Exp(.interpolate) {
                Exp(.linear)
                Exp(.zoom)
                14
                lowZoomWidth
                18
                highZoomWidth
            }
        )
        lineLayer.layout?.lineCap = .constant(.round)
        lineLayer.layout?.lineJoin = .constant(.round)

        // Add the source and style layer to the map style.
        try! mapView.style.addSource(geoJSONSource, id: geoJSONDataSourceIdentifier)
        try! mapView.style.addLayer(lineLayer, layerPosition: nil)
    }
}
