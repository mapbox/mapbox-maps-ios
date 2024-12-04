import UIKit
import MapboxMaps
import CoreLocation

final class ViewAnnotationAnimationExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var cancelables = Set<AnyCancelable>()

    private lazy var route: LineString = {
        let routeURL = Bundle.main.url(forResource: "sf_airport_route", withExtension: "geojson")!
        let routeData = try! Data(contentsOf: routeURL)

        return try! JSONDecoder().decode(LineString.self, from: routeData)
    }()
    private lazy var totalDistance: CLLocationDistance = route.distance() ?? 0
    private var annotation: ViewAnnotation?
    private var animationStartTime: TimeInterval = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // center camera around SF airport
        let centerCoordinate = CLLocationCoordinate2D(latitude: 37.7080221537549, longitude: -122.39470445734368)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 11))

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.mapboxMap.onStyleLoaded.observeNext { [weak self] _ in
            guard let self = self else { return }

            self.setupExample()
        }.store(in: &cancelables)
    }

    private func setupExample() {
        var source = GeoJSONSource(id: "route-source")
        source.data = .geometry(route.geometry)

        try! mapView.mapboxMap.addSource(source)

        var layer = LineLayer(id: "route-layer", source: source.id)
        layer.lineColor = .constant(StyleColor(UIColor.systemPink))
        layer.lineWidth = .constant(4)

        try! mapView.mapboxMap.addLayer(layer)

        let view = UIImageView(image: UIImage(named: "intermediate-pin"))
        view.contentMode = .scaleAspectFit
        let annotation = ViewAnnotation(coordinate: route.coordinates.first!, view: view)
        annotation.variableAnchors = [.init(anchor: .bottom, offsetY: -12)]
        mapView.viewAnnotations.add(annotation)
        self.annotation = annotation
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if mapView.mapboxMap.isStyleLoaded {
            startAnimation()
        } else {
            mapView.mapboxMap.onMapLoaded.observeNext { _ in
                self.startAnimation()
            }.store(in: &cancelables)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        animationStartTime = 0 // stops the animation
    }

    private func startAnimation() {
        let link = CADisplayLink(target: self, selector: #selector(animateNextStep))
        link.add(to: .main, forMode: .default)

        animationStartTime = CACurrentMediaTime()
    }

    @objc private func animateNextStep(_ displayLink: CADisplayLink) {
        let animationDuration: TimeInterval = 30
        let progress = (CACurrentMediaTime() - animationStartTime) / animationDuration
        let currentDistanceOffset = totalDistance * min(progress, 1)

        defer {
            if progress >= 1 {
                displayLink.invalidate()

                // The below line is used for internal testing purposes only.
                self.finish()
            }
        }
        let currentCoordinate = route.coordinateFromStart(distance: currentDistanceOffset)!

        // set new coordinate to the annotation
        annotation?.annotatedFeature = .geometry(Point(currentCoordinate))
    }
}
