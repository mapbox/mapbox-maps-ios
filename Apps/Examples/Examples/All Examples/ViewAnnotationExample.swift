import UIKit
import MapboxMaps
import CoreLocation

@objc(ViewAnnotationExample)
final class ViewAnnotationExample: UIViewController, ExampleProtocol {

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

        mapView.mapboxMap.onNext(.mapLoaded) { [weak self] _ in
            guard let self = self else { return }
            self.addMarkerAndAnnotation(at: self.mapView.mapboxMap.coordinate(for: self.mapView.center))
            self.finish()
        }

        mapView.mapboxMap.onEvery(.styleLoaded) { [weak self] _ in
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
        addMarkerAndAnnotation(at: mapView.mapboxMap.coordinate(for: sender.location(in: mapView)))
    }

    @objc private func onMapClick(_ sender: UITapGestureRecognizer) {
        let screenPoint = sender.location(in: mapView)
        let queryOptions = RenderedQueryOptions(layerIds: [Constants.LAYER_ID], filter: nil)
        mapView.mapboxMap.queryRenderedFeatures(at: screenPoint, options: queryOptions) { [weak self] result in
            if case let .success(queriedFeatures) = result,
                let feature = queriedFeatures.first?.feature,
                let id = feature.identifier,
                case let .string(idString) = id,
                let viewAnnotation = self?.mapView.viewAnnotations.viewAnnotation(byFeatureId: idString) {
                viewAnnotation.isHidden = !viewAnnotation.isHidden
            }
        }
    }

    @objc private func styleChangePressed(sender: UIButton) {
        mapView.mapboxMap.style.uri = mapView.mapboxMap.style.uri == .streets ? .satelliteStreets : .streets
    }

    // MARK: - Style management

    private func prepareStyle() {
        let style = mapView.mapboxMap.style
        try? style.addImage(image, id: Constants.BLUE_ICON_ID, stretchX: [], stretchY: [])

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
        layer.iconAllowOverlap = .constant(false)
        try? mapView.mapboxMap.style.addLayer(layer)
    }

    // MARK: - Annotation management

    private func addMarkerAndAnnotation(at coordinate: CLLocationCoordinate2D) {
        let point = Point.init(coordinate)
        let markerId = addMarker(at: point)
        addViewAnnotation(at: coordinate, withMarkerId: markerId)
    }

    // Add a marker to a custom GeoJSON source:
    // This is an optional step to demonstrate the automatic alignment of view annotations
    // with features in a data source
    private func addMarker(at point: Point) -> String {
        let currentId = "\(Constants.MARKER_ID_PREFIX)\(markerId)"
        markerId += 1
        var feature = Feature(geometry: Geometry.point(point))
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
            geometry: .point(Point(coordinate)),
            width: 128,
            height: 64,
            associatedFeatureId: markerId,
            allowOverlap: false,
            anchor: .bottom
        )
        let sampleView = SampleView(withCoordinate: coordinate)

        // We receive an annotation view which will wrap our custom `SampleView` object
        guard let annotationView = try? mapView.viewAnnotations.addAnnotationView(withContent: sampleView, options: options) else {
            print("Failed to add annotation")
            return
        }

        // Set the vertical offset of the `AnnotationView` to be placed above the marker
        try? mapView.viewAnnotations.update(annotationView, options: ViewAnnotationOptions(offsetY: markerHeight))

        // Handle the actions for the button clicks inside the `SampleView` instance
        sampleView.closeCallback = { [weak self] in
            try? self?.mapView.viewAnnotations.remove(annotationView)
        }
        sampleView.selectCallback = { [weak self] in
            guard let self = self else { return }
            guard let options = self.mapView.viewAnnotations.options(byAnnotationView: annotationView) else { return }
            let selected = !(options.selected ?? false)
            let pxDelta = selected ? Constants.SELECTED_ADD_COEF_PX : -Constants.SELECTED_ADD_COEF_PX
            sampleView.selectButton.setTitle(selected ? "DESELECT" : "SELECT", for: .normal)
            let updateOptions = ViewAnnotationOptions(
                width: (options.width ?? 0.0) + pxDelta,
                height: (options.height ?? 0.0) + pxDelta,
                selected: selected
            )
            try? self.mapView.viewAnnotations.update(annotationView, options: updateOptions)
        }
    }

}

// `SampleView` is a custom `UIView` subclass which is used only for demonstration
private class SampleView: UIView {

    lazy var centerLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 10)
        label.numberOfLines = 0
        return label
    }()
    lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.black, for: .normal)
        button.setTitle("X", for: .normal)
        return button
    }()
    lazy var selectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 0.9882352941, alpha: 1)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.setTitle("SELECT", for: .normal)
        return button
    }()

    var closeCallback: (() -> Void)?
    var selectCallback: (() -> Void)?

    init(withCoordinate coordinate: CLLocationCoordinate2D) {
        super.init(frame: .zero)
        self.backgroundColor = .green

        centerLabel.text = String(format: "lat=%.2f\nlon=%.2f", coordinate.latitude, coordinate.longitude)
        closeButton.addTarget(self, action: #selector(closePressed(sender:)), for: .touchUpInside)
        selectButton.addTarget(self, action: #selector(selectPressed(sender:)), for: .touchUpInside)

        [centerLabel, closeButton, selectButton].forEach { item in
            item.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(item)
        }

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            closeButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -4),

            centerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            centerLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -4),
            centerLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 4),

            selectButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            selectButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -4),
            selectButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 4)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Action handlers

    @objc private func closePressed(sender: UIButton) {
        closeCallback?()
    }

    @objc private func selectPressed(sender: UIButton) {
        selectCallback?()
    }
}
