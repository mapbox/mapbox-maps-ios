import UIKit
import MapboxMaps

@objc(CameraAnimatorsExample)

public class CameraAnimatorsExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    // Store the CameraAnimators so that the do not fall out of scope.
    var bearingAnimator: CameraAnimator?
    var centerAnimator: CameraAnimator?
    var zoomAnimator: CameraAnimator?
    override public func viewDidLoad() {
        super.viewDidLoad()

        guard let accessToken = AccountManager.shared.accessToken else {
            fatalError("Access token not set")
        }

        let resourceOptions = ResourceOptions(accessToken: accessToken)
        mapView = MapView(with: view.bounds, resourceOptions: resourceOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.centerCoordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        mapView.zoom = 5

        // Allows the delegate to receive information about map events.
        mapView.on(.mapLoaded) { [weak self] _ in

            guard let self = self else { return }

            // Rotate the map 180º over the course of four seconds.
            self.bearingAnimator = self.mapView.cameraManager.makeCameraAnimator(duration: 4,
                                                                                    curve: .linear,
                                                                           animationOwner: .custom(id: "bearing-animator"),
                                                                               animations: {
                self.mapView.bearing = 180.0
            })
            self.bearingAnimator?.addCompletion({ _ in
                self.bearingAnimator = nil
            })
            self.bearingAnimator?.startAnimation()

            // Center the map over New York City.
            self.centerAnimator = self.mapView.cameraManager.makeCameraAnimator(duration: 4,
                                                                                curve: .linear,
                                                                                animationOwner: .custom(id: "center-animator"),
                                                                                animations: {
                self.mapView.centerCoordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
            })
            self.centerAnimator?.addCompletion({ _ in
                self.centerAnimator = nil
            })
            // Start the animation after a one second delay.
            self.centerAnimator?.startAnimation(afterDelay: 1)

            // Zoom in to zoom level 10 after a two second delay.
            self.zoomAnimator = self.mapView.cameraManager.makeCameraAnimator(duration: 3,
                                                                                 curve: .linear,
                                                                        animationOwner: .custom(id: "zoom-animator"), animations: {
                self.mapView.zoom = 10.0
            })
            self.zoomAnimator?.addCompletion({ _ in
                self.zoomAnimator = nil
            })
            self.zoomAnimator?.startAnimation(afterDelay: 2)

            // For internal testing purposes only.
            self.finish()

        }
    }
}
