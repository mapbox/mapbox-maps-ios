import UIKit
import Turf

public protocol CameraAnimator {

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
    public internal(set) var mapCameraOptions: MapCameraOptions

    /// List of animators currently alive
    public var cameraAnimators: [CameraAnimator] {
        guard let mapView = mapView else {
            return []
        }

        return mapView.cameraAnimators
    }

    /// Used to update the map's camera options and pass them to the core Map.
    internal func updateMapCameraOptions(newOptions: MapCameraOptions) {
        let boundOptions = BoundOptions(__bounds: newOptions.restrictedCoordinateBounds ?? nil,
                                        maxZoom: newOptions.maximumZoomLevel as NSNumber,
                                        minZoom: newOptions.minimumZoomLevel as NSNumber,
                                        maxPitch: newOptions.maximumPitch as NSNumber,
                                        minPitch: newOptions.minimumPitch as NSNumber)
        mapView?.mapboxMap.__map.setBoundsFor(boundOptions)
        mapCameraOptions = newOptions
    }

    /// Internal camera animator used for animated transition
    internal var internalAnimator: CameraAnimator?

    /// May want to convert to an enum.
    fileprivate let northBearing: CGFloat = 0

    internal weak var mapView: BaseMapView?

    public init(for mapView: BaseMapView, with mapCameraOptions: MapCameraOptions) {
        self.mapView = mapView
        self.mapCameraOptions = mapCameraOptions
    }

    // MARK: Setting a new camera

    /// Transition the map's viewport to a new camera.
    /// - Parameters:
    ///   - targetCamera: The target camera to transition to.
    ///   - animated: Set to `true` if transition should be animated. `false` by default.
    ///   - duration: Controls the duration of the animation transition. Must be greater than zero if `animated` is true.
    ///   - completion: The completion block to be called after an animated transition. Only called if `animated` is true.
    public func setCamera(to targetCamera: CameraOptions,
                          animated: Bool = false,
                          duration: TimeInterval = 0,
                          completion: ((UIViewAnimatingPosition) -> Void)? = nil) {
        guard let mapView = mapView else {
            assertionFailure("MapView is nil.")
            return
        }

        internalAnimator?.stopAnimation()

        let clampedCamera = CameraOptions(center: targetCamera.center,
                                          padding: targetCamera.padding,
                                          anchor: targetCamera.anchor,
                                          zoom: targetCamera.zoom?.clamped(to: mapCameraOptions.minimumZoomLevel...mapCameraOptions.maximumZoomLevel),
                                          bearing: targetCamera.bearing,
                                          pitch: targetCamera.pitch?.clamped(to: mapCameraOptions.minimumPitch...mapCameraOptions.maximumPitch))

        // Return early if the cameraView's camera is already at `clampedCamera`
        guard mapView.cameraOptions != clampedCamera else {
            return
        }

        if animated && duration > 0 {
            let animation = { (transition: inout CameraTransition) in
                transition.center.toValue = clampedCamera.center
                transition.padding.toValue = clampedCamera.padding
                transition.anchor.toValue = clampedCamera.anchor
                transition.zoom.toValue = clampedCamera.zoom
                transition.bearing.toValue = clampedCamera.bearing
                transition.pitch.toValue = clampedCamera.pitch
            }
            performCameraAnimation(duration: duration, animation: animation, completion: completion)
        } else {
            mapView.mapboxMap.updateCamera(with: clampedCamera)
        }
    }

    /// Interrupts all `active` animation.
    /// The camera remains at the last point before the cancel request was invoked, i.e.,
    /// the camera is not reset or fast-forwarded to the end of the transition.
    /// Canceled animations cannot be restarted / resumed. The animator must be recreated.
    public func cancelAnimations() {
        guard let validMapView = mapView else { return }
        for animator in validMapView.cameraAnimators {
            animator.stopAnimation()
        }
    }

    /// Private function to perform camera animation
    /// - Parameters:
    ///   - duration: If animated, how long the animation takes
    ///   - animation: closure to perform
    ///   - completion: animation block called on completion
    fileprivate func performCameraAnimation(duration: TimeInterval,
                                            animation: @escaping (inout CameraTransition) -> Void,
                                            completion: ((UIViewAnimatingPosition) -> Void)? = nil) {

        // Stop previously running animations
        internalAnimator?.stopAnimation()

        // Make a new camera animator for the new properties

        let cameraAnimator = makeAnimator(duration: duration,
                                          curve: .easeOut,
                                          animationOwner: .custom(id: "com.mapbox.maps.cameraManager"),
                                          animations: animation)

        // Add completion
        cameraAnimator.addCompletion({ (position) in
            completion?(position)
        })

        // Start animation
        cameraAnimator.startAnimation()

        // Store the animator in order to keep it alive
        internalAnimator = cameraAnimator
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
    /// - Returns: An instance of `CameraAnimatorProtocol` which can be interrupted if necessary
    @discardableResult
    public func fly(to camera: CameraOptions,
                    duration: TimeInterval? = nil,
                    completion: AnimationCompletion? = nil) -> CameraAnimator? {

        guard let mapView = mapView,
              let flyToAnimator = FlyToCameraAnimator(
                inital: mapView.cameraOptions,
                final: camera,
                owner: .custom(id: "fly-to"),
                duration: duration,
                mapSize: mapView.mapboxMap.size,
                delegate: self) else {
            Log.warning(forMessage: "Unable to start fly-to animation", category: "CameraManager")
            return nil
        }

        // Stop the `internalAnimator` before beginning a `flyTo`
        internalAnimator?.stopAnimation()

        mapView.addCameraAnimator(flyToAnimator)

        // Nil out the internalAnimator after `flyTo` finishes
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
    /// - Returns: An instance of `CameraAnimatorProtocol` which can be interrupted if necessary
    @discardableResult
    public func ease(to camera: CameraOptions,
                     duration: TimeInterval,
                     completion: AnimationCompletion? = nil) -> CameraAnimator? {

        internalAnimator?.stopAnimation()

        let animator = makeAnimator(duration: duration, curve: .easeInOut) { (transition) in
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
