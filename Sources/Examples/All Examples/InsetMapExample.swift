// Add a main map and a small inset map that does not respond to gestures
// the inset map updates its center when the main map is moved
// the inset map displays a polygon based on the current viewport of the main map
import UIKit
import MapboxMaps

@objc(InsetMapExample)
final class InsetMapExample: UIViewController, ExampleProtocol {
    static let styleUri = StyleURI(rawValue: "mapbox://styles/mapbox/cj5l80zrp29942rmtg0zctjto")!

    // create MapViews for the main map and the inset map
    private var mapView: MapView!
    private var insetMapView: MapView!
    private var cancelables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        // set up the main map
        let cameraCenter = CLLocationCoordinate2D(latitude: 39.13954, longitude: -77.25637)
        let initOptions = MapInitOptions(
            cameraOptions: CameraOptions(center: cameraCenter, zoom: 6.52),
            styleURI: Self.styleUri
        )
        mapView = MapView(frame: view.bounds, mapInitOptions: initOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.gestures.options.rotateEnabled = false

        view.addSubview(mapView)

        mapView.mapboxMap.onCameraChanged.observe { [weak self] event in
            self?.updateInsetMap(center: event.cameraState.center)
        }.store(in: &cancelables)

        setupInsetMapView()
    }

    private func setupInsetMapView() {
        let myInsetMapInitOptions = MapInitOptions(cameraOptions: CameraOptions(zoom: 0), styleURI: Self.styleUri )

        // position the inset map in the bottom left corner
        insetMapView = MapView(
            frame: CGRect(x: 8, y: (view.frame.size.height - 250), width: 120, height: 120),
            mapInitOptions: myInsetMapInitOptions
        )

        // hide the scaleBar, logo, and attribution on the inset map
        insetMapView.ornaments.options.scaleBar.visibility = .hidden
        insetMapView.ornaments.logoView.isHidden = true
        insetMapView.ornaments.attributionButton.isHidden = true

        // disable panning and zooming on the inset map
        insetMapView.gestures.options.panEnabled = false
        insetMapView.gestures.options.doubleTapToZoomInEnabled = false
        insetMapView.gestures.options.doubleTouchToZoomOutEnabled = false

        // add a border, radius, and shadow around the inset map
        insetMapView.layer.borderWidth = 2
        insetMapView.layer.cornerRadius = 10
        insetMapView.layer.borderColor = UIColor.gray.cgColor
        insetMapView.layer.shadowColor = UIColor.black.cgColor
        insetMapView.layer.shadowOffset = CGSize(width: 3, height: 3)
        insetMapView.layer.shadowOpacity = 0.7
        insetMapView.layer.shadowRadius = 4.0
        insetMapView.layer.masksToBounds = true

        view.addSubview(insetMapView)

        // when the inset map loads, add a source and layer to show the bounds rectangle for the main map
        insetMapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
            guard let self else { return }

            let geoJSONSource = GeoJSONSource(id: "bounds")

            // Create a line layer
            var lineBoundsLayer = LineLayer(id: "line-bounds", source: geoJSONSource.id)
            lineBoundsLayer.lineWidth = .constant(2.5)
            lineBoundsLayer.lineColor = .constant(StyleColor(#colorLiteral(red: 1, green: 0.99608, blue: 0.11373, alpha: 1)))

            // Add the source and layers to the map style
            try! self.insetMapView.mapboxMap.addSource(geoJSONSource)
            try! self.insetMapView.mapboxMap.addLayer(lineBoundsLayer)

            self.updateInsetMap(center: self.mapView.mapboxMap.cameraState.center)
        }.store(in: &cancelables)

    }

    private func updateInsetMap(center: CLLocationCoordinate2D) {
        // set the inset map's center to the main map's center
        insetMapView.mapboxMap.setCamera(to: CameraOptions(center: center))

        // get the main map's bounds
        let bounds = mapView.mapboxMap.coordinateBounds(for: mapView.bounds)

        // create a geojson polygon based on the main map's bounds
        // use it to update the "bounds" source in the inset map
        let polygon = Polygon(
            outerRing: Ring(
                coordinates: [
                    CLLocationCoordinate2D(latitude: bounds.south, longitude: bounds.west),
                    CLLocationCoordinate2D(latitude: bounds.north, longitude: bounds.west),
                    CLLocationCoordinate2D(latitude: bounds.north, longitude: bounds.east),
                    CLLocationCoordinate2D(latitude: bounds.south, longitude: bounds.east),
                    CLLocationCoordinate2D(latitude: bounds.south, longitude: bounds.west)
                ]
            )
        )

        insetMapView.mapboxMap.updateGeoJSONSource(withId: "bounds", geoJSON: polygon.geometry.geoJSONObject)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The below line is used for internal testing purposes only.
        finish()
    }
}
