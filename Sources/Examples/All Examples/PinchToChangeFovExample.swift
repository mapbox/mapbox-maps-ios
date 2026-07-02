import UIKit
@_spi(Experimental) import MapboxMaps

final class PinchToChangeFovExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var fovLabel: UILabel!
    private var fovAtGestureStart: CGFloat = 36.87
    private let fovRange: ClosedRange<CGFloat> = 11...90

    override func viewDidLoad() {
        super.viewDidLoad()

        let camera = CameraOptions(
            center: CLLocationCoordinate2D(latitude: 59.3419, longitude: 18.0669),
            zoom: 16.5,
            bearing: 30,
            pitch: 70)
        let options = MapInitOptions(cameraOptions: camera)
        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Disable built-in pinch-to-zoom so we can repurpose the pinch gesture for FOV
        mapView.gestures.options.pinchEnabled = false

        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        mapView.addGestureRecognizer(pinch)

        setupLabel()
        updateLabel(mapView.mapboxMap.cameraState.verticalFov)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        finish()
    }

    private func setupLabel() {
        fovLabel = UILabel()
        fovLabel.textColor = .white
        fovLabel.textAlignment = .center
        fovLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        fovLabel.layer.cornerRadius = 10
        fovLabel.layer.masksToBounds = true
        fovLabel.font = .monospacedSystemFont(ofSize: 15, weight: .medium)
        fovLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fovLabel)

        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            fovLabel.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -20),
            fovLabel.centerXAnchor.constraint(equalTo: safe.centerXAnchor),
            fovLabel.widthAnchor.constraint(equalToConstant: 200),
            fovLabel.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func updateLabel(_ fov: CGFloat) {
        fovLabel.text = String(format: "FOV: %.1f°", fov)
    }

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            fovAtGestureStart = mapView.mapboxMap.cameraState.verticalFov
        case .changed:
            guard gesture.scale > 0 else { return }
            // Pinch out (scale > 1) narrows FOV (like zooming in); pinch in widens it
            let newFov = min(fovRange.upperBound, max(fovRange.lowerBound, fovAtGestureStart / gesture.scale))
            mapView.mapboxMap.setCamera(to: CameraOptions(verticalFov: newFov))
            updateLabel(newFov)
        default:
            break
        }
    }
}
