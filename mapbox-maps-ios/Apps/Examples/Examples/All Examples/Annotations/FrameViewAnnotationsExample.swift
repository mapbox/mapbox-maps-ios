import UIKit
import MapboxMaps

final class FrameViewAnnotationsExample: UIViewController, ExampleProtocol {

    private enum Animator {
        case flyTo, easeTo, viewport
    }

    private var flyToButton: UIButton!
    private var easeToButton: UIButton!
    private var viewportButton: UIButton!
    private var resetButton: UIButton!

    private var mapView: MapView!
    private let initialCamera = CameraOptions(
        center: .random,
        padding: UIEdgeInsets(top: .random(in: 0...20), left: .random(in: 0...20), bottom: .random(in: 0...20), right: .random(in: 0...20)),
        zoom: 0,
        bearing: 0,
        pitch: 0
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        mapView = MapView(frame: view.bounds, mapInitOptions: MapInitOptions(cameraOptions: initialCamera))
        let buttonsView = makeButtonsView()

        view.addSubview(mapView)
        view.addSubview(buttonsView)

        mapView.translatesAutoresizingMaskIntoConstraints = false
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsView.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor),
            buttonsView.bottomAnchor.constraint(equalTo: mapView.ornaments.logoView.topAnchor, constant: -10),
        ])

        addAnnotations()

        mapView.mapboxMap.onNext(event: .mapLoaded) { [weak self] _ in
            // The below line is used for internal testing purposes only.
            self?.finish()
        }
    }

    private func makeButtonsView() -> UIView {
        func makeButton(title: String, selector: Selector) -> UIButton {
            let button = UIButton()
            button.setTitle(title, for: .normal)
            button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
            button.backgroundColor = .black
            button.addTarget(self, action: selector, for: .touchUpInside)
            return button
        }

        flyToButton = makeButton(title: "FlyTo", selector: #selector(flyToButtonTapped(_:)))
        easeToButton = makeButton(title: "EaseTo", selector: #selector(easeToButtonTapped(_:)))
        viewportButton = makeButton(title: "Viewport", selector: #selector(viewportButtonTapped(_:)))
        resetButton = makeButton(title: "Reset camera", selector: #selector(resetButtonTapped(_:)))

        let buttonsView = UIStackView(arrangedSubviews: [flyToButton, easeToButton, viewportButton, resetButton])
        buttonsView.axis = .horizontal
        buttonsView.spacing = 10
        buttonsView.distribution = .fillEqually

        resetButton.isHidden = true

        return buttonsView
    }

    @objc private func flyToButtonTapped(_ sender: UIButton) {
        frameViewAnnotation(with: .flyTo, sender: sender)
    }

    @objc private func easeToButtonTapped(_ sender: UIButton) {
        frameViewAnnotation(with: .easeTo, sender: sender)
    }

    @objc private func viewportButtonTapped(_ sender: UIButton) {
        frameViewAnnotation(with: .viewport, sender: sender)
    }

    @objc private func resetButtonTapped(_ sender: UIButton) {
        mapView.mapboxMap.setCamera(to: initialCamera)
        resetButton.isHidden = true
        flyToButton.isHidden = false
        easeToButton.isHidden = false
        viewportButton.isHidden = false
    }

    private func frameViewAnnotation(with animator: Animator, sender: UIButton) {
        flyToButton.isHidden = true
        easeToButton.isHidden = true
        viewportButton.isHidden = true
        resetButton.isHidden = false

        let camera = self.mapView.viewAnnotations.camera(
            forAnnotations: Array(annotations.keys),
            padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10),
            bearing: nil,
            pitch: nil
        )!

        switch animator {
        case .flyTo:
            mapView.camera.fly(to: camera, duration: 1)
        case .easeTo:
            mapView.camera.ease(to: camera, duration: 1)
        case .viewport:
            let bounds = mapView.mapboxMap.coordinateBounds(for: camera)
            let overviewViewportStateOptions = OverviewViewportStateOptions(
                geometry: MultiPoint([bounds.northeast, bounds.southeast, bounds.southwest, bounds.northwest]),
                padding: .zero,
                bearing: camera.bearing,
                pitch: camera.pitch,
                animationDuration: 1
            )
            let overviewViewportState = mapView.viewport.makeOverviewViewportState(options: overviewViewportStateOptions)
            mapView.viewport.transition(to: overviewViewportState)
        }
    }

    private func addAnnotations() {
        func makeView(_ bgColor: UIColor) -> UIView {
            let view = UIView()
            view.backgroundColor = bgColor
            return view
        }

        for (id, annotationOptions) in annotations {
            try! mapView.viewAnnotations.add(makeView(.green), id: id, options: annotationOptions)
        }
    }

    private let annotations: [String: ViewAnnotationOptions] = [
        "Saigon": .init(
            geometry: Point(LocationCoordinate2D(latitude: 10.823099, longitude: 106.629662)),
            width: 179,
            height: 40,
            allowOverlap: true,
            anchor: .top),
        "Hanoi": .init(
            geometry: Point(LocationCoordinate2D(latitude: 21.027763, longitude: 105.834160)),
            width: 152,
            height: 40,
            allowOverlap: true,
            anchor: .bottomLeft),
        "Tokyo": .init(
            geometry: Point(LocationCoordinate2D(latitude: 35.689487, longitude: 139.691711)),
            width: 102,
            height: 40,
            allowOverlap: true,
            anchor: .right),
        "Bangkok": .init(
            geometry: Point(LocationCoordinate2D(latitude: 13.756331, longitude: 100.501762)),
            width: 191,
            height: 40,
            allowOverlap: true,
            anchor: .topRight),
        "Jakarta": .init(
            geometry: Point(LocationCoordinate2D(latitude: -6.175110, longitude: 106.865036)),
            width: 95,
            height: 40,
            allowOverlap: true,
            anchor: .topLeft),
    ]
}
