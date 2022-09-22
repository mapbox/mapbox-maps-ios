import UIKit
import MapboxMaps
import CoreLocation

@objc(ViewAnnotationMarkerExample)
final class ViewAnnotationMarkerExample: UIViewController, ExampleProtocol {

    private enum Constants {
        static let BLUE_ICON_ID = "blue"
        static let SOURCE_ID = "source_id"
        static let LAYER_ID = "layer_id"
        static let TERRAIN_SOURCE = "TERRAIN_SOURCE"
        static let TERRAIN_URL_TILE_RESOURCE = "mapbox://mapbox.mapbox-terrain-dem-v1"
        static let MARKER_ID_PREFIX = "view_annotation_"
        static let SELECTED_ADD_COEF_PX: CGFloat = 50
    }

    private var mapView: MapView!
    private var pointList: [Feature] = []
    private var markerId = 0

    private let image = UIImage(named: "blue_marker_view")!
    private lazy var markerHeight: CGFloat = image.size.height

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
        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onMapClick)))
        mapView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(onMapLongClick)))
        view.addSubview(mapView)

        addMarkerAndAnnotation(at: mapView.mapboxMap.coordinate(for: mapView.center))

        mapView.mapboxMap.onNext(event: .mapLoaded) { [weak self] _ in
            guard let self = self else { return }
            self.finish()
        }

        mapView.mapboxMap.onEvery(event: .styleLoaded) { [weak self] _ in
            self?.prepareStyle()
        }

        mapView.mapboxMap.style.uri = .streets

        view.addSubview(styleChangeButton)

        NSLayoutConstraint.activate([
            styleChangeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            styleChangeButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            styleChangeButton.widthAnchor.constraint(equalToConstant: 128)
        ])
    }

    // MARK: - Action handlers

    @objc private func onMapLongClick(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .ended else { return }
        let point = Point(mapView.mapboxMap.coordinate(for: sender.location(in: mapView)))
        _ = addMarker(at: point)
    }

    @objc private func onMapClick(_ sender: UITapGestureRecognizer) {
        let screenPoint = sender.location(in: mapView)
        let queryOptions = RenderedQueryOptions(layerIds: [Constants.LAYER_ID], filter: nil)
        mapView.mapboxMap.queryRenderedFeatures(with: screenPoint, options: queryOptions) { [weak self] result in
            if case let .success(queriedFeatures) = result,
               let self = self,
               let feature = queriedFeatures.first?.feature,
               let id = feature.identifier,
               case let .string(idString) = id,
               let viewAnnotations = self.mapView.viewAnnotations {
                if let annotationView = viewAnnotations.view(forFeatureId: idString) {
                    let visible = viewAnnotations.options(for: annotationView)?.visible ?? true
                    try? viewAnnotations.update(annotationView, options: ViewAnnotationOptions(visible: !visible))
                } else {
                    let markerCoordinates: CLLocationCoordinate2D
                    if let geometry = feature.geometry, case let Geometry.point(point) = geometry {
                        markerCoordinates = point.coordinates
                    } else {
                        markerCoordinates = self.mapView.mapboxMap.coordinate(for: screenPoint)
                    }
                    self.addViewAnnotation(at: markerCoordinates, withMarkerId: idString)
                }
            }
        }
    }

    @objc private func styleChangePressed(sender: UIButton) {
        mapView.mapboxMap.style.uri = mapView.mapboxMap.style.uri == .streets ? .satelliteStreets : .streets
    }

    // MARK: - Style management

    private func prepareStyle() {
        let style = mapView.mapboxMap.style
        try? style.addImage(image, id: Constants.BLUE_ICON_ID)

        var source = GeoJSONSource()
        source.data = .featureCollection(FeatureCollection(features: pointList))
        try? mapView.mapboxMap.style.addSource(source, id: Constants.SOURCE_ID)

        if style.uri == .satelliteStreets {
            var demSource = RasterDemSource()
            demSource.url = Constants.TERRAIN_URL_TILE_RESOURCE
            try? mapView.mapboxMap.style.addSource(demSource, id: Constants.TERRAIN_SOURCE)
            let terrain = Terrain(sourceId: Constants.TERRAIN_SOURCE)
            try? mapView.mapboxMap.style.setTerrain(terrain)
        }

        var layer = SymbolLayer(id: Constants.LAYER_ID)
        layer.source = Constants.SOURCE_ID
        layer.iconImage = .constant(.name(Constants.BLUE_ICON_ID))
        layer.iconAnchor = .constant(.bottom)
        layer.iconAllowOverlap = .constant(true)
        try? mapView.mapboxMap.style.addLayer(layer)
    }

    // MARK: - Annotation management

    private func addMarkerAndAnnotation(at coordinate: CLLocationCoordinate2D) {
        let point = Point(coordinate)
        let markerId = addMarker(at: point)
        addViewAnnotation(at: coordinate, withMarkerId: markerId)
    }

    // Add a marker to a custom GeoJSON source:
    // This is an optional step to demonstrate the automatic alignment of view annotations
    // with features in a data source
    private func addMarker(at point: Point) -> String {
        let currentId = "\(Constants.MARKER_ID_PREFIX)\(markerId)"
        markerId += 1
        var feature = Feature(geometry: point)
        feature.identifier = .string(currentId)
        pointList.append(feature)
        if (try? mapView.mapboxMap.style.source(withId: Constants.SOURCE_ID)) != nil {
            try? mapView.mapboxMap.style.updateGeoJSONSource(withId: Constants.SOURCE_ID, geoJSON: .featureCollection(FeatureCollection(features: pointList)))
        }
        return currentId
    }

    // Add a view annotation at a specified location and optionally bind it to an ID of a marker
    private func addViewAnnotation(at coordinate: CLLocationCoordinate2D, withMarkerId markerId: String? = nil) {
        let options = ViewAnnotationOptions(
            geometry: Point(coordinate),
            width: 128,
            height: 64,
            associatedFeatureId: markerId,
            allowOverlap: false,
            anchor: .bottom
        )
        let annotationView = AnnotationView(frame: CGRect(x: 0, y: 0, width: 128, height: 64))
        annotationView.title = String(format: "lat=%.2f\nlon=%.2f", coordinate.latitude, coordinate.longitude)
        annotationView.delegate = self
        try? mapView.viewAnnotations.add(annotationView, options: options)

        // Set the vertical offset of the annotation view to be placed above the marker
        try? mapView.viewAnnotations.update(annotationView, options: ViewAnnotationOptions(offsetY: markerHeight))
    }
}

