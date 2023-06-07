import UIKit
import MapboxMaps

public class FitCameraToGeometryExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!
    private var cancelables = Set<AnyCancelable>()

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Allows the view controller to receive information about map events.
        mapView.mapboxMap.onMapLoaded.observeNext { _ in
            self.fitToCameraToGeometry()
        }.store(in: &cancelables)

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

        var source = GeoJSONSource(id: "triangle-source")
        source.data = .feature(polygonFeature)

        var polygonLayer = FillLayer(id: "triangle-style")
        polygonLayer.fillOpacity = .constant(0.5)
        polygonLayer.fillColor = .constant(StyleColor(.gray))
        polygonLayer.source = source.id

        do {
            try mapView.mapboxMap.addSource(source)
        } catch {
            displayAlert(message: error.localizedDescription)
        }

        do {
            try mapView.mapboxMap.addLayer(polygonLayer, layerPosition: nil)
        } catch {
            displayAlert(message: error.localizedDescription)
        }

        let newCamera = mapView.mapboxMap.camera(for: polygon, padding: .zero, bearing: 0, pitch: 0)
        mapView.mapboxMap.setCamera(to: newCamera)
        // The below line is used for internal testing purposes only.
        self.finish()
    }

    fileprivate func displayAlert(message: String) {
        let alertController = UIAlertController(title: "Error:",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
