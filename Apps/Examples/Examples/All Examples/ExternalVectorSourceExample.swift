import UIKit
import MapboxMaps

@objc(ExternalVectorSourceExample)
public class ExternalVectorSourceExample: UIViewController, ExampleProtocol {
    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(with: view.bounds, resourceOptions: resourceOptions())
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.style.styleURI = .light
        let centerCoordinate = CLLocationCoordinate2D(latitude: 41.878781, longitude: -87.622088)
        mapView.cameraManager.setCamera(centerCoordinate: centerCoordinate,
                                        zoom: 12)
        view.addSubview(mapView)

        // Allow the view controller to receive information about map events.
        mapView.on(.mapLoaded) { [weak self] _ in
            guard let self = self else { return }
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

        let addSourceResult = mapView.style.addSource(source: vectorSource, identifier: sourceIdentifier)

        // Define the layer's positioning within the layer stack so
        // that it doesn't obscure other important labels.
        let layerPosition = LayerPosition(above: nil, below: "waterway-label", at: nil)
        let addLayerResult = mapView.style.addLayer(layer: lineLayer, layerPosition: layerPosition)

        if case .failure(let sourceError) = addSourceResult {
            displayAlert(message: sourceError.localizedDescription)
        }

        if case .failure(let layerError) = addLayerResult {
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
