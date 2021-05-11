import UIKit
import MapboxMaps
import MetricKit

extension CLLocationCoordinate2D {
    init(_ lat: Double, _ lng: Double) {
        self.init(latitude: lat, longitude: lng)
    }

    static let Boston       = CLLocationCoordinate2D(42.3601, -71.0589)
    static let SanFrancisco = CLLocationCoordinate2D(37.7749, -122.4194)
    static let MexicoCity   = CLLocationCoordinate2D(19.4326, -99.1332)
    static let London       = CLLocationCoordinate2D(51.5074, -0.1278)
    static let Madrid       = CLLocationCoordinate2D(40.4168, -3.7038)
    static let Minsk        = CLLocationCoordinate2D(53.9006, 27.5590)
    static let Moscow       = CLLocationCoordinate2D(55.7558, 37.6173)
    static let HongKong     = CLLocationCoordinate2D(22.3193, 114.1694)
    static let Tokyo        = CLLocationCoordinate2D(35.6762, 139.6503)
    static let Melbourne    = CLLocationCoordinate2D(-37.8136, 144.9631)
    static let BuenosAires  = CLLocationCoordinate2D(-34.6037, -58.3816)
    static let Reykjavik    = CLLocationCoordinate2D(64.1466, -21.9426)
}

class ViewController: UIViewController {
    var mapView: MapView!

    var startTime: TimeInterval = 0
    var endTime: TimeInterval   = 0

    // Fly through these coordinates
    var coordStep = 0
    var coords: [CLLocationCoordinate2D] = [
        .London,
        .Madrid,
        .Minsk,
        .Moscow,
        .HongKong,
        .Tokyo,
        .Melbourne,
        .BuenosAires,
        .MexicoCity,
        .SanFrancisco,
        .Boston,
        .Reykjavik
    ]

    // Cycle each fly-to set through these styles
    var styleStep = 0
    var styles: [(StyleURI, String?)] = {
        return [
            (.streets, "land"),
            (.outdoors, "land"),
            (.dark, "land"),
            (.light, "land"),
            (.satellite, nil),
            (.satelliteStreets, nil),
            (.custom(url: URL(string: "mapbox://styles/mapbox-map-design/ck40ed2go56yr1cp7bbsalr1c")!), "land"),
            (.custom(url: URL(string: "mapbox://styles/examples/cke97f49z5rlg19l310b7uu7j")!), nil),
        ]
    }()

    var step = 0

    // How many steps to take before finishing
    var maxSteps: Int {
        2 * styles.count * coords.count
    }

    var annotations: [PointAnnotation] = []
    var color: StylePropertyValue?
    var mapInitOptions: MapInitOptions!
    var snapshotter: Snapshotter?
    var logHandle: OSLog!

