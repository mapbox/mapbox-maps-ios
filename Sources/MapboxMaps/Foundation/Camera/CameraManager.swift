import UIKit
import Turf

/// An object that manages a camera's view lifecycle.
public class CameraManager {

    /// Used to set up camera specific configuration
    public internal(set) var mapCameraOptions: MapCameraOptions

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
    internal var internalAnimator: CameraAnimatorProtocol?

    /// May want to convert to an enum.
    fileprivate let northBearing: CGFloat = 0

    internal weak var mapView: BaseMapView?

    public init(for mapView: BaseMapView, with mapCameraOptions: MapCameraOptions) {
        self.mapView = mapView
        self.mapCameraOptions = mapCameraOptions
    }

    // MARK: Camera creation

    /// Creates a new `Camera` object to fit a given array of coordinates.
    ///
    /// Note: This method does not set the map's camera to the new values. You must call
    /// - Parameter coordinates: Array of coordinates that should fit within the new viewport.
    /// - Returns: A `Camera` object that contains all coordinates within the viewport.
    public func camera(for coordinates: [CLLocationCoordinate2D]) -> CameraOptions {
        guard let mapView = mapView else {
            assertionFailure("MapView is nil.")
            return CameraOptions()
        }

        let coordinateLocations = coordinates.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }

        // Construct new camera options with current values
        let cameraOptions = MapboxCoreMaps.CameraOptions(mapView.cameraOptions)

        let defaultEdgeInsets = EdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        // Create a new camera options with adjusted values
        return CameraOptions(mapView.mapboxMap.__map.cameraForCoordinates(
            forCoordinates: coordinateLocations,
            padding: cameraOptions.__padding ?? defaultEdgeInsets,
            bearing: cameraOptions.__bearing,
            pitch: cameraOptions.__pitch))
    }

    /// Returns the camera that best fits the given coordinate bounds, with optional edge padding, bearing, and pitch values.
    /// - Parameters:
    ///   - coordinateBounds: The coordinate bounds that will be displayed within the viewport.
    ///   - edgePadding: The new padding to be used by the camera. By default, this value is `UIEdgeInsets.zero`.
    ///   - bearing: The new bearing to be used by the camera. By default, this value is `0`.
    ///   - pitch: The new pitch to be used by the camera. By default, this value is `0`.
    /// - Returns: A set of options `CameraOptions` that represents properties of the Camera.
    public func camera(for coordinateBounds: CoordinateBounds,
                       edgePadding: UIEdgeInsets = UIEdgeInsets.zero,
                       bearing: CGFloat = 0.0,
                       pitch: CGFloat = 0.0) -> CameraOptions {
        guard let mapView = mapView else {
            return CameraOptions()
        }

        return CameraOptions(mapView.mapboxMap.__map.cameraForCoordinateBounds(
            for: coordinateBounds,
            padding: edgePadding.toMBXEdgeInsetsValue(),
            bearing: NSNumber(value: Float(bearing)),
            pitch: NSNumber(value: Float(pitch))))
    }

    /// Returns the camera that best fits the given geometry, with optional edge padding, bearing, and pitch values.
    /// - Parameters:
    ///   - geometry: The geoemtry that will be displayed within the viewport.
    ///   - edgePadding: The new padding to be used by the camera. By default, this value is `UIEdgeInsets.zero`.
    ///   - bearing: The new bearing to be used by the camera. By default, this value is `0`.
    ///   - pitch: The new pitch to be used by the camera. By default, this value is `0`.
    /// - Returns: A set of options `CameraOptions` that represents properties of the Camera.
    public func camera(fitting geometry: Geometry,
                       edgePadding: UIEdgeInsets = UIEdgeInsets.zero,
                       bearing: CGFloat = 0.0,
                       pitch: CGFloat = 0.0) -> CameraOptions {
        guard let mapView = mapView else {
            assertionFailure("MapView is nil.")
            return CameraOptions()
        }

        return CameraOptions(mapView.mapboxMap.__map.cameraForGeometry(
            for: MBXGeometry(geometry: geometry),
            padding: edgePadding.toMBXEdgeInsetsValue(),
            bearing: NSNumber(value: Float(bearing)),
            pitch: NSNumber(value: Float(pitch))))
    }

    /// Returns the coordinate bounds for a given `Camera` object's viewport.
    /// - Parameter camera: The camera that the coordinate bounds will be returned for.
    /// - Returns: `CoordinateBounds` for the given `Camera`
    public func coordinateBounds(for camera: CameraOptions) -> CoordinateBounds {
        guard let mapView = mapView else {
            assertionFailure("MapView is nil.")
            return CoordinateBounds()
        }
        return mapView.mapboxMap.__map.coordinateBoundsForCamera(forCamera: MapboxCoreMaps.CameraOptions(camera))
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
            let mbxCamera = MapboxCoreMaps.CameraOptions(clampedCamera)
            mapView.mapboxMap.__map.setCameraFor(mbxCamera)
        }
    }

    public func cancelAnimations() {
        guard let validMapView = mapView else { return }
        for animator in validMapView.cameraAnimatorsHashTable.allObjects where animator.state == UIViewAnimatingState.active {
            animator.stopAnimation()
        }
    }

    /// Private function to perform camera animation
    /// - Parameters:
    ///   - duration: If animated, how long the animation takes
    ///   - animation: closure to perform
    ///   - completion: animation block called on completion
    fileprivate func performCameraAnimation(duration: TimeInterval, animation: @escaping CameraAnimation, completion: ((UIViewAnimatingPosition) -> Void)? = nil) {

        // Stop previously running animations
        internalAnimator?.stopAnimation()

        // Make a new camera animator for the new properties

        let cameraAnimator = makeCameraAnimator(duration: duration,
                                                curve: .easeOut,
                                                animationOwner: .custom(id: "com.mapbox.maps.cameraManager"),
                                                animations: animation)

        // Add completion
        cameraAnimator.addCompletion({ [weak self] (position) in
            completion?(position)
            self?.internalAnimator = nil
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
                    completion: AnimationCompletion? = nil) -> CameraAnimatorProtocol? {

        guard let mapView = mapView else {
            return nil
        }

        // Stop the `internalAnimator` before beginning a `flyTo`
        internalAnimator?.stopAnimation()

        let flyToAnimator = FlyToAnimator(delegate: self)
        mapView.cameraAnimatorsHashTable.add(flyToAnimator)

        flyToAnimator.makeFlyToInterpolator(from: mapView.cameraOptions,
                                             to: camera,
                                             duration: duration,
                                             screenFullSize: mapView.bounds.size)

        flyToAnimator.addCompletion(completion)
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
    public func ease(to camera: CameraOptions, duration: TimeInterval, completion: AnimationCompletion? = nil) -> CameraAnimatorProtocol? {

        internalAnimator?.stopAnimation()

        let animator = makeCameraAnimator(duration: duration, curve: .easeInOut) { (transition) in
            transition.center.toValue = camera.center
            transition.padding.toValue = camera.padding
            transition.anchor.toValue = camera.anchor
            transition.zoom.toValue = camera.zoom
            transition.bearing.toValue = camera.bearing
            transition.pitch.toValue = camera.pitch
        }

        if let completion = completion {
            animator.addCompletion(completion)
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
