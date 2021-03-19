import UIKit
import MapboxMaps

@objc(CameraAnimationExample2)

public class CameraUIViewAnimationExample: UIViewController, ExampleProtocol {

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

        mapView.cameraView.centerCoordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        mapView.cameraView.zoom = 5

        // Allows the delegate to receive information about map events.
        mapView.on(.mapLoaded) { [weak self] _ in

            guard let self = self else { return }

            // The following dispatch group is used to coordinate the completion of
            // this example. This is useful in the case where the durations and delays
            // are changed.
            let group = DispatchGroup()
            group.enter()
            group.enter()
            group.enter()

            // Center the map camera over New York City.
            UIView.animate(withDuration: 4.0, delay: 2.0, options: [.beginFromCurrentState, .allowUserInteraction, .curveLinear]) {
                self.mapView.cameraView.bearing = 180.0
            } completion: { _ in
                group.leave()
            }

            UIView.animate(withDuration: 4.0, delay: 1.0, options: [.beginFromCurrentState, .allowUserInteraction, .curveLinear]) {
                self.mapView.cameraView.centerCoordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
            } completion: { _ in
                group.leave()
            }

            UIView.animate(withDuration: 4.0, delay: 3.0, options: [.beginFromCurrentState, .allowUserInteraction, .curveLinear]) {
                self.mapView.cameraView.zoom = 10.0
            } completion: { _ in
                group.leave()
            }

            // Wait until all animations are complete before finishing
            group.notify(queue: DispatchQueue.main) {
                self.finish()
            }
        }
    }
}
