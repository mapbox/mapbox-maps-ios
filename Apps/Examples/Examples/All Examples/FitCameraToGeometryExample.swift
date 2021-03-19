import UIKit
import MapboxMaps
import Turf

@objc(FitCameraToGeometryExample)

public class FitCameraToGeometryExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        guard let accessToken = AccountManager.shared.accessToken else {
            fatalError("Access token not set")
        }

        let resourceOptions = ResourceOptions(accessToken: accessToken)
        mapView = MapView(with: view.bounds, resourceOptions: resourceOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Allows the view controller to receive information about map events.
        mapView.on(.mapLoaded) { [weak self] _ in
            guard let self = self else { return }
            self.fitToCameraToGeometry()
        }

    }

    public func fitToCameraToGeometry() {
        let triangleCoordinates = [
            CLLocationCoordinate2DMake(43.274580742195845, -2.938070297241211),
            CLLocationCoordinate2DMake(43.258768377941465, -2.9680252075195312),
            CLLocationCoordinate2DMake(43.24063848114794, -2.912750244140625),
            CLLocationCoordinate2DMake(43.274580742195845, -2.938070297241211)
        ]

        let polygon = Geometry.polygon(Polygon([triangleCoordinates]))
        let polygonFeature = Feature(geometry: polygon)

        let sourceIdentifier = "triangle-source"
        var source = GeoJSONSource()
        source.data = .feature(polygonFeature)

        var polygonLayer = FillLayer(id: "triangle-style")
        polygonLayer.paint?.fillOpacity = .constant(0.5)
        polygonLayer.paint?.fillColor = .constant(ColorRepresentable(color: .gray))
        polygonLayer.source = sourceIdentifier

        let addSourceResult = mapView.style?.addSource(source: source, identifier: sourceIdentifier)
        let addLayerResult = mapView.style?.addLayer(layer: polygonLayer, layerPosition: nil)

        if case .failure(let sourceError) = addSourceResult {
            displayAlert(message: sourceError.localizedDescription)
        }

        if case .failure(let layerError) = addLayerResult {
            displayAlert(message: layerError.localizedDescription)
        }

        let newCamera = mapView.cameraManager.camera(fitting: polygon)
        mapView.cameraManager.setCamera(to: newCamera) { _ in
            // The below line is used for internal testing purposes only.
            self.finish()
        }
    }

    fileprivate func displayAlert(message: String) {
        let alertController = UIAlertController(title: "Error:",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
