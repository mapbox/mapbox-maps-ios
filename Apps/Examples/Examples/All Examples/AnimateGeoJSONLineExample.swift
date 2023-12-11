import UIKit
import MapboxMaps

final class AnimateGeoJSONLineExample: UIViewController, ExampleProtocol {
    private let sourceIdentifier = "route-source-identifier"
    private var mapView: MapView!
    private var routeLineSource: GeoJSONSource!
    private var currentIndex = 0
    private var cancelables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        let centerCoordinate = CLLocationCoordinate2D(latitude: 45.5076, longitude: -122.6736)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate,
                                                                  zoom: 11.0))

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Wait for the map to load its style before adding data.
        mapView.mapboxMap.onMapLoaded.observeNext { _ in

            self.addLine()
            self.animatePolyline()

            // The below line is used for internal testing purposes only.
            self.finish()
        }.store(in: &cancelables)
    }

    func addLine() {

        // Create a GeoJSON data source.
        routeLineSource = GeoJSONSource(id: sourceIdentifier)
        routeLineSource.data = .feature(Feature(geometry: LineString([allCoordinates[currentIndex]])))

        // Create a line layer
        var lineLayer = LineLayer(id: "line-layer", source: sourceIdentifier)
        lineLayer.lineColor = .constant(StyleColor(.red))

        let lowZoomWidth = 5
        let highZoomWidth = 20

        // Use an expression to define the line width at different zoom extents
        lineLayer.lineWidth = .expression(
            Exp(.interpolate) {
                Exp(.linear)
                Exp(.zoom)
                14
                lowZoomWidth
                18
                highZoomWidth
            }
        )
        lineLayer.lineCap = .constant(.round)
        lineLayer.lineJoin = .constant(.round)

        // Add the lineLayer to the map.
        try! mapView.mapboxMap.addSource(routeLineSource)
        try! mapView.mapboxMap.addLayer(lineLayer)
    }

    func animatePolyline() {
        var currentCoordinates = [CLLocationCoordinate2D]()

        // Start a timer that will add a new coordinate to the line and redraw it every time it repeats.
        Timer.scheduledTimer(withTimeInterval: 0.10, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            if self.currentIndex > self.allCoordinates.count {
                timer.invalidate()
                return
            }

            self.currentIndex += 1

            // Create a subarray of locations up to the current index.
            currentCoordinates = Array(self.allCoordinates[0..<self.currentIndex - 1])

            let updatedLine = Feature(geometry: LineString(currentCoordinates))
            self.routeLineSource.data = .feature(updatedLine)
            self.mapView.mapboxMap.updateGeoJSONSource(withId: self.sourceIdentifier,
                                                                  geoJSON: .feature(updatedLine))
        }
    }

    let allCoordinates = [
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
    ]
}
