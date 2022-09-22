import Foundation
import MapboxMaps

final class IconSizeChangeExample: UIViewController, ExampleProtocol {
    enum Constants {
        static let blueMarkerImageId = "blue-marker"
        static let markerLayerId = "marker-layer"
        static let markerSourceId = "marker-source"
        static let selectedMarkerLayerId = "selected-marker-layer"
        static let selectedMarkerSourceId = "selected-marker"
    }
    private var mapView: MapView!
    private var markerSelected = false

    override func viewDidLoad() {
        super.viewDidLoad()

        let initialPosition = CLLocationCoordinate2D(latitude: 42.354950, longitude: -71.065634)
        let cameraOptions = CameraOptions(center: initialPosition, zoom: 11)
        let initOptions = MapInitOptions(cameraOptions: cameraOptions)
        mapView = MapView(frame: view.bounds, mapInitOptions: initOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Allows the delegate to receive information about map events.
        mapView.mapboxMap.onNext(event: .mapLoaded) { [weak self] _ in

            // Set up the example
            self?.setupExample()

            // The below line is used for internal testing purposes only.
            self?.finish()
        }

        mapView.mapboxMap.loadStyleURI(.dark)
    }

    private func setupExample() {
        let markerFeatures = [
            CLLocationCoordinate2D(latitude: 42.354950, longitude: -71.065634), // Boston Common Park
            CLLocationCoordinate2D(latitude: 42.346645, longitude: -71.097293), // Fenway Park
            CLLocationCoordinate2D(latitude: 42.363725, longitude: -71.053694) // The Paul Revere House
        ].map({ Feature(geometry: Point($0)) })

        // Create a GeoJSON data source for markers
        var markerSource = GeoJSONSource()
        markerSource.data = .featureCollection(FeatureCollection(features: markerFeatures))
        try? mapView.mapboxMap.style.addSource(markerSource, id: Constants.markerSourceId)

        // Add marker image to the map
        try? mapView.mapboxMap.style.addImage(UIImage(named: "blue_marker_view")!, id: Constants.blueMarkerImageId)

        // Create a symbol layer for markers
        var markerLayer = SymbolLayer(id: Constants.markerLayerId)
        markerLayer.source = Constants.markerSourceId
        markerLayer.iconImage = .constant(.name(Constants.blueMarkerImageId))
        markerLayer.iconAllowOverlap = .constant(true)
        // Adding an offset so that the bottom of the blue icon gets fixed to the coordinate, rather than the
        // middle of the icon being fixed to the coordinate point.
        markerLayer.iconOffset = .constant([0, -9])

        try? mapView.mapboxMap.style.addLayer(markerLayer)

        // Create a GeoJSON source for the selected marker
        var selectedMarkerSource = GeoJSONSource()
        selectedMarkerSource.data = .geometry(.point(Point(CLLocationCoordinate2D())))
        try? mapView.mapboxMap.style.addSource(selectedMarkerSource, id: Constants.selectedMarkerSourceId)

        // Create a symbol layer for the selected marker
        var selectedMarkerLayer = SymbolLayer(id: Constants.selectedMarkerLayerId)
        selectedMarkerLayer.source = Constants.selectedMarkerSourceId
        selectedMarkerLayer.iconImage = .constant(.name(Constants.blueMarkerImageId))
        selectedMarkerLayer.iconAllowOverlap = .constant(true)
        // Adding an offset so that the bottom of the blue icon gets fixed to the coordinate, rather than the
        // middle of the icon being fixed to the coordinate point.
        selectedMarkerLayer.iconOffset = .constant([0, -9])

        try? mapView.mapboxMap.style.addLayer(selectedMarkerLayer)

        // add a tap gesture recognizer to the map
        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(mapTapped(_:))))
    }

    @objc private func mapTapped(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: mapView)

        let options = RenderedQueryOptions(layerIds: [Constants.selectedMarkerLayerId], filter: nil)
        // check if the selected marker was tapped
        mapView.mapboxMap.queryRenderedFeatures(with: point, options: options) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let features):
                if !features.isEmpty, self.markerSelected {
                    return
                }

                self.updateSelectedMarker(atPoint: point)
            case .failure(let error):
                self.showAlert(with: "An error occurred: \(error.localizedDescription)")
            }
        }
    }

    private func updateSelectedMarker(atPoint point: CGPoint) {
        let options = RenderedQueryOptions(layerIds: [Constants.markerLayerId], filter: nil)
        mapView.mapboxMap.queryRenderedFeatures(with: point, options: options) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let features):
                if features.isEmpty {
                    if self.markerSelected {
                        self.updateMarker(selected: false)
                    }
                    return
                }

                if let geometry = features.first?.feature.geometry {
                    try? self.mapView.mapboxMap.style.updateGeoJSONSource(withId: Constants.selectedMarkerSourceId,
                                                                          geoJSON: .geometry(geometry))
                }

                if self.markerSelected {
                    self.updateMarker(selected: false)
                }

                if !features.isEmpty {
                    self.updateMarker(selected: true)
                }
            case .failure(let error):
                self.showAlert(with: "An error occurred: \(error.localizedDescription)")
            }
        }
    }

    private func updateMarker(selected: Bool) {
        try? mapView.mapboxMap.style.updateLayer(
            withId: Constants.selectedMarkerLayerId,
            type: SymbolLayer.self,
            update: { (layer: inout SymbolLayer) throws in
                layer.iconSize = .constant(selected ? 2 : 1)
            })
        markerSelected = selected
    }
}
