import UIKit
import MapboxMaps
import CoreLocation

final class ViewAnnotationMarkerExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var pointList: [Feature] = []
    private var markerId = 0
    private var annotations = [String: ViewAnnotation]()
    private var _topPriority = 0
    private var topPriority: Int {
        _topPriority += 1
        return _topPriority
    }

    private let image = UIImage(named: "intermediate-pin")!
    private lazy var markerHeight: CGFloat = image.size.height
    private var cancelables = Set<AnyCancelable>()

    lazy var styleChangeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemTeal
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.setTitle("Change style", for: .normal)
        button.addTarget(self, action: #selector(styleChangePressed(sender:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let centerCoordinate = CLLocationCoordinate2D(latitude: 39.7128, longitude: -75.0060)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 7))

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
            guard let self = self else { return }
            self.finish()
        }.store(in: &cancelables)

        mapView.mapboxMap.onStyleLoaded.observe { [weak self, weak mapView] _ in
            guard let self, let mapView else { return }
            self.prepareStyle()
            self.addMarker(at: mapView.mapboxMap.coordinate(for: mapView.center), viewAnnotation: true)
        }.store(in: &cancelables)

        mapView.mapboxMap.addInteraction(LongPressInteraction { [weak self] context in
            self?.addMarker(at: context.coordinate)
            return false
        })

        mapView.mapboxMap.addInteraction(TapInteraction(.layer(Constants.LAYER_ID)) { [weak self] feature, _ in
            self?.handleMarkerTap(feature) ?? false
        })

        mapView.mapboxMap.styleURI = .streets

        view.addSubview(styleChangeButton)

        NSLayoutConstraint.activate([
            styleChangeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            styleChangeButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            styleChangeButton.widthAnchor.constraint(equalToConstant: 128)
        ])
    }

    private func handleMarkerTap(_ feature: FeaturesetFeature) -> Bool {
        guard let id = feature.id?.id else { return false }

        if let annotation = annotations[id] {
            annotation.priority = topPriority
            return true
        }
        return addViewAnnotation(id: id, geometry: feature.geometry)
    }

    @objc private func styleChangePressed(sender: UIButton) {
        mapView.mapboxMap.styleURI = mapView.mapboxMap.styleURI == .streets ? .satelliteStreets : .streets
    }

    // MARK: - Style management

    private func prepareStyle() {
        try? mapView.mapboxMap.addImage(image, id: Constants.BLUE_ICON_ID)

        var source = GeoJSONSource(id: Constants.SOURCE_ID)
        source.data = .featureCollection(FeatureCollection(features: pointList))
        try? mapView.mapboxMap.addSource(source)

        if mapView.mapboxMap.styleURI == .satelliteStreets {
            var demSource = RasterDemSource(id: "terrain-source")
            demSource.url = Constants.TERRAIN_URL_TILE_RESOURCE
            try? mapView.mapboxMap.addSource(demSource)
            let terrain = Terrain(sourceId: demSource.id)
            try? mapView.mapboxMap.setTerrain(terrain)
        }

        var layer = SymbolLayer(id: Constants.LAYER_ID, source: Constants.SOURCE_ID)
        layer.iconImage = .constant(.name(Constants.BLUE_ICON_ID))
        layer.iconAnchor = .constant(.bottom)
        layer.iconOffset = .constant([0, 12])
        layer.iconAllowOverlap = .constant(true)
        try? mapView.mapboxMap.addLayer(layer)
    }

    // MARK: - Annotation management

    // Add a marker to a custom GeoJSON source:
    // This is an optional step to demonstrate the automatic alignment of view annotations
    // with features in a data source
    private func addMarker(at coordinate: CLLocationCoordinate2D, viewAnnotation: Bool = false) {
        let currentId = "\(Constants.MARKER_ID_PREFIX)\(markerId)"
        markerId += 1
        var feature = Feature(geometry: Point(coordinate))
        feature.identifier = .string(currentId)
        pointList.append(feature)
        if (try? mapView.mapboxMap.source(withId: Constants.SOURCE_ID)) != nil {
            mapView.mapboxMap.updateGeoJSONSource(withId: Constants.SOURCE_ID, geoJSON: .featureCollection(FeatureCollection(features: pointList)))
        }

        if viewAnnotation {
            addViewAnnotation(id: currentId, geometry: .point(Point(coordinate)))
        }
    }

    // Add a view annotation at a specified location and optionally bind it to an ID of a marker
    @discardableResult
    private func addViewAnnotation(id: String, geometry: Geometry) -> Bool {
        guard case let .point(point) = geometry else { return false }
        let annotationView = AnnotationView(frame: .zero)
        annotationView.title = String(format: "lat=%.2f\nlon=%.2f", point.coordinates.latitude, point.coordinates.longitude)

        let annotation = ViewAnnotation(
            annotatedFeature: .layerFeature(layerId: Constants.LAYER_ID, featureId: id),
            view: annotationView)
        annotation.variableAnchors = [ViewAnnotationAnchorConfig(anchor: .bottom, offsetY: markerHeight - 12)]
        mapView.viewAnnotations.add(annotation)

        annotationView.onClose = { [weak annotation, weak self] in
            annotation?.remove()
            self?.annotations.removeValue(forKey: id)
        }
        annotationView.onSelect = { [weak annotation, weak self] _ in
            guard let self else { return }
            annotation?.priority = self.topPriority
            annotation?.setNeedsUpdateSize()
        }

        annotations[id] = annotation
        return true
    }
}

extension ViewAnnotationMarkerExample {
    private enum Constants {
        static let BLUE_ICON_ID = "blue"
        static let SOURCE_ID = "source_id"
        static let LAYER_ID = "layer_id"
        static let TERRAIN_URL_TILE_RESOURCE = "mapbox://mapbox.mapbox-terrain-dem-v1"
        static let MARKER_ID_PREFIX = "view_annotation_"
        static let SELECTED_ADD_COEF_PX: CGFloat = 50
    }
}
