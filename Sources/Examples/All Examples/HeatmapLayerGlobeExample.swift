import UIKit
import MapboxMaps

final class HeatmapLayerGlobeExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var cancelables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Center the map over the United States.
        let centerCoordinate = CLLocationCoordinate2D(latitude: 50, longitude: -120)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 1.0), styleURI: .dark)

        // Set up map view
        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.ornaments.options.scaleBar.visibility = .hidden
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        try! self.mapView.mapboxMap.setProjection(StyleProjection(name: .globe))
        view.addSubview(mapView)

        mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
            guard let self = self else { return }
            try! self.mapView.mapboxMap.setAtmosphere(Atmosphere())
            self.addRuntimeLayers()
            self.finish()
        }.store(in: &cancelables)
    }

    func addRuntimeLayers() {
        createEarthquakeSource()
        createHeatmapLayer()
        createCircleLayer()
    }

    func createEarthquakeSource() {
        var earthquakeSource = GeoJSONSource(id: self.earthquakeSourceId)
        earthquakeSource.data = .url(self.earthquakeURL)
        earthquakeSource.generateId = true

        do {
            try mapView.mapboxMap.addSource(earthquakeSource)
        } catch {
            print("Ran into an error adding a source: \(error)")
        }
    }

    func createHeatmapLayer() {

        // Add earthquake-viz layer
        var heatmapLayer = HeatmapLayer(id: self.heatmapLayerId, source: self.earthquakeSourceId)
        heatmapLayer.maxZoom = 9.0
        heatmapLayer.sourceLayer  = self.heatmapLayerSource

        heatmapLayer.heatmapColor = .expression(
            Exp(.interpolate) {
                Exp(.linear)
                Exp(.heatmapDensity)
                0
                "rgba(33.0, 102.0, 172.0, 0.0)"
                0.2
                "rgb(102.0, 169.0, 207.0)"
                0.4
                "rgb(209.0, 229.0, 240.0)"
                0.6
                "rgb(253.0, 219.0, 199.0)"
                0.8
                "rgb(239.0, 138.0, 98.0)"
                1
                "rgb(178.0, 24.0, 43.0)"
            }
        )
        // Increase the heatmap weight based on frequency and property magnitude
        heatmapLayer.heatmapWeight = .expression(
            Exp(.interpolate) {
                Exp(.linear)
                Exp(.get) {"mag"}
                0
                0
                6
                1
            }
        )
        // Increase the heatmap color weight weight by zoom level
        // heatmap-intensity is a multiplier on top of heatmap-weight
        heatmapLayer.heatmapIntensity = .expression(
            Exp(.interpolate) {
                Exp(.linear)
                Exp(.zoom)
                0
                1
                9
                3
            }
        )
        // Adjust the heatmap radius by zoom level
        heatmapLayer.heatmapRadius = .expression(
            Exp(.interpolate) {
                Exp(.linear)
                Exp(.zoom)
                0
                2
                9
                20
            }
        )

        // Transition from heatmap to circle layer by zoom level
        heatmapLayer.heatmapOpacity = .expression(
            Exp(.interpolate) {
                Exp(.linear)
                Exp(.zoom)
                7
                1
                9
                0
            }
        )

        do {
            try mapView.mapboxMap.addLayer(heatmapLayer, layerPosition: .above("waterway-label"))
        } catch {
            print("Ran into an error adding a layer: \(error)")
        }
    }

    func createCircleLayer() {

        // Add circle layer
        var circleLayer = CircleLayer(id: self.circleLayerId, source: self.earthquakeSourceId)

        // Adjust the circle layer radius by zoom level
        circleLayer.circleRadius = .expression(
            Exp(.interpolate) {
                Exp(.linear)
                Exp(.zoom)
                7
                Exp(.interpolate) {
                    Exp(.linear)
                    Exp(.get) { "mag" }
                    1
                    1
                    6
                    4
                }
                16
                Exp(.interpolate) {
                    Exp(.linear)
                    Exp(.get) { "mag" }
                    1
                    5
                    6
                    50
                }
            }
        )

        circleLayer.circleRadiusTransition = StyleTransition(duration: 0.5, delay: 0)
        circleLayer.circleStrokeColor = .constant(StyleColor(.black))
        circleLayer.circleStrokeWidth = .constant(1)

        // Set circle layer color by mag level
        circleLayer.circleColor = .expression(
            Exp(.interpolate) {
                Exp(.linear)
                Exp(.get) { "mag" }
                1
                "rgba(33.0, 102.0, 172.0, 0.0)"
                2
                "rgb(102.0, 169.0, 207.0)"
                3
                "rgb(209.0, 229.0, 240.0)"
                4
                "rgb(253.0, 219.0, 199.0)"
                5
                "rgb(239.0, 138.0, 98.0)"
                6
                "rgb(178.0, 24.0, 43.0)"
            }
        )

        // Adjust the circle laye opacity by zoom level
        circleLayer.circleOpacity = .expression(
            Exp(.interpolate) {
                Exp(.linear)
                Exp(.zoom)
                7
                0
                8
                1
            }
        )

        circleLayer.circleStrokeColor = .constant(.init(UIColor.white))
        circleLayer.circleStrokeWidth = .constant(0.1)

        do {
            try mapView.mapboxMap.addLayer(circleLayer, layerPosition: .below(self.heatmapLayerId))
        } catch {
            print("Ran into an error adding a layer: \(error)")
        }
    }

}

private extension HeatmapLayerGlobeExample {
    var earthquakeSourceId: String { "earthquakes" }
    var earthquakeLayerId: String { "earthquake-viz" }
    var heatmapLayerId: String { "earthquakes-heat" }
    var heatmapLayerSource: String { "earthquakes" }
    var circleLayerId: String { "earthquakes-circle" }
    var earthquakeURL: URL { URL(string: "https://www.mapbox.com/mapbox-gl-js/assets/earthquakes.geojson")! }
}
