import UIKit
import MapboxMaps

// swiftlint:disable:next type_body_length
final class NavigationSimulatorExample: UIViewController, ExampleProtocol {
    private enum ID {
        static let routeSource = "route-line-source-id"
        static let routeLineLayer = "route-line-layer-id"
        static let casingLineLayer = "route-casing-layer-id"
    }

    private var mapView: MapView!
    private var navigationSimulator: NavigationSimulator!

    private lazy var routeSource: Source = {
        var source = GeoJSONSource()
        source.data = .geometry(Geometry(sampleRouteLine))
        source.lineMetrics = true

        return source
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        configureMap()

        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            mapView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
        ])
    }

    private func configureMap() {
        navigationSimulator = NavigationSimulator(mapView: mapView, route: sampleRouteLine)

        mapView.location.options.puckType = .puck2D(.makeDefault(showBearing: true))
        mapView.location.options.puckBearingSource = .course
        mapView.location.overrideLocationProvider(with: navigationSimulator)
        mapView.location.addLocationConsumer(newConsumer: self)

        mapView.mapboxMap.onNext(.mapLoaded) { [weak self] _ in
            guard let self = self else { return }
            do {
                try self.mapView.mapboxMap.style.addSource(self.routeSource, id: "route-line-source-id")
                try self.mapView.mapboxMap.style.addLayer(self.makeCasingLayer())
                try self.mapView.mapboxMap.style.addLayer(self.makeRouteLineLayer())

                self.navigationSimulator.start()
            } catch {
                print("Unexpected error when adding source/style: \(error)")
            }

            // The below line is used for internal testing purposes only.
            self.finish()
        }
    }

    // MARK: - Util

    private func makeRouteLineLayer() -> LineLayer {
        var routeLayer = LineLayer(id: ID.routeLineLayer)
        routeLayer.source = ID.routeSource
        routeLayer.lineCap = .constant(.round)
        routeLayer.lineJoin = .constant(.round)
        routeLayer.lineWidth = .expression(
            Exp(.interpolate) {
                Exp(.exponential) {
                    1.5
                }
                Exp(.zoom)
                4.0
                Exp(.product) {
                    3.0
                    1.0
                }
                10.0
                Exp(.product) {
                    4.0
                    1.0
                }
                13.0
                Exp(.product) {
                    6.0
                    1.0
                }
                16.0
                Exp(.product) {
                    10.0
                    1.0
                }
                19.0
                Exp(.product) {
                    14.0
                    1.0
                }
                22.0
                Exp(.product) {
                    18.0
                    1.0
                }
            }
        )
        routeLayer.lineGradient = .expression(
            Exp(.interpolate) {
                Exp(.linear)
                Exp(.lineProgress)
                0.0
                UIColor(red: 6.0/255.0, green: 1.0/255.0, blue: 255.0/255.0, alpha: 1)
                0.1
                UIColor(red: 59.0/255.0, green: 118.0/255.0, blue: 227.0/255.0, alpha: 1)
                0.3
                UIColor(red: 7.0/255.0, green: 238.0/255.0, blue: 251.0/255.0, alpha: 1)
                0.5
                UIColor(red: 0, green: 255.0/255.0, blue: 42.0/255.0, alpha: 1)
                0.7
                UIColor(red: 255.0/255.0, green: 252.0/255.0, blue: 0, alpha: 1)
                1.0
                UIColor(red: 255.0/255.0, green: 30.0/255.0, blue: 0, alpha: 1)
            }
        )

        return routeLayer
    }

    private func makeCasingLayer() -> LineLayer {
        var casingLayer = LineLayer(id: ID.casingLineLayer)
        casingLayer.source = ID.routeSource
        casingLayer.lineCap = .constant(.round)
        casingLayer.lineJoin = .constant(.round)

        casingLayer.lineWidth = .expression(
            Exp(.interpolate) {
                Exp(.exponential) {
                    1.5
                }
                Exp(.zoom)
                10.0
                Exp(.product) {
                    7.0
                    1.0
                }
                14.0
                Exp(.product) {
                    10.5
                    1.0
                }
                16.5
                Exp(.product) {
                    15.5
                    1.0
                }
                19.0
                Exp(.product) {
                    24.0
                    1.0
                }
                22.0
                Exp(.product) {
                    29.0
                    1.0
                }
            }
        )
        casingLayer.lineGradient = .expression(
            Exp(.interpolate) {
                Exp(.linear)
                Exp(.lineProgress)
                0.0
                UIColor(red: 47.0/255.0, green: 122.0/255.0, blue: 198.0/255.0, alpha: 1)
                1.0
                UIColor(red: 47.0/255.0, green: 122.0/255.0, blue: 198.0/255.0, alpha: 1)
            }
        )

        return casingLayer
    }

    // MARK: Sample Data

    private let sampleRouteLine = LineString([
        CLLocationCoordinate2D(latitude: 45.52214, longitude: -122.63748),
        CLLocationCoordinate2D(latitude: 45.52218, longitude: -122.64855),
        CLLocationCoordinate2D(latitude: 45.52219, longitude: -122.6545),
        CLLocationCoordinate2D(latitude: 45.52196, longitude: -122.65497),
        CLLocationCoordinate2D(latitude: 45.52104, longitude: -122.65631),
        CLLocationCoordinate2D(latitude: 45.51935, longitude: -122.6578),
        CLLocationCoordinate2D(latitude: 45.51848, longitude: -122.65867),
        CLLocationCoordinate2D(latitude: 45.51293, longitude: -122.65872),
        CLLocationCoordinate2D(latitude: 45.51295, longitude: -122.66576),
        CLLocationCoordinate2D(latitude: 45.51252, longitude: -122.66745),
        CLLocationCoordinate2D(latitude: 45.51244, longitude: -122.66813),
        CLLocationCoordinate2D(latitude: 45.51385, longitude: -122.67359),
        CLLocationCoordinate2D(latitude: 45.51406, longitude: -122.67415),
        CLLocationCoordinate2D(latitude: 45.51484, longitude: -122.67481),
        CLLocationCoordinate2D(latitude: 45.51532, longitude: -122.676),
        CLLocationCoordinate2D(latitude: 45.51668, longitude: -122.68106),
        CLLocationCoordinate2D(latitude: 45.50934, longitude: -122.68503),
        CLLocationCoordinate2D(latitude: 45.50858, longitude: -122.68546),
        CLLocationCoordinate2D(latitude: 45.50783, longitude: -122.6852),
        CLLocationCoordinate2D(latitude: 45.50714, longitude: -122.68424),
        CLLocationCoordinate2D(latitude: 45.50585, longitude: -122.68433),
        CLLocationCoordinate2D(latitude: 45.50521, longitude: -122.68429),
        CLLocationCoordinate2D(latitude: 45.50445, longitude: -122.68456),
        CLLocationCoordinate2D(latitude: 45.50371, longitude: -122.68538),
        CLLocationCoordinate2D(latitude: 45.50311, longitude: -122.68653),
        CLLocationCoordinate2D(latitude: 45.50292, longitude: -122.68731),
        CLLocationCoordinate2D(latitude: 45.50253, longitude: -122.68742),
        CLLocationCoordinate2D(latitude: 45.50239, longitude: -122.6867),
        CLLocationCoordinate2D(latitude: 45.5026, longitude: -122.68545),
        CLLocationCoordinate2D(latitude: 45.50294, longitude: -122.68407),
        CLLocationCoordinate2D(latitude: 45.50271, longitude: -122.68357),
        CLLocationCoordinate2D(latitude: 45.50055, longitude: -122.68236),
        CLLocationCoordinate2D(latitude: 45.49994, longitude: -122.68233),
        CLLocationCoordinate2D(latitude: 45.49955, longitude: -122.68267),
        CLLocationCoordinate2D(latitude: 45.49919, longitude: -122.68257),
        CLLocationCoordinate2D(latitude: 45.49842, longitude: -122.68376),
        CLLocationCoordinate2D(latitude: 45.49821, longitude: -122.68428),
        CLLocationCoordinate2D(latitude: 45.49798, longitude: -122.68573),
        CLLocationCoordinate2D(latitude: 45.49805, longitude: -122.68923),
        CLLocationCoordinate2D(latitude: 45.49857, longitude: -122.68926),
        CLLocationCoordinate2D(latitude: 45.49911, longitude: -122.68814),
        CLLocationCoordinate2D(latitude: 45.49921, longitude: -122.68865),
        CLLocationCoordinate2D(latitude: 45.49905, longitude: -122.6897),
        CLLocationCoordinate2D(latitude: 45.49917, longitude: -122.69346),
        CLLocationCoordinate2D(latitude: 45.49902, longitude: -122.69404),
        CLLocationCoordinate2D(latitude: 45.49796, longitude: -122.69438),
        CLLocationCoordinate2D(latitude: 45.49697, longitude: -122.69504),
        CLLocationCoordinate2D(latitude: 45.49661, longitude: -122.69624),
        CLLocationCoordinate2D(latitude: 45.4955, longitude: -122.69781),
        CLLocationCoordinate2D(latitude: 45.49517, longitude: -122.69803),
        CLLocationCoordinate2D(latitude: 45.49508, longitude: -122.69711),
        CLLocationCoordinate2D(latitude: 45.4948, longitude: -122.69688),
        CLLocationCoordinate2D(latitude: 45.49368, longitude: -122.69744),
        CLLocationCoordinate2D(latitude: 45.49311, longitude: -122.69702),
        CLLocationCoordinate2D(latitude: 45.49294, longitude: -122.69665),
        CLLocationCoordinate2D(latitude: 45.49212, longitude: -122.69788),
        CLLocationCoordinate2D(latitude: 45.49264, longitude: -122.69771),
        CLLocationCoordinate2D(latitude: 45.49332, longitude: -122.69835),
        CLLocationCoordinate2D(latitude: 45.49334, longitude: -122.7007),
        CLLocationCoordinate2D(latitude: 45.49358, longitude: -122.70167),
        CLLocationCoordinate2D(latitude: 45.49401, longitude: -122.70215),
        CLLocationCoordinate2D(latitude: 45.49439, longitude: -122.70229),
        CLLocationCoordinate2D(latitude: 45.49566, longitude: -122.70185),
        CLLocationCoordinate2D(latitude: 45.49635, longitude: -122.70215),
        CLLocationCoordinate2D(latitude: 45.49674, longitude: -122.70346),
        CLLocationCoordinate2D(latitude: 45.49758, longitude: -122.70517),
        CLLocationCoordinate2D(latitude: 45.49736, longitude: -122.70614),
        CLLocationCoordinate2D(latitude: 45.49736, longitude: -122.70663),
        CLLocationCoordinate2D(latitude: 45.49767, longitude: -122.70807),
        CLLocationCoordinate2D(latitude: 45.49798, longitude: -122.70807),
        CLLocationCoordinate2D(latitude: 45.49798, longitude: -122.70717),
        CLLocationCoordinate2D(latitude: 45.4984, longitude: -122.70713),
        CLLocationCoordinate2D(latitude: 45.49893, longitude: -122.70774)
    ])
}

extension NavigationSimulatorExample: LocationConsumer {

    func locationUpdate(newLocation: Location) {
        let style = mapView.mapboxMap.style
        let progress = navigationSimulator.distanceTravelled / navigationSimulator.routeLength

        let trimLineLayer: (inout LineLayer) -> Void = { layer in
            layer.lineTrimOffset = .constant([0, progress])
        }
        try? style.updateLayer(withId: ID.routeLineLayer, type: LineLayer.self, update: trimLineLayer)
        try? style.updateLayer(withId: ID.casingLineLayer, type: LineLayer.self, update: trimLineLayer)
    }
}
