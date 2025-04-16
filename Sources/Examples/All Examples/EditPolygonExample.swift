import UIKit
import MapboxMaps

final class EditPolygonExample: UIViewController, ExampleProtocol {
    private enum ID {
        static let polygonLayer = "editable-polygon-layer-id"
        static let geoJsonSource = "editable-geojson-source"
    }

    private var mapView: MapView!
    private var cancelables: Set<AnyCancelable> = []

    private lazy var circleAnnotationsManager = mapView.annotations.makeCircleAnnotationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        let cameraOptions = CameraOptions(
            center: .helsinki,
            zoom: 3,
            bearing: 12)
        let options = MapInitOptions(cameraOptions: cameraOptions)
        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(mapView)

        mapView.gestures.onMapTap.observe { [weak self] context in
            self?.dropPin(at: context.coordinate)
        }.store(in: &cancelables)

        mapView.mapboxMap.onStyleLoaded.observeNext { [weak self] _ in
            self?.dropPin(at: .helsinki)
            self?.dropPin(at: .kyiv)
            self?.dropPin(at: .berlin)
        }.store(in: &cancelables)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The below line is used for internal testing purposes only.
        finish()
    }

    private func dropPin(at coordinate: CLLocationCoordinate2D) {
        var newAnnotation = CircleAnnotation(centerCoordinate: coordinate)
            .circleColor(.random)
            .circleRadius(10)
        newAnnotation.isDraggable = true

        newAnnotation.dragBeginHandler = { (annotation, _) in
            annotation.circleRadius = 15
            return true
        }
        newAnnotation.dragChangeHandler = { [weak self] (_, _) in
            self?.addOrEditPolygon()
        }
        newAnnotation.dragEndHandler = { (annotation, _) in
            annotation.circleRadius = 10
        }

        circleAnnotationsManager.annotations.append(newAnnotation)
        addOrEditPolygon()
    }

    private func addOrEditPolygon() {
        if !circleAnnotationsManager.annotations.isEmpty {
            mapView.mapboxMap.setMapStyleContent {
                GeoJSONSource(id: ID.geoJsonSource)
                    .data(.geometry(Polygon(outerRing: .init(coordinates: circleAnnotationsManager.annotations.map(\.point.coordinates))).geometry))
                FillLayer(id: ID.polygonLayer, source: ID.geoJsonSource)
                    .fillColor(.blue)
                    .fillOpacity(0.3)
                    .fillOutlineColor(.black)
            }
        }
    }
}
