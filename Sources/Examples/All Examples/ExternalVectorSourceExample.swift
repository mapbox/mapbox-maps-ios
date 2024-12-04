import UIKit
import MapboxMaps

final class ExternalVectorSourceExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var cancelables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        let centerCoordinate = CLLocationCoordinate2D(latitude: 41.878781, longitude: -87.622088)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 12.0),
                                     styleURI: .light)

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Allow the view controller to receive information about map events.
        mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
            self?.drawLineLayer()
            // The following line is just for testing purposes.
            self?.finish()
        }.store(in: &cancelables)
    }

    func drawLineLayer() {
        var vectorSource = VectorSource(id: "mapillary")

        // For sources using the {z}/{x}/{y} URL scheme, use the `tiles`
        // property on `VectorSource` to set the URL.
        vectorSource.tiles = ["https://tiles.mapillary.com/maps/vtp/mly1_public/2/{z}/{x}/{y}?access_token=MLY%7C4142433049200173%7C72206abe5035850d6743b23a49c41333"]
        vectorSource.minzoom = 6
        vectorSource.maxzoom = 14

        var lineLayer = LineLayer(id: "line-layer", source: vectorSource.id)
        lineLayer.sourceLayer = "sequence"
        let lineColor = StyleColor(UIColor(red: 0.21, green: 0.69, blue: 0.43, alpha: 1.00))
        lineLayer.lineColor = .constant(lineColor)
        lineLayer.lineOpacity = .constant(0.6)
        lineLayer.lineWidth = .constant(2.0)
        lineLayer.lineCap = .constant(.round)

        do {
            try mapView.mapboxMap.addSource(vectorSource)
        } catch {
            showAlert(with: error.localizedDescription)
        }

        // Define the layer's positioning within the layer stack so
        // that it doesn't obscure other important labels.
        do {
            try mapView.mapboxMap.addLayer(lineLayer, layerPosition: .below("waterway-label"))
        } catch let layerError {
            showAlert(with: layerError.localizedDescription)
        }
    }
}
