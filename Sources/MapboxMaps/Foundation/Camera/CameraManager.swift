// swiftlint:disable file_length type_body_length
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
        try! mapView?.__map.setBoundsFor(boundOptions)
        mapCameraOptions = newOptions
    }

    /// Pointer HashTable for holding camera animators
    internal var cameraAnimators = NSHashTable<CameraAnimator>.weakObjects()

    /// List of animators currently alive
    public var cameraAnimatorsList: [CameraAnimator] {
        return cameraAnimators.allObjects
    }

    /// Internal camera animator used for animated transition
    internal var internalCameraAnimator: CameraAnimator?

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
        let cameraOptions = mapView.cameraView.camera

        let defaultEdgeInsets = EdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        // Create a new camera options with adjusted values
        let options = try! mapView.__map.cameraForCoordinates(forCoordinates: coordinateLocations,
                                                              padding: cameraOptions.__padding ?? defaultEdgeInsets,
                                                              bearing: cameraOptions.__bearing,
                                                              pitch: cameraOptions.__pitch)
        // Create a new camera object with adjusted values
        return options
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

        let cameraOptions = try! mapView.__map.cameraForCoordinateBounds(for: coordinateBounds,
                                                                         padding: edgePadding.toMBXEdgeInsetsValue(),
                                                                         bearing: NSNumber(value: Float(bearing)),
                                                                         pitch: NSNumber(value: Float(pitch)))

        return cameraOptions
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

        let mbxGeometry = MBXGeometry(geometry: geometry)

        let cameraOptions = try! mapView.__map.cameraForGeometry(for: mbxGeometry,
                                                                 padding: edgePadding.toMBXEdgeInsetsValue(),
                                                                 bearing: NSNumber(value: Float(bearing)),
                                                                 pitch: NSNumber(value: Float(pitch)))
        return cameraOptions
    }

    /// Returns the coordinate bounds for a given `Camera` object's viewport.
    /// - Parameter camera: The camera that the coordinate bounds will be returned for.
    /// - Returns: `CoordinateBounds` for the given `Camera`
    public func coordinateBounds(for camera: CameraOptions) -> CoordinateBounds {
        guard let mapView = mapView else {
            assertionFailure("MapView is nil.")
            return CoordinateBounds()
        }

        let coordinateBounds = try! mapView.__map.coordinateBoundsForCamera(forCamera: camera)
        return coordinateBounds
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

        let clampedCamera = CameraOptions(center: targetCamera.center,
                                          padding: targetCamera.padding,
                                          anchor: targetCamera.anchor,
                                          zoom: targetCamera.zoom?.clamped(to: mapCameraOptions.minimumZoomLevel...mapCameraOptions.maximumZoomLevel),
                                          bearing: optimizeBearing(startBearing: mapView.cameraView.localBearing, endBearing: targetCamera.bearing),
                                          pitch: targetCamera.pitch?.clamped(to: mapCameraOptions.minimumPitch...mapCameraOptions.maximumPitch))

        // Return early if the cameraView's camera is already at `clampedCamera`
        guard mapView.camera != clampedCamera else {
            return
        }

        let transitionBlock = {
            mapView.camera = clampedCamera
        }

        if animated && duration > 0 {
            performCameraAnimation(duration: duration, animation: transitionBlock, completion: completion)
        } else {
            transitionBlock()
        }
    }

    public func cancelAnimations() {
        for animator in cameraAnimators.allObjects where animator.state == .active {
            animator.stopAnimation()
        }
    }

    /// Private function to perform camera animation
    /// - Parameters:
    ///   - duration: If animated, how long the animation takes
    ///   - animation: closure to perform
    ///   - completion: animation block called on completion
    fileprivate func performCameraAnimation(duration: TimeInterval, animation: @escaping () -> Void, completion: ((UIViewAnimatingPosition) -> Void)? = nil) {

        // Stop previously running animations
        internalCameraAnimator?.stopAnimation()

        // Make a new camera animator for the new properties
        internalCameraAnimator = makeCameraAnimator(duration: duration,
                                      curve: .easeOut,
                                      animationOwner: .custom(id: "com.mapbox.maps.cameraManager"),
                                      animations: animation)

        // Add completion
        internalCameraAnimator?.addCompletion({ [weak self] (position) in
            completion?(position)
            self?.internalCameraAnimator = nil
        })

        // Start animation
        internalCameraAnimator?.startAnimation()
    }

    /// Moves the viewpoint to a different location using a transition animation that
    /// evokes powered flight and an optional transition duration and timing function
    /// It seamlessly incorporates zooming and panning to help
    /// the user find his or her bearings even after traversing a great distance.
    ///
    /// NOTE: Keep in mind the lifecycle of the `CameraAnimator` returned by this method.
    /// If a `CameraAnimator` is destroyed, before the animation is finished,
    /// the animation will be interrupted and completion handlers will be called.
    ///
    /// - Parameters:
    ///   - camera: The camera options at the end of the animation. Any camera parameters that are nil will not be animated.
    ///   - duration: Duration of the animation, measured in seconds. If nil, a suitable calculated duration is used.
    ///   - completion: Completion handler called when the animation stops
    /// - Returns: The optional `CameraAnimator` that will execute the FlyTo animation
    public func fly(to camera: CameraOptions,
                    duration: TimeInterval? = nil,
                    completion: AnimationCompletion? = nil) -> CameraAnimator? {

        guard let mapView = mapView else {
            return nil
        }

        // Stop the `internalCameraAnimator` before beginning a `flyTo`
        internalCameraAnimator?.stopAnimation()

        guard let interpolator = FlyToInterpolator(from: mapView.camera,
                                                   to: camera,
                                                   size: mapView.bounds.size) else {
            return nil
        }

        // If there was no duration specified, use a default
        let time: TimeInterval = duration ?? interpolator.duration()

        // TODO: Consider timesteps based on the flyTo curve, for example, it would be beneficial to have a higher
        // density of time steps at towards the start and end of the animation to avoid jiggling.
        let timeSteps = stride(from: 0.0, through: 1.0, by: 0.025)
        let keyTimes: [Double] = Array(timeSteps)

        let animator = makeCameraAnimator(duration: time, curve: .linear) {

            UIView.animateKeyframes(withDuration: 0, delay: 0, options: []) {

                for keyTime in keyTimes {
                    let interpolatedCoordinate = interpolator.coordinate(at: keyTime)
                    let interpolatedZoom = interpolator.zoom(at: keyTime)
                    let interpolatedBearing = interpolator.bearing(at: keyTime)
                    let interpolatedPitch = interpolator.pitch(at: keyTime)

                    UIView.addKeyframe(withRelativeStartTime: keyTime, relativeDuration: 0.025) {
                        self.mapView?.cameraView.centerCoordinate = interpolatedCoordinate
                        self.mapView?.cameraView.zoom = CGFloat(interpolatedZoom)
                        self.mapView?.cameraView.bearing = CGFloat(interpolatedBearing)
                        self.mapView?.cameraView.pitch = CGFloat(interpolatedPitch)
                    }
                }
            }
        }

        if let completion = completion {
            animator.addCompletion(completion)
        }

        animator.startAnimation()

        return animator
    }

    /// This function optimizes the bearing for set camera so that it is taking the shortest path.
    /// - Parameters:
    ///   - startBearing: The current or start bearing of the map viewport.
    ///   - endBearing: The bearing of where the map viewport should end at.
    /// - Returns: A `CLLocationDirection` that represents the correct final bearing accounting for positive and negatives.
    internal func optimizeBearing(startBearing: CLLocationDirection?, endBearing: CLLocationDirection?) -> CLLocationDirection? {
        // This modulus is required to account for larger values
        guard
            let startBearing = startBearing?.truncatingRemainder(dividingBy: 360.0),
            let endBearing = endBearing?.truncatingRemainder(dividingBy: 360.0)
        else {
            return nil
        }

        // 180 degrees is the max the map should rotate, therefore if the difference between the end and start point is
        // more than 180 we need to go the opposite direction
        if endBearing - startBearing >= 180 {
            return endBearing - 360
        }

        // This is the inverse of the above, accounting for negative bearings
        if endBearing - startBearing <= -180 {
            return endBearing + 360
        }

        return endBearing
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
