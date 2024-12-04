import UIKit
import MapboxMaps

final class FeaturesAtPointExample: UIViewController, ExampleProtocol {
    private var cancelables = Set<AnyCancelable>()
    private var mapView: MapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Center the map over the United States.
        let centerCoordinate = CLLocationCoordinate2D(latitude: 39.368279,
                                                      longitude: -97.646484)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 2.4))

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Allows the view controller to receive information about map events.
        mapView.mapboxMap.onMapLoaded.observeNext { _ in
            self.setupExample()

            // The following line is just for testing purposes.
            self.finish()
        }.store(in: &cancelables)

        // Set up the tap gesture
        mapView.gestures.onLayerTap("US-states") { [weak self] queriedFeature, _ in
            if let firstFeature = queriedFeature.feature.properties,
               case let .string(stateName) = firstFeature["STATE_NAME"] {
                    self?.showAlert(with: "You selected \(stateName)")
            }
            return true
        }.store(in: &cancelables)
    }

    func setupExample() {
        // Create a new GeoJSON data source which gets its data from an external URL.
        var geoJSONSource = GeoJSONSource(id: "US-states-vector-source")
        geoJSONSource.data = .string("https://docs.mapbox.com/mapbox-gl-js/assets/us_states.geojson")

        // Create a new fill layer associated with the data source.
        var fillLayer = FillLayer(id: "US-states", source: geoJSONSource.id)
        fillLayer.sourceLayer = "state_county_population_2014_cen"

        // Apply basic styling to the fill layer.
        fillLayer.fillColor = .constant(StyleColor(.blue))
        fillLayer.fillOpacity = .constant(0.3)
        fillLayer.fillOutlineColor = .constant(StyleColor(.black))

        // Add the data source and style layer to the map.
        try! mapView.mapboxMap.addSource(geoJSONSource)
        try! mapView.mapboxMap.addLayer(fillLayer, layerPosition: nil)
    }
}