extension ViewAnnotationMarkerExample: AnnotationViewDelegate {
    func annotationViewDidSelect(_ annotationView: AnnotationView) {
        guard let options = self.mapView.viewAnnotations.options(for: annotationView) else { return }

        let updateOptions = ViewAnnotationOptions(
            width: (options.width ?? 0.0) + Constants.SELECTED_ADD_COEF_PX,
            height: (options.height ?? 0.0) + Constants.SELECTED_ADD_COEF_PX,
            selected: true
        )
        try? self.mapView.viewAnnotations.update(annotationView, options: updateOptions)
    }

    func annotationViewDidUnselect(_ annotationView: AnnotationView) {
        guard let options = self.mapView.viewAnnotations.options(for: annotationView) else { return }

        let updateOptions = ViewAnnotationOptions(
            width: (options.width ?? 0.0) - Constants.SELECTED_ADD_COEF_PX,
            height: (options.height ?? 0.0) - Constants.SELECTED_ADD_COEF_PX,
            selected: false
        )
        try? self.mapView.viewAnnotations.update(annotationView, options: updateOptions)
    }

    // Handle the actions for the button clicks inside the `SampleView` instance
    func annotationViewDidPressClose(_ annotationView: AnnotationView) {
        mapView.viewAnnotations.remove(annotationView)
    }
}
