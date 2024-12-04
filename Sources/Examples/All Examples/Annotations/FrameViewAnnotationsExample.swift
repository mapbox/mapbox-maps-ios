import UIKit
import MapboxMaps

final class FrameViewAnnotationsExample: UIViewController, ExampleProtocol {
    private enum Animator {
        case flyTo, easeTo, viewport
    }

    private var cancelables = Set<AnyCancelable>()
    private var flyToButton: UIButton!
    private var easeToButton: UIButton!
    private var viewportButton: UIButton!
    private var resetButton: UIButton!
    private var annotations = [ViewAnnotation]()

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
        // Camera
        try! mapView.mapboxMap.setProjection(StyleProjection(name: .mercator))
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

        mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
            // The below line is used for internal testing purposes only.
            self?.finish()
        }.store(in: &cancelables)
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
        mapView.viewport.idle()
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
            forAnnotations: annotations,
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
                bearing: camera.bearing,
                pitch: camera.pitch,
                animationDuration: 1
            )
            let overviewViewportState = mapView.viewport.makeOverviewViewportState(options: overviewViewportStateOptions)
            mapView.viewport.transition(to: overviewViewportState)
        }
    }

    private func addAnnotations() {
        func makeView(text: String) -> UIView {
            let view = UIView()
            view.backgroundColor = .white
            view.layer.shadowOpacity = 0.25
            view.layer.shadowRadius = 8
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.cornerRadius = 8
            let label = UILabel()
            label.text = text
            label.textColor = .black
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
                label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
                label.topAnchor.constraint(equalTo: view.topAnchor, constant: 4),
                label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -4),
            ])
            return view
        }

        self.annotations = annotationData.map {
            let view = makeView(text: $0.name)
            let annotation = ViewAnnotation(coordinate: $0.coordinate, view: view)
            annotation.variableAnchors = [.init(anchor: $0.anchor)]
            self.mapView.viewAnnotations.add(annotation)
            return annotation
        }
    }

    private struct AnnotationInfo {
        var name: String
        var coordinate: CLLocationCoordinate2D
        var anchor: ViewAnnotationAnchor
    }

    private let annotationData: [AnnotationInfo] = [
        AnnotationInfo(name: "Saigon", coordinate: .init(latitude: 10.823099, longitude: 106.629662),
            anchor: .top),
        AnnotationInfo(name: "Hanoi", coordinate: .init(latitude: 21.027763, longitude: 105.834160),
            anchor: .bottomLeft),
        AnnotationInfo(name: "Tokyo", coordinate: .init(latitude: 35.689487, longitude: 139.691711),
            anchor: .right),
        AnnotationInfo(name: "Bangkok", coordinate: .init(latitude: 13.756331, longitude: 100.501762),
            anchor: .topRight),
        AnnotationInfo(name: "Jakarta", coordinate: .init(latitude: -6.175110, longitude: 106.865036),
            anchor: .topLeft)
    ]
}

private func annotation(geometry: GeometryConvertible, width: CGFloat, height: CGFloat, anchor: ViewAnnotationAnchor) -> ViewAnnotationOptions {
    .init(
        annotatedFeature: .geometry(geometry),
        width: width,
        height: height,
        allowOverlap: true,
        variableAnchors: [ViewAnnotationAnchorConfig(anchor: anchor)])
}