    override func viewDidLoad() {
        super.viewDidLoad()

        annotations.reserveCapacity(100)

        // Do any additional setup after loading the view.
        mapInitOptions = MapInitOptions()
        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.leftAnchor.constraint(equalTo: view.leftAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.rightAnchor.constraint(equalTo: view.rightAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        logHandle = MXMetricManager.makeLogHandle(category: "StressTest")
        start()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Set initial conditions
        mapView.on(.styleLoaded) { _ in
            self.flyToNextCoordinate()
        }

        mapView.style.uri = styles[styleStep].0
    }

    func flyToNextCoordinate() {

        // Check to see if we should cycle through the coordinates
        // and styles
        if coordStep >= coords.count {
            coordStep = 0
            styleStep += 1

            if styleStep >= styles.count {
                styleStep = 0
            }

            removeAnnotations()

            // Change the style
            mapView.style.uri = styles[styleStep].0
            print("Changing style to \(styles[styleStep].0)")

            return
        }

        let dest = coords[coordStep]

        // Every 2 steps, add or remove annotations
        if step % 2 == 0 {
            if annotations.isEmpty {
                addAnnotations(around: dest)
            } else {
                removeAnnotations()
            }
        }

        // Every 5 steps, toggle color expressions
        if step % 5 == 0 {
            if color == nil {
                pushColorExpression()
            } else {
                popColorExpression()
            }
        }

        snapshotter = nil

        flyTo(end: dest) {
            // At the end of the fly-to, use the snapshotter before moving on
            self.takeSnapshot {
                DispatchQueue.main.async(execute: self.nextStep)
            }
        }
    }

    func nextStep() {
        coordStep += 1
        step += 1

        if step < maxSteps {
            flyToNextCoordinate()
        } else {
            finish()
        }
    }

    func start() {
        mxSignpost(.begin, log: logHandle, name: "StressTest")
        startTime = CACurrentMediaTime()
    }

    func finish() {
        endTime = CACurrentMediaTime()
        mxSignpost(.end, log: logHandle, name: "StressTest")

        let totalSeconds = endTime - startTime
        let message = "Time taken: \(totalSeconds)"
        print("Stress-test completed: \(message)")

        let label = UILabel()
        label.text            = message
        label.textColor       = .white
        label.backgroundColor = .red
        label.sizeToFit()
        view.addSubview(label)

        DispatchQueue.main.asyncAfter(deadline: .now()+10) {
            self.mapView.removeFromSuperview()
            self.mapView = nil
        }
    }

    func flyTo(end: CLLocationCoordinate2D, completion: @escaping () -> Void) {
        let startOptions = mapView.cameraState
        let start = startOptions.center

        let lineAnnotation = LineAnnotation(coordinates: [start, end])

        // Add the annotation to the map.
        print("Adding line annotation")
        mapView.annotations.addAnnotation(lineAnnotation)

        let endOptions = CameraOptions(center: end, zoom: 17)

        var animator: CameraAnimator?
        animator = mapView.camera.fly(to: endOptions) { _ in
            print("Removing line annotation for animator \(String(describing: animator))")
            self.mapView.annotations.removeAnnotation(lineAnnotation)
            animator = nil
            completion()
        }
    }

    func removeAnnotations() {
        print("Removing \(annotations.count) annotations")
        mapView.annotations.removeAnnotations(annotations)
        annotations = []
    }

    func addAnnotations(around coord: CLLocationCoordinate2D) {
        for lat in stride(from: coord.latitude-0.25, to: coord.latitude+0.25, by: 0.05) {
            for lng in stride(from: coord.longitude-0.25, to: coord.longitude+0.25, by: 0.05) {
                let pointAnnotation = PointAnnotation(coordinate: CLLocationCoordinate2D(lat, lng))
                annotations.append(pointAnnotation)
            }
        }

        print("Adding \(annotations.count) annotations")
        mapView.annotations.addAnnotations(annotations)
    }

    func pushColorExpression() {
        guard let land = styles[styleStep].1 else {
            return
        }

        let exp = Exp(.interpolate) {
            Exp(.linear)
            Exp(.zoom)
            0
            UIColor.red
            14
            UIColor.blue
        }

        do {
            let data = try JSONEncoder().encode(exp.self)
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            color = mapView.mapboxMap.__map.getStyleLayerProperty(
                forLayerId: land,
                property: "background-color")

            print("Setting background color expression")
            mapView.mapboxMap.__map.setStyleLayerPropertyForLayerId(
                land,
                property: "background-color",
                value: jsonObject)
        } catch let error {
            print("Error setting background color: \(error)")
        }
    }

    func popColorExpression() {
        guard let land = styles[styleStep].1 else {
            return
        }

        if let color = color {
            print("Re-setting background color expression")
            mapView.mapboxMap.__map.setStyleLayerPropertyForLayerId(
                land,
                property: "background-color",
                value: color.value)
        }
        color = nil
    }

    func takeSnapshot(_ completion: @escaping () -> Void) {
        guard snapshotter == nil else {
            fatalError()
        }

        // Configure the snapshotter object with its default access
        // token, size, map style, and camera.
        let options = MapSnapshotOptions(size: CGSize(width: 300, height: 300),
                                         pixelRatio: 1,
                                         resourceOptions: mapInitOptions.resourceOptions)

        print("Creating snapshotter")
        let snapshotter = Snapshotter(options: options)
        snapshotter.style.uri = .light
        snapshotter.setCamera(to: CameraOptions(cameraState: mapView.cameraState))

        snapshotter.on(.styleLoaded) { [weak self] _ in
            guard let snapshotter = self?.snapshotter else {
                assertionFailure("Snapshotter does not exist")
                completion()
                return true
            }

            snapshotter.start(overlayHandler: nil) { _ in
                completion()
            }
            return true
        }

        self.snapshotter = snapshotter
    }
}
