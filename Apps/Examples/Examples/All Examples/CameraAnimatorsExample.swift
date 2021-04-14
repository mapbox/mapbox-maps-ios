import UIKit
import MapboxMaps

@objc(CameraAnimatorsExample)

public class CameraAnimatorsExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    // Store the CameraAnimators so that the do not fall out of scope.
    lazy var zoomAnimator: CameraAnimator = {
        let animator = mapView.cameraManager.makeCameraAnimator(duration: 4, curve: .easeInOut) { (camera) in
            camera.zoom = 14
        }

        animator.addCompletion { [unowned self] (_) in
//            self.pitchAnimator.startAnimation()
        }

        return animator
    }()

//    lazy var pitchAnimator: CameraAnimator = {
//        let animator = mapView.cameraManager.makeCameraAnimator(duration: 2, curve: .easeInOut) { (camera) in
//            camera.pitch = 55
//        }
//
//        animator.addCompletion { [unowned self] (_) in
//            self.bearingAnimator.startAnimation()
//        }
//
//        return animator
//    }()

//    lazy var bearingAnimator: CameraAnimator = {
//        let animator = mapView.cameraManager.makeCameraAnimator(duration: 4, curve: .easeInOut) { (camera) in
//            camera.bearing = -45
//        }
//
//        animator.addCompletion { (_) in
//            print("All animations complete!")
//        }
//
//        return animator
//    }()

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Center the map over New York City.
        let newYork = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
//        mapView.cameraManager.setCamera(to: CameraOptions(center: newYork))

        // Allows the delegate to receive information about map events.
        mapView.on(.mapLoaded) { [weak self] _ in
            guard let self = self else { return }
            
            self.mapView.cameraManager.setCamera(to: CameraOptions(center: newYork))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.zoomAnimator.startAnimation()
            }
            
            self.finish()
        }
    }
}
