import UIKit
import MapboxMaps

final class FrameViewAnnotationsExample: UIViewController, ExampleProtocol {

    private var mapView: MapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)

        let showAnnotationsButton = UIButton()
        showAnnotationsButton.setTitle("Frame Annotations", for: .normal)
        showAnnotationsButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        showAnnotationsButton.backgroundColor = .black
        showAnnotationsButton.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)

        view.addSubview(mapView)
        view.addSubview(showAnnotationsButton)

        mapView.translatesAutoresizingMaskIntoConstraints = false
        showAnnotationsButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            showAnnotationsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            showAnnotationsButton.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor),
            showAnnotationsButton.bottomAnchor.constraint(equalTo: mapView.ornaments.logoView.topAnchor, constant: -10),
        ])

        addAnnotations()

        mapView.mapboxMap.onNext(event: .mapLoaded) { [weak self] _ in
            // The below line is used for internal testing purposes only.
            self?.finish()
        }
    }

    @objc private func tap(_ sender: UIButton) {
        mapView.viewAnnotations.showAnnotations(
            Array(coordinates.keys),
            padding: .zero,
            pitch: nil,
            animationDuration: 1)
    }

    private func addAnnotations() {
        for (id, point) in coordinates {
            let options = ViewAnnotationOptions(
                geometry: point.geometry,
                width: 40,
                height: 40,
                allowOverlap: true,
                anchor: .center,
                offsetX: 0,
                offsetY: 0)
            let annotation = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            annotation.backgroundColor = .green
            try! mapView.viewAnnotations.add(annotation, id: id, options: options)
        }
    }

    private let coordinates: [String: Point] = [
        "Saigon": .init(LocationCoordinate2D(latitude: 10.823099, longitude: 106.629662)),
        "Hanoi": .init(LocationCoordinate2D(latitude: 21.027763, longitude: 105.834160)),
        "Tokyo": .init(LocationCoordinate2D(latitude: 35.689487, longitude: 139.691711)),
        "Bangkok": .init(LocationCoordinate2D(latitude: 13.756331, longitude: 100.501762)),
        "Jakarta": .init(LocationCoordinate2D(latitude: -6.175110, longitude: 106.865036)),
    ]
}
