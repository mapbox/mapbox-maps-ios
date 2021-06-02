import UIKit
import MapboxMaps

@objc(CameraAnimatorsExample)

public class CameraAnimatorsExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    // Coordinate in New York City
    let newYork = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)

    // Store the CameraAnimators so that the do not fall out of scope.
    lazy var zoomAnimator: BasicCameraAnimator = {
        let animator = mapView.camera.makeAnimator(duration: 4, curve: .easeInOut) { (transition) in
            transition.zoom.toValue = 14
        }

        animator.addCompletion { [unowned self] (_) in
            print("Animating camera pitch from 0 degrees -> 55 degrees")
            self.pitchAnimator.startAnimation()
        }

        return animator
    }()

    lazy var pitchAnimator: BasicCameraAnimator = {
        let animator = mapView.camera.makeAnimator(duration: 2, curve: .easeInOut) { (transition) in
            transition.pitch.toValue = 55
        }

        animator.addCompletion { [unowned self] (_) in
            print("Animating camera bearing from 0 degrees -> 45 degrees")
            self.bearingAnimator.startAnimation()
        }

        return animator
    }()

    lazy var bearingAnimator: BasicCameraAnimator = {
        let animator = mapView.camera.makeAnimator(duration: 4, curve: .easeInOut) { (transition) in
            transition.bearing.toValue = -45
        }

        animator.addCompletion { (_) in
            print("All animations complete!")
        }

        return animator
    }()

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.mapboxMap.onNext(.styleLoaded) { _ in
            // Center the map over New York City.
            self.mapView.mapboxMap.setCamera(to: CameraOptions(center: self.newYork))
        }

        // Allows the delegate to receive information about map events.
        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            print("Animating zoom from zoom lvl 3 -> zoom lvl 14")
            self.zoomAnimator.startAnimation(afterDelay: 1)
            self.finish()
        }
    }
}
