import UIKit
import MapboxMaps
import CoreLocation

final class ViewAnnotationBasicExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var cancelables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        let centerCoordinate = CLLocationCoordinate2D(latitude: 39.7128, longitude: -75.0060)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 7))

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        addViewAnnotation(at: mapView.mapboxMap.coordinate(for: mapView.center))

        mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
            guard let self = self else { return }
            self.finish()
        }.store(in: &cancelables)

        mapView.gestures.onMapTap.observe { [weak self] context in
            self?.addViewAnnotation(at: context.coordinate)
        }.store(in: &cancelables)
    }

    private func addViewAnnotation(at coordinate: CLLocationCoordinate2D) {
        let annotationView = AnnotationView(frame: CGRect(x: 0, y: 0, width: 100, height: 80))
        annotationView.title = String(format: "lat=%.2f\nlon=%.2f", coordinate.latitude, coordinate.longitude)
        let annotation = ViewAnnotation(coordinate: coordinate, view: annotationView)
        annotation.allowOverlap = true
        annotationView.onClose = { [weak annotation] in annotation?.remove() }
        annotationView.onSelect = { [weak annotation] selected in
            annotation?.selected = selected
            annotation?.setNeedsUpdateSize()
        }
        mapView.viewAnnotations.add(annotation)
    }
}
