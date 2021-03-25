import UIKit
import MapboxMaps

@objc(CameraAnimatorsExample)

public class CameraAnimatorsExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    // Store the CameraAnimators so that the do not fall out of scope.
    lazy var zoomAnimator: CameraAnimator = {
        let animator = mapView.cameraManager.makeCameraAnimator(duration: 4, curve: .easeInOut) { [unowned self] in
            self.mapView.zoom = 14
        }

        animator.addCompletion { [unowned self] (_) in
//            self.pitchAnimator.startAnimation()
        }

        return animator
    }()

    lazy var pitchAnimator: CameraAnimator = {
        let animator = mapView.cameraManager.makeCameraAnimator(duration: 2, curve: .easeInOut) { [unowned self] in
            self.mapView.pitch = 55
        }

        animator.addCompletion { [unowned self] (_) in
            self.bearingAnimator.startAnimation()
        }

        return animator
    }()

    lazy var bearingAnimator: CameraAnimator = {
        let animator = mapView.cameraManager.makeCameraAnimator(duration: 4, curve: .easeInOut) { [unowned self] in
            self.mapView.bearing = -45
        }

        animator.addCompletion { (_) in
            print("All animations complete!")
        }

        return animator
    }()

    override public func viewDidLoad() {
        super.viewDidLoad()

        guard let accessToken = AccountManager.shared.accessToken else {
            fatalError("Access token not set")
        }

        let resourceOptions = ResourceOptions(accessToken: accessToken)
        mapView = MapView(with: view.bounds, resourceOptions: resourceOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Center the map over New York City.
        let newYork = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        mapView.zoom = 15
        mapView.cameraManager.setCamera(centerCoordinate: newYork, bearing: 358.0316467285156)


        // Allows the delegate to receive information about map events.
        mapView.on(.mapLoaded) { [weak self] _ in
            guard let self = self else { return }
            let cameraOptions = CameraOptions(center: newYork, bearing: CLLocationDirection(0.7362971305847168))
            self.mapView.cameraManager.setCamera(to: cameraOptions, animated: true, duration: 0.5, completion: nil)
            
            
            self.finish()
        }
    }
}
