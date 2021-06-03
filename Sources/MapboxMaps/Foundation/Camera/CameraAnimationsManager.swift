import UIKit
import Turf
@_implementationOnly import MapboxCommon_Private

public protocol CameraAnimator: Cancelable {

    /// Stops the animation in its tracks and calls any provided completion
    func stopAnimation()

    /// The current state of the animation
    var state: UIViewAnimatingState { get }
}

/// Internal-facing protocol to represent camera animators
internal protocol CameraAnimatorInterface: CameraAnimator {
    var currentCameraOptions: CameraOptions? { get }
}

/// An object that manages a camera's view lifecycle.
public class CameraAnimationsManager {

    /// Used to set up camera specific configuration
    public var options: CameraBoundsOptions {
        didSet {
            try? mapView?.mapboxMap.setCameraBounds(for: options)
        }
    }

    /// List of animators currently alive
    public var cameraAnimators: [CameraAnimator] {
        guard let mapView = mapView else {
            return []
        }

        return mapView.cameraAnimators
    }

    /// Internal camera animator used for animated transition
    internal var internalAnimator: CameraAnimator?

    /// May want to convert to an enum.
    fileprivate let northBearing: CGFloat = 0

    internal weak var mapView: MapView?

    internal init(mapView: MapView) {
        self.mapView = mapView
        self.options = CameraBoundsOptions(cameraBounds: mapView.mapboxMap.cameraBounds)
    }

    // MARK: Setting a new camera

    /// Interrupts all `active` animation.
    /// The camera remains at the last point before the cancel request was invoked, i.e.,
    /// the camera is not reset or fast-forwarded to the end of the transition.
    /// Canceled animations cannot be restarted / resumed. The animator must be recreated.
    public func cancelAnimations() {
        guard let validMapView = mapView else { return }
        for animator in validMapView.cameraAnimators where animator.state == .active {
            animator.stopAnimation()
        }
    }

    /// Moves the viewpoint to a different location using a transition animation that
    /// evokes powered flight and an optional transition duration and timing function
    /// It seamlessly incorporates zooming and panning to help
    /// the user find his or her bearings even after traversing a great distance.
    ///
    /// - Parameters:
    ///   - camera: The camera options at the end of the animation. Any camera parameters that are nil will not be animated.
    ///   - duration: Duration of the animation, measured in seconds. If nil, a suitable calculated duration is used.
    ///   - completion: Completion handler called when the animation stops
    /// - Returns: An instance of `Cancelable` which can be canceled if necessary
    @discardableResult
    public func fly(to camera: CameraOptions,
                    duration: TimeInterval? = nil,
                    completion: AnimationCompletion? = nil) -> Cancelable? {

        guard let mapView = mapView,
              let flyToAnimator = FlyToCameraAnimator(
                initial: mapView.cameraState,
                final: camera,
                cameraBounds: mapView.mapboxMap.cameraBounds,
                owner: AnimationOwner(rawValue: "com.mapbox.maps.cameraAnimationsManager.flyToAnimator"),
                duration: duration,
                mapSize: mapView.mapboxMap.size,
                delegate: self) else {
            Log.warning(forMessage: "Unable to start fly-to animation", category: "CameraManager")
            return nil
        }

        // Stop the `internalAnimator` before beginning a `flyTo`
        internalAnimator?.stopAnimation()

        mapView.addCameraAnimator(flyToAnimator)

        flyToAnimator.addCompletion { (position) in
            // Call the developer-provided completion (if present)
            completion?(position)
        }

        flyToAnimator.startAnimation()
        internalAnimator = flyToAnimator
        return internalAnimator
    }

    /// Ease the camera to a destination
    /// - Parameters:
    ///   - camera: the target camera after animation
    ///   - duration: duration of the animation
    ///   - completion: completion to be called after animation
    /// - Returns: An instance of `Cancelable` which can be canceled if necessary
    @discardableResult
    public func ease(to camera: CameraOptions,
                     duration: TimeInterval,
                     curve: UIView.AnimationCurve = .easeOut,
                     completion: AnimationCompletion? = nil) -> Cancelable? {

        internalAnimator?.stopAnimation()

        let animator = makeAnimator(duration: duration, curve: curve) { (transition) in
            transition.center.toValue = camera.center
            transition.padding.toValue = camera.padding
            transition.anchor.toValue = camera.anchor
            transition.zoom.toValue = camera.zoom
            transition.bearing.toValue = camera.bearing
            transition.pitch.toValue = camera.pitch
        }

        // Nil out the `internalAnimator` once the "ease to" finishes
        animator.addCompletion { (position) in
            completion?(position)
        }

        animator.startAnimation()
        internalAnimator = animator

        return internalAnimator
    }

}

fileprivate extension CoordinateBounds {
    func contains(_ coordinates: [CLLocationCoordinate2D]) -> Bool {
        let latitudeRange = southwest.latitude...northeast.latitude
        let longitudeRange = southwest.longitude...northeast.longitude

        for coordinate in coordinates {
            if latitudeRange.contains(coordinate.latitude) || longitudeRange.contains(coordinate.longitude) {
                return true
            }
        }
        return false
    }
}
