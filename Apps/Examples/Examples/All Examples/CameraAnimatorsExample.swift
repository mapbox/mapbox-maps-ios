import UIKit
import MapboxMaps

@objc(CameraAnimatorsExample)
class CameraAnimatorsExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    // Coordinate in New York City
    let newYork = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)

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
            self.startCameraAnimations()
            self.finish()
        }
    }

    // Start a chain of camera animations
    func startCameraAnimations() {
        // Declare an animator that changes the map's
        var bearingAnimator = mapView.camera.makeAnimator(duration: 4, curve: .easeInOut) { (transition) in
            transition.bearing.toValue = -45
        }
        
        bearingAnimator.addCompletion { (_) in
            print("All animations complete!")
        }

        // Declare an animator that changes the map's pitch.
        let pitchAnimator = mapView.camera.makeAnimator(duration: 2, curve: .easeInOut) { (transition) in
            transition.pitch.toValue = 55
        }

        // Begin the bearing animation once the pitch animation has finished.
        pitchAnimator.addCompletion { _ in
            print("Animating camera bearing from 0 degrees -> 45 degrees")
            bearingAnimator.startAnimation()
        }

        // Declare an animator that changes the map's zoom level.
        let zoomAnimator = self.mapView.camera.makeAnimator(duration: 4, curve: .easeInOut) { (transition) in
            transition.zoom.toValue = 14
        }

        // Begin the pitch animation once the zoom animation has finished.
        zoomAnimator.addCompletion { _ in
            print("Animating camera pitch from 0 degrees -> 55 degrees")
            pitchAnimator.startAnimation()
        }

        // Begin the zoom animation.
        zoomAnimator.startAnimation(afterDelay: 1)
    }
}
