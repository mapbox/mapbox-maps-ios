import UIKit
import MapboxMaps
import CoreLocation

@objc(ViewAnnotationWithPointAnnotationExample)
final class ViewAnnotationWithPointAnnotationExample: UIViewController, ExampleProtocol {
    private enum Constants {
        static let BLUE_ICON_ID = "blue"
        static let SELECTED_ADD_COEF_PX: CGFloat = 50
    }

    private var mapView: MapView!
    private var pointAnnotationManager: PointAnnotationManager!

    private let image = UIImage(named: "blue_marker_view")!
    private lazy var markerHeight: CGFloat = image.size.height

    override func viewDidLoad() {
        super.viewDidLoad()

        let centerCoordinate = CLLocationCoordinate2D(latitude: 39.7128, longitude: -75.0060)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 7))

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        pointAnnotationManager = mapView.annotations.makePointAnnotationManager()

        mapView.mapboxMap.onNext(.mapLoaded) { [weak self] _ in
            guard let self = self else { return }
            self.finish()
        }

        mapView.mapboxMap.onEvery(.styleLoaded) { [weak self] _ in
            guard let self = self else { return }
            try? self.mapView.mapboxMap.style.addImage(self.image, id: Constants.BLUE_ICON_ID, stretchX: [], stretchY: [])
        }

        mapView.mapboxMap.style.uri = .streets

        addPointAndViewAnnotation(at: mapView.mapboxMap.coordinate(for: mapView.center))
    }

    // MARK: - Annotation management

    private func addPointAndViewAnnotation(at coordinate: CLLocationCoordinate2D) {
        let markerId = addPointAnnotation(at: coordinate)
        addViewAnnotation(at: coordinate, withPointAnnotationId: markerId)
    }

    private func addPointAnnotation(at coordinate: CLLocationCoordinate2D) -> String {
        var pointAnnotation = PointAnnotation(coordinate: coordinate)
        pointAnnotation.iconImage = Constants.BLUE_ICON_ID
        pointAnnotation.iconAnchor = .bottom

        pointAnnotationManager.annotations.append(pointAnnotation)

        return pointAnnotation.id
    }

    // Add a view annotation at a specified location and optionally bind it to an ID of a marker
    private func addViewAnnotation(at coordinate: CLLocationCoordinate2D, withPointAnnotationId markerId: String? = nil) {
        let options = ViewAnnotationOptions(
            geometry: Point(coordinate),
            width: 128,
            height: 64,
            associatedFeatureId: markerId,
            allowOverlap: false,
            anchor: .bottom,
            offsetY: markerHeight
        )
        let annotationView = AnnotationView(frame: CGRect(x: 0, y: 0, width: 128, height: 64))
        annotationView.title = String(format: "lat=%.2f\nlon=%.2f", coordinate.latitude, coordinate.longitude)
        annotationView.delegate = self
        try? mapView.viewAnnotations.add(annotationView, options: options)
    }
}

extension ViewAnnotationWithPointAnnotationExample: AnnotationViewDelegate {
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
