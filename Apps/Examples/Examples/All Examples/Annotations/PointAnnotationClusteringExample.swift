import UIKit
import MapboxMaps

@objc(PointAnnotationClusteringExample)
class PointAnnotationClusteringExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Create a `MapView` centered over Washington, DC.
        let center = CLLocationCoordinate2D(latitude: 38.889215, longitude: -77.039354)
        let cameraOptions = CameraOptions(center: center, zoom: 11)
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions, styleURI: .light)
        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(mapView)

        // Add the source and style layers once the map has loaded.
        mapView.mapboxMap.onNext(event: .mapLoaded) { _ in
            self.addSymbolClusteringLayers()
        }

//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
//        mapView.addGestureRecognizer(tapGestureRecognizer)
    }

    func addSymbolClusteringLayers() {
        let style = mapView.mapboxMap.style
        // The image named `fire-station-11` is included in the app's Assets.xcassets bundle.
        // In order to recolor an image, you need to add a template image to the map's style.
        // The image's rendering mode can be set programmatically or in the asset catalogue.
        let image = UIImage(named: "fire-station-11")!.withRenderingMode(.alwaysTemplate)

        // Add the image tp the map's style. Set `sdf` to `true`. This allows the icon images to be recolored.
        // For more information about `SDF`, or Signed Distance Fields, see
        // https://docs.mapbox.com/help/troubleshooting/using-recolorable-images-in-mapbox-maps/#what-are-signed-distance-fields-sdf
        try! style.addImage(image, id: "fire-station-icon", sdf: true)

        // Fire_Hydrants.geojson contains information about fire hydrants in the District of Columbia.
        // It was downloaded on 6/10/21 from https://opendata.dc.gov/datasets/DCGIS::fire-hydrants/about
        let url = Bundle.main.url(forResource: "Fire_Hydrants", withExtension: "geojson")!

        // Create a GeoJSONSource using the previously specified URL.
        var source = GeoJSONSource()
        source.data = .url(url)

        // Enable clustering for this source.
        source.cluster = true
        source.clusterRadius = 75
        let sourceID = "fire-hydrant-source"

        let clusterOptions = ClusterOptions(sourceID: sourceID, clusterRadius: .constant(75), circleRadius: .constant(18), colorLevels: [(100, StyleColor(.red)), (50, StyleColor(.blue)), (0, StyleColor(.green))])

        try! style.addSource(source, id: sourceID)
        let pointAnnotationManager = mapView.annotations.makePointAnnotationManager(clusterOptions: clusterOptions)

        finish()
    }

    // Present an alert with a given title and message.
    func showAlert(withTitle title: String, and message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
}
