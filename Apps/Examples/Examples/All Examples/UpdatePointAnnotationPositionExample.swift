import UIKit
import MapboxMaps
import Turf

@objc(UpdatePointAnnotationPositionExample)

public class UpdatePointAnnotationPositionExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!
    internal var pointAnnotation: PointAnnotation!

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.cameraManager.setCamera(to: CameraOptions(center: CLLocationCoordinate2D(latitude: 59.3, longitude: 8.06),
                                                          zoom: 12))
        view.addSubview(mapView)

        // Allows the view controller to receive information about map events.
        mapView.on(.mapLoaded) { [weak self] _ in
            guard let self = self else { return }
            self.addPointAnnotation()
            // The below line is used for internal testing purposes only.
            self.finish()
        }

    }

    public func addPointAnnotation() {
        pointAnnotation = PointAnnotation(coordinate: mapView.centerCoordinate)
        mapView.annotationManager.addAnnotation(pointAnnotation)
        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(updatePosition)))
    }

    @objc public func updatePosition(_ sender: UITapGestureRecognizer) {
        let newCoordinate = mapView.coordinate(for: sender.location(in: mapView))
        pointAnnotation.coordinate = newCoordinate

        do {
            try mapView.annotationManager.updateAnnotation(pointAnnotation)
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
