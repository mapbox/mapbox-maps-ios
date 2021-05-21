import UIKit
import MapboxMaps
import Turf

@objc(UpdatePointAnnotationPositionExample)

public class UpdatePointAnnotationPositionExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!
    internal var pointAnnotation: PointAnnotation_Legacy!

    override public func viewDidLoad() {
        super.viewDidLoad()

        let camera = CameraOptions(center: CLLocationCoordinate2D(latitude: 59.3, longitude: 8.06),
                                   zoom: 12)
        let options = MapInitOptions(cameraOptions: camera)

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Allows the view controller to receive information about map events.
        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            self.addPointAnnotation()
            // The below line is used for internal testing purposes only.
            self.finish()
        }

    }

    public func addPointAnnotation() {
        pointAnnotation = PointAnnotation_Legacy(coordinate: mapView.cameraState.center)
        mapView.annotations.addAnnotation(pointAnnotation)
        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(updatePosition)))
    }

    @objc public func updatePosition(_ sender: UITapGestureRecognizer) {
        let newCoordinate = mapView.mapboxMap.coordinate(for: sender.location(in: mapView))
        pointAnnotation.coordinate = newCoordinate

        do {
            try mapView.annotations.updateAnnotation(pointAnnotation)
        } catch let error {
            displayAlert(message: error.localizedDescription)
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
