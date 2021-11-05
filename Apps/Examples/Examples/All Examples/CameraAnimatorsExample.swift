import UIKit
import MapboxMaps

@objc(CameraAnimatorsExample)
class CameraAnimatorsExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    // Coordinate in New York City
    var newYork = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)

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
        // Declare an animator that changes the map's zoom level.
        let zoomAnimator = self.mapView.camera.makeAnimator(duration: 4, curve: .easeInOut) { (transition) in
            transition.zoom.toValue = 14
            transition.pitch.toValue = 55
            transition.bearing.toValue = -45
            transition.center.toValue = self.newYork
        }

        // Begin the pitch animation once the zoom animation has finished.
        zoomAnimator.addCompletion { _ in
            print("Animating camera pitch from 0 degrees -> 55 degrees")
            self.newYork.longitude -= 0.1
            self.zoomToBoston()
        }

        // Begin the zoom animation.
        zoomAnimator.startAnimation(afterDelay: 1)
    }

    func zoomToBoston() {
        let centerTimingParameters = UICubicTimingParameters(controlPoint1: CGPoint(x: 0.4, y: 0.0),
                                                                   controlPoint2: CGPoint(x: 0.6, y: 1.0))
        let animator = mapView.camera.makeAnimator(duration: 4, timingParameters: centerTimingParameters) { (transition) in
            transition.center.toValue = self.newYork
            transition.zoom.toValue = 16
            transition.bearing.toValue = 0
            transition.pitch.toValue = 0
        }

        animator.addCompletion { _ in
            self.newYork.longitude += 0.1
            self.startCameraAnimations()
        }
        
        animator.startAnimation(afterDelay: 1)
        
        
    }
}
