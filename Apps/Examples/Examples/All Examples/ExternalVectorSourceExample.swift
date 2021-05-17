import UIKit
import MapboxMaps

@objc(ExternalVectorSourceExample)
public class ExternalVectorSourceExample: UIViewController, ExampleProtocol {
    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        let centerCoordinate = CLLocationCoordinate2D(latitude: 41.878781, longitude: -87.622088)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 12.0),
                                     styleURI: .light)

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Allow the view controller to receive information about map events.
        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            self.drawLineLayer()
        }
    }

    public func drawLineLayer() {

        let sourceIdentifier = "data-source"

        var vectorSource = VectorSource()

        // For sources using the {z}/{x}/{y} URL scheme, use the `tiles`
        // property on `VectorSource` to set the URL.
        vectorSource.tiles = ["https://d25uarhxywzl1j.cloudfront.net/v0.1/{z}/{x}/{y}.mvt"]
        vectorSource.minzoom = 6
        vectorSource.maxzoom = 14

        var lineLayer = LineLayer(id: "line-layer")
        lineLayer.source = sourceIdentifier
        lineLayer.sourceLayer = "mapillary-sequences"
        let lineColor = ColorRepresentable(color: UIColor(red: 0.21, green: 0.69, blue: 0.43, alpha: 1.00))
        lineLayer.paint?.lineColor = .constant(lineColor)
        lineLayer.paint?.lineOpacity = .constant(0.6)
        lineLayer.paint?.lineWidth = .constant(2.0)
        lineLayer.layout?.lineCap = .constant(.round)

        do {
            try mapView.mapboxMap.style.addSource(vectorSource, id: sourceIdentifier)
        } catch {
            displayAlert(message: error.localizedDescription)
        }

        // Define the layer's positioning within the layer stack so
        // that it doesn't obscure other important labels.
        do {
            try mapView.style.addLayer(lineLayer, layerPosition: .below("waterway-label"))
        } catch let layerError {
            displayAlert(message: layerError.localizedDescription)
        }
    }

    public func displayAlert(message: String) {
        let alertController = UIAlertController(title: "An error occurred",
                                                message: message,
                                                preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }
}
