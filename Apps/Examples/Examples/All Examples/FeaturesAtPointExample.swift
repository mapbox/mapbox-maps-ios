import UIKit
import MapboxMaps

@objc(FeaturesAtPointExample)

public class FeaturesAtPointExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(with: view.bounds, resourceOptions: resourceOptions())
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Center the map over the United States.
        let centerCoordinate = CLLocationCoordinate2D(latitude: 39.368279,
                                                      longitude: -97.646484)

        mapView.cameraManager.setCamera(centerCoordinate: centerCoordinate,
                                        zoom: 2.4)

        // Allows the view controller to receive information about map events.
        mapView.on(.mapLoaded) { [weak self] _ in
            guard let self = self else { return }
            self.setupExample()
        }
    }

    public func setupExample() {

        // Create a new GeoJSON data source which gets its data from an external URL.
        guard let dataURL = URL(string: "https://docs.mapbox.com/mapbox-gl-js/assets/us_states.geojson") else {
            preconditionFailure("URL is not valid")
        }

        let sourceIdentifier = "US-states-vector-source"

        var geoJSONSource = GeoJSONSource()
        geoJSONSource.data = .url(dataURL)

        // Create a new fill layer associated with the data source.
        var fillLayer = FillLayer(id: "US-states")
        fillLayer.sourceLayer = "state_county_population_2014_cen"
        fillLayer.source = sourceIdentifier

        // Apply basic styling to the fill layer.
        fillLayer.paint?.fillColor = .constant(ColorRepresentable(color: UIColor.blue))
        fillLayer.paint?.fillOpacity = .constant(0.3)
        fillLayer.paint?.fillOutlineColor = .constant(ColorRepresentable(color: UIColor.black))

        // Add the data source and style layer to the map.
        _ = mapView.style.addSource(source: geoJSONSource, identifier: sourceIdentifier)
        _ = mapView.style.addLayer(layer: fillLayer, layerPosition: nil)

        // Set up the tap gesture
        addTapGesture(to: mapView)
    }

    // Add a tap gesture to the map view.
    public func addTapGesture(to mapView: MapView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(findFeatures))
        mapView.addGestureRecognizer(tapGesture)
    }

    /**
     Use the tap point received from the gesture recognizer to query
     the map for rendered features at the given point within the layer specified.
     */
    @objc public func findFeatures(_ sender: UITapGestureRecognizer) {
        let tapPoint = sender.location(in: mapView)

        mapView.visibleFeatures(at: tapPoint,
                                styleLayers: ["US-states"],
                                completion: { [weak self] result in
                                    switch result {
                                    case .success(let features):
                                        if let firstFeature = features.first?.properties,
                                           let stateName = firstFeature["STATE_NAME"] as? String {
                                            self?.showAlert(with: "You selected \(stateName)")
                                        }
                                    case .failure(let error):
                                        self?.showAlert(with: "An error occurred: \(error.localizedDescription)")
                                    }
                                 })
    }

    // Present an alert with a given title.
    public func showAlert(with title: String) {
        let alertController = UIAlertController(title: title,
                                                message: nil,
                                                preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
}
