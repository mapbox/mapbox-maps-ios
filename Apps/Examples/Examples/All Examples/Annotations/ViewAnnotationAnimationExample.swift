import UIKit
import MapboxMaps
import CoreLocation

final class ViewAnnotationAnimationExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!

    private lazy var route: LineString = {
        let routeURL = Bundle.main.url(forResource: "sf_airport_route", withExtension: "geojson")!
        let routeData = try! Data(contentsOf: routeURL)

        return try! JSONDecoder().decode(LineString.self, from: routeData)
    }()
    private lazy var totalDistance: CLLocationDistance = route.distance() ?? 0
    private lazy var annotationView: UIView = {
        let view = UIImageView(image: UIImage(named: "blue_marker_view"))
        view.contentMode = .scaleAspectFit
        return view
    }()
    private var animationStartTime: TimeInterval = 0
    private lazy var displayLink: CADisplayLink = CADisplayLink(target: self, selector: #selector(animateNextStep))

    deinit {
        displayLink.invalidate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // center camera around SF airport
        let centerCoordinate = CLLocationCoordinate2D(latitude: 37.7080221537549, longitude: -122.39470445734368)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 11))

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        // prevents view annotations being unsynchronized with map movements
        mapView.presentsWithTransaction = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.mapboxMap.onNext(event: .mapLoaded) { [weak self] _ in
            guard let self = self else { return }

            self.setupExample()
            self.isMapLoaded = true
        }
    }

    private var isMapLoaded: Bool = false

    private func setupExample() {
        var source = GeoJSONSource()
        source.data = .geometry(route.geometry)

        try! mapView.mapboxMap.style.addSource(source, id: "route-source")

        var layer = LineLayer(id: "route-layer")
        layer.source = "route-source"
        layer.lineColor = .constant(StyleColor(UIColor.systemPink))
        layer.lineWidth = .constant(4)

        try! mapView.mapboxMap.style.addLayer(layer)

        let options = ViewAnnotationOptions(
            geometry: Point(route.coordinates.first!),
            width: 50,
            height: 50,
            anchor: .bottom,
            offsetY: -5
        )
        try! mapView.viewAnnotations.add(annotationView, options: options)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if isMapLoaded {
            startAnimation()
        } else {
            mapView.mapboxMap.onNext(event: .mapLoaded) { _ in
                self.startAnimation()
            }
        }

        displayLink.isPaused = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMapLoaded {
            displayLink.isPaused = true
        }
    }

    private func startAnimation() {
        displayLink.add(to: .main, forMode: .common)

        if animationStartTime == 0 {
            animationStartTime = CACurrentMediaTime()
        }
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
        let options = ViewAnnotationOptions(geometry: Point(currentCoordinate))
        try! mapView.viewAnnotations.update(annotationView, options: options)
    }
}
