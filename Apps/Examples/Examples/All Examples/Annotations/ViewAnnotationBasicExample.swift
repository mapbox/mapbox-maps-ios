import UIKit
import MapboxMaps
import CoreLocation

@objc(ViewAnnotationBasicExample)
final class ViewAnnotationBasicExample: UIViewController, ExampleProtocol {

    private var mapView: MapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let centerCoordinate = CLLocationCoordinate2D(latitude: 39.7128, longitude: -75.0060)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 7))

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onMapClick)))
        view.addSubview(mapView)

        addViewAnnotation(at: mapView.mapboxMap.coordinate(for: mapView.center))

        mapView.mapboxMap.onNext(.mapLoaded) { [weak self] _ in
            guard let self = self else { return }
            self.finish()
        }
    }

    // MARK: - Action handlers

    @objc private func onMapClick(_ sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }
        addViewAnnotation(at: mapView.mapboxMap.coordinate(for: sender.location(in: mapView)))
    }

    @objc private func onSampleViewClick(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        mapView.viewAnnotations.remove(view)
    }

    // MARK: - Annotation management

    private func addViewAnnotation(at coordinate: CLLocationCoordinate2D) {
        let options = ViewAnnotationOptions(
            geometry: Point(coordinate),
            allowOverlap: true,
            anchor: .center
        )
        let annotationView = AnnotationView(frame: CGRect(x: 0, y: 0, width: 100, height: 80))
        annotationView.title = String(format: "lat=%.2f\nlon=%.2f", coordinate.latitude, coordinate.longitude)
        annotationView.delegate = self
        try? mapView.viewAnnotations.add(annotationView, options: options)
    }
}

extension ViewAnnotationBasicExample: AnnotationViewDelegate {
    func annotationViewDidSelect(_ annotationView: AnnotationView) {
        let options = ViewAnnotationOptions(selected: true)

        try? mapView.viewAnnotations.update(annotationView, options: options)
    }

    func annotationViewDidUnselect(_ annotationView: AnnotationView) {
        let options = ViewAnnotationOptions(selected: false)

        try? mapView.viewAnnotations.update(annotationView, options: options)
    }

    func annotationViewDidPressClose(_ annotationView: AnnotationView) {
        mapView.viewAnnotations.remove(annotationView)
    }
}
