#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
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
            allowOverlap: false,
            anchor: .center
        )
        let labelText = String(format: "lat=%.2f\nlon=%.2f", coordinate.latitude, coordinate.longitude)
        let sampleView = createSampleView(withText: labelText)
        try? mapView.viewAnnotations.add(sampleView, options: options)
    }

    private func createSampleView(withText text: String) -> UIView {
        let sampleView = UIView()
        sampleView.bounds.size = CGSize(width: 64, height: 32)
        sampleView.backgroundColor = .blue
        sampleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSampleViewClick)))

        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 10)
        label.numberOfLines = 0
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        sampleView.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: sampleView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: sampleView.centerYAnchor)
        ])

        return sampleView
    }

}
