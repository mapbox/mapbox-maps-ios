import UIKit
import MapboxMaps

final class IconSizeChangeExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var markerSelected = false
    private var cancelables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        let initialPosition = CLLocationCoordinate2D(latitude: 42.354950, longitude: -71.065634)
        let cameraOptions = CameraOptions(center: initialPosition, zoom: 11)
        let initOptions = MapInitOptions(cameraOptions: cameraOptions)
        mapView = MapView(frame: view.bounds, mapInitOptions: initOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Allows the delegate to receive information about map events.
        mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in

            // Set up the example
            self?.setupExample()

            // The below line is used for internal testing purposes only.
            self?.finish()
        }.store(in: &cancelables)

        mapView.mapboxMap.loadStyle(.dark)
    }

    private func setupExample() {
        let markerFeatures = [
            CLLocationCoordinate2D(latitude: 42.354950, longitude: -71.065634), // Boston Common Park
            CLLocationCoordinate2D(latitude: 42.346645, longitude: -71.097293), // Fenway Park
            CLLocationCoordinate2D(latitude: 42.363725, longitude: -71.053694) // The Paul Revere House
        ].map({ Feature(geometry: Point($0)) })

        // Create a GeoJSON data source for markers
        var markerSource = GeoJSONSource(id: Constants.markerSourceId)
        markerSource.data = .featureCollection(FeatureCollection(features: markerFeatures))
        try? mapView.mapboxMap.addSource(markerSource)

        // Add marker image to the map
        try? mapView.mapboxMap.addImage(UIImage(named: "intermediate-pin")!, id: Constants.blueMarkerImageId)

        // Create a symbol layer for markers
        var markerLayer = SymbolLayer(id: Constants.markerLayerId, source: Constants.markerSourceId)
        markerLayer.iconImage = .constant(.name(Constants.blueMarkerImageId))
        markerLayer.iconAllowOverlap = .constant(true)
        markerLayer.iconOffset = .constant([0, 12])
        // Adding an offset so that the bottom of the blue icon gets fixed to the coordinate, rather than the
        // middle of the icon being fixed to the coordinate point.
        markerLayer.iconOffset = .constant([0, -9])

        try? mapView.mapboxMap.addLayer(markerLayer)

        // Create a GeoJSON source for the selected marker
        var selectedMarkerSource = GeoJSONSource(id: Constants.selectedMarkerSourceId)
        selectedMarkerSource.data = .geometry(.point(Point(CLLocationCoordinate2D())))
        try? mapView.mapboxMap.addSource(selectedMarkerSource)

        // Create a symbol layer for the selected marker
        var selectedMarkerLayer = SymbolLayer(id: Constants.selectedMarkerLayerId, source: Constants.selectedMarkerSourceId)
        selectedMarkerLayer.iconImage = .constant(.name(Constants.blueMarkerImageId))
        selectedMarkerLayer.iconAllowOverlap = .constant(true)
        // Adding an offset so that the bottom of the blue icon gets fixed to the coordinate, rather than the
        // middle of the icon being fixed to the coordinate point.
        selectedMarkerLayer.iconOffset = .constant([0, -9])

        try? mapView.mapboxMap.addLayer(selectedMarkerLayer)

        // Add a handler for tap on the selected marker layer.
        mapView.mapboxMap.addInteraction(TapInteraction(.layer(Constants.selectedMarkerLayerId)) { [weak self] _, context in
            guard let self else { return false }
            if !self.markerSelected {
                self.updateSelectedMarker(atPoint: context.point)
            }
            return true
        })

        // Add a handler for on map, except taps on selected marker.
        mapView.mapboxMap.addInteraction(TapInteraction { [weak self] context in
            self?.updateSelectedMarker(atPoint: context.point)
            return false
        })
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

                if let geometry = features.first?.queriedFeature.feature.geometry {
                    self.mapView.mapboxMap.updateGeoJSONSource(withId: Constants.selectedMarkerSourceId,
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
        try? mapView.mapboxMap.updateLayer(
            withId: Constants.selectedMarkerLayerId,
            type: SymbolLayer.self,
            update: { (layer: inout SymbolLayer) throws in
                layer.iconSize = .constant(selected ? 2 : 1)
            })
        markerSelected = selected
    }
}

extension IconSizeChangeExample {
    private enum Constants {
        static let blueMarkerImageId = "blue-marker"
        static let markerLayerId = "marker-layer"
        static let markerSourceId = "marker-source"
        static let selectedMarkerLayerId = "selected-marker-layer"
        static let selectedMarkerSourceId = "selected-marker"
    }
}
