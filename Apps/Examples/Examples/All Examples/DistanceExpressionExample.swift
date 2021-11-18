import MapboxMaps
import Turf

@objc(DistanceExpressionExample)
class DistanceExpressionExample: UIViewController, ExampleProtocol {
    var mapView: MapView!
    var point: Turf.Feature!

    override func viewDidLoad() {
        super.viewDidLoad()

        let center = CLLocationCoordinate2D(latitude: 37.787945, longitude: -122.407522)
        let cameraOptions = CameraOptions(center: center, zoom: 16)
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions, styleURI: .streets)
        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(mapView)

        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            self.addCircleLayer()
        }
    }

    func addCircleLayer() {
        let style = mapView.mapboxMap.style
        let center = mapView.mapboxMap.cameraState.center

        // Create a `GeoJSONSource` from a Turf geometry.
        var source = GeoJSONSource()
        point = Feature(geometry: .point(Point(center)))

        // Filter out POI labels that are more than 150 meters from the point.
        self.filterPoiLabels()

        // Set the source's data property to the feature.
        source.data = .feature(point)

        // Create a `CircleLayer` from the previously defined source. The source ID
        // will be set for the source once it is added to the map's style.
        var circleLayer = CircleLayer(id: "circle-layer")
        circleLayer.source = "source-id"

        // This expression simulates a `CircleLayer` with a radius of 150 meters. For features that will be
        // visible at lower zoom levels, add more stops at the zoom levels where the feature will be more
        // visible. This keeps the circle's radius more consistent.
        let circleRadiusExp = Exp(.interpolate) {
            Exp(.linear)
            Exp(.zoom)
            0
            circleRadius(forZoom: 0)
            5
            circleRadius(forZoom: 5)
            10
            circleRadius(forZoom: 10)
            15
            circleRadius(forZoom: 15)
            16
            circleRadius(forZoom: 16)
            16.5
            circleRadius(forZoom: 16.5)
            17
            circleRadius(forZoom: 17)
            17.5
            circleRadius(forZoom: 17.5)
            18
            circleRadius(forZoom: 18)
            18.5
            circleRadius(forZoom: 18.5)
            19
            circleRadius(forZoom: 19)
            19.5
            circleRadius(forZoom: 19.5)
            20
            circleRadius(forZoom: 20)
            20.5
            circleRadius(forZoom: 20.5)
            21
            circleRadius(forZoom: 21)
            21.5
            circleRadius(forZoom: 21.5)
            22
            circleRadius(forZoom: 22)
        }
        circleLayer.circleRadius = .expression(circleRadiusExp)
        circleLayer.circleOpacity = .constant(0.3)

        // Add the source and layer to the map's style.
        try! style.addSource(source, id: "source-id")
        try! style.addLayer(circleLayer)
    }

    func filterPoiLabels() {
        let style = mapView.mapboxMap.style

        do {
            // Update the `SymbolLayer` with id "poi-label". This layer is included in the Mapbox
            // Streets v11 style. In order to see all layers included with your style, either inspect
            // the style in Mapbox Studio or inspect the `style.allLayerIdentifiers` property once
            // the style has finished loading.
            try style.updateLayer(withId: "poi-label", type: SymbolLayer.self) { (layer: inout SymbolLayer) throws in
                // Filter the "poi-label" layer to only show points less than 150 meters away from the
                // the specified feature.
                layer.filter = Exp(.lt) {
                    Exp(.distance) {
                        // Specify the feature that will be used as an anchor for the distance check.
                        // This feature should be a `GeoJSONObject`.
                        GeoJSONObject.feature(point)
                    }
                    // Specify the distance in meters that you would like to limit visible POIs to.
                    // Note that this checks the distance of the feature itself.
                    150
                }
            }
        } catch {
            print("Updating the layer failed: \(error.localizedDescription)")
        }

    }

    func circleRadius(forZoom zoom: CGFloat) -> Double {
        let centerLatitude = mapView.cameraState.center.latitude

        // Get the meters per pixel at a given latitude and zoom level.
        let metersPerPoint = Projection.metersPerPoint(for: centerLatitude, zoom: zoom)

        // We want to have a circle radius of 150 meters. Calculate how many
        // pixels that radius needs to be.
        let radius = 150 / metersPerPoint
        return radius
    }
}
