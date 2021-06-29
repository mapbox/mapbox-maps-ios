import MapboxMaps
import Turf

@objc(DistanceExpressionExample)
class DistanceExpressionExample: UIViewController, ExampleProtocol {
    var mapView: MapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let center = CLLocationCoordinate2D(latitude: 37.787945, longitude: -122.407522)
        let cameraOptions = CameraOptions(center: center, zoom: 16)
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions, styleURI: .streets)
        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(mapView)

        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            self.addCircle()
        }
    }

    func addCircle() {
        let style = mapView.mapboxMap.style
        let center = mapView.mapboxMap.cameraState.center
        var source = GeoJSONSource()
        let point = Turf.Point(center)
        source.data = .feature(point)
        var circle = CircleLayer(id: "circle-layer")
        circle.source = "source-id"
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

        circle.circleRadius = .expression(circleRadiusExp)
        circle.circleOpacity = .constant(0.3)
        try! style.addSource(source, id: "source-id")
        try! style.addLayer(circle)
        
        let data = JSONEncoder().encode(point.self)
        var poiLabelLayer: SymbolLayer = try! style.layer(withId: "poi-label")
        poiLabelLayer.filter = Exp(.distance) {
        }
    }

    func circleRadius(forZoom zoom: CGFloat) -> Double {
        let centerLatitude = mapView.cameraState.center.latitude
        let metersPerPoint = Projection.metersPerPoint(for: centerLatitude, zoom: zoom)
        let radius = 150 / metersPerPoint
        return radius
    }
}
