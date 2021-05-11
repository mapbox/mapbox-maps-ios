import UIKit
import MapboxMaps

@objc(LayerBelowExample)

public class LayerBelowExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Center the map over downtown Atlanta
        let centerCoordinate = CLLocationCoordinate2D(latitude: 35.137452,
                                                      longitude: -88.137343)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 4))

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        view.addSubview(mapView)

        // Allows the view controller to receive information about map events
        mapView.mapboxMap.on(.mapLoaded) { _ in
            self.setupExample()
            return true
        }
    }

    // Wait for the style to load before adding data to it
    public func setupExample() {
        let sourceIdentifier = "urban-areas-source"
        var source: GeoJSONSource!
        var layer: FillLayer!
        // Add the URL for Natural Earth's urban areas
        guard let dataSourceURL = URL(string: "https://d2ad6b4ur7yvpq.cloudfront.net/naturalearth-3.3.0/ne_50m_urban_areas.geojson") else {
            fatalError("Data source URL is invalid")
        }
        // Create a new GeoJSON data source which gets its data from that URL
        source = GeoJSONSource()
        source.data = .url(dataSourceURL)
        // Create the layer, add the data source, and add basic styling to the layer
        layer = FillLayer(id: "urban-areas-layer")
        layer.source = sourceIdentifier
        layer.paint?.fillColor = .constant(ColorRepresentable(color: #colorLiteral(red: 0.9764705896, green: 0.5455193555, blue: 0.8344934594, alpha: 1)))
        layer.paint?.fillOutlineColor = .constant(ColorRepresentable(color: #colorLiteral(red: 0.03167597491, green: 0.3966798381, blue: 0.043041647, alpha: 1)))

        // Add the data source to the map
        try! mapView.style.addSource(source, id: sourceIdentifier)
        // Add the layer to the map below the "settlement-label" layer
        try! mapView.style.addLayer(layer, layerPosition: LayerPosition(below: "settlement-label"))

        // The below line is used for internal testing purposes only.
        finish()
    }
}
