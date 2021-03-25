// swiftlint:disable file_length
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
    public internal(set) var cameraAnimators = NSHashTable<CameraAnimator>.weakObjects()

    /// May want to convert to an enum.
    fileprivate let northBearing: CGFloat = 0

    public weak var mapView: BaseMapView?

    public init(for mapView: BaseMapView, with mapCameraOptions: MapCameraOptions) {
        self.mapView = mapView
        self.mapCameraOptions = mapCameraOptions
    }

    // MARK: Camera creation
    /**
     Creates a new `Camera` object to fit a given array of coordinates.
    
     Note: This method does not set the map's camera to the new values. You must call
     `setCamera` in order for the changes to take effect.

     - Parameter array: Array of coordinates that should fit within the new viewport.
     - Returns: A `Camera` object that contains all coordinates within the viewport.
    */
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

    /**
     Returns the camera that best fits the given coordinate bounds, with optional edge
     padding, bearing, and pitch values.
     - Parameter coordinateBounds: The coordinate bounds that will be displayed within the viewport.
     - Parameter edgePadding: The new padding to be used by the camera. By default, this value is `UIEdgeInsets.zero`.
     - Parameter bearing: The new bearing to be used by the camera. By default, this value is `0`.
     - Parameter pitch: The new pitch to be used by the camera. By default, this value is `0`.
     */
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

    /**
     Returns the camera that best fits the given geometry, with optional edge
     padding, bearing, and pitch values.
     - Parameter geometry: The geoemtry that will be displayed within the viewport.
     - Parameter edgePadding: The new padding to be used by the camera. By default, this value is `UIEdgeInsets.zero`.
     - Parameter bearing: The new bearing to be used by the camera. By default, this value is `0`.
     - Parameter pitch: The new pitch to be used by the camera. By default, this value is `0`.
     */
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

    /**
     Returns the coordinate bounds for a given `Camera` object's viewport.
     - Parameter camera: The camera that the coordinate bounds will be returned for.
     */
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
    /// - Parameter targetCamera: The target camera to transition to.
    /// - Parameter animated: Set to `true` if transition should be animated. `false` by default.
    /// - Parameter duration: Controls the duration of the animation transition. Must be greater than zero if `animated` is true.
    /// - Parameter completion: The completion block to be called after an animated transition. Only called if `animated` is true.
    public func setCamera(to targetCamera: CameraOptions, animated: Bool = false, duration: TimeInterval = 0, completion: ((UIViewAnimatingPosition) -> Void)? = nil) {
        guard let mapView = mapView else {
            assertionFailure("MapView is nil.")
            return
        }

        let clampedCamera = CameraOptions(center: targetCamera.center,
                                          padding: targetCamera.padding,
                                          anchor: targetCamera.anchor,
                                          zoom: targetCamera.zoom?.clamped(to: mapCameraOptions.minimumZoomLevel...mapCameraOptions.maximumZoomLevel),
                                          bearing: optimizeBearing(startBearing: mapView.bearing, endBearing: targetCamera.bearing),
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

    /**
     Transition the camera view to a new map camera based on individual camera properties,
     optionally animating the change and executing a completion block after the transition occurs.

     - Parameter center: The new center coordinate the viewport will transition to.
     - Parameter padding: The new edge insets the viewport will use to to apply padding.
     - Parameter anchor: The new anchor point the viewport will use.
     - Parameter zoom: The new zoom level the viewport will transition to.
     - Parameter bearing: The bearing the viewport will rotate to.
     - Parameter pitch: The new pitch the viewport will transition to.
     - Parameter animated: A boolean indicating if the change should be animated. By default, this value is `false`
     - Parameter completion: The completion block to execute after the transition has occurred.
     */
    public func setCamera(centerCoordinate: CLLocationCoordinate2D? = nil,
                          padding: UIEdgeInsets? = nil,
                          anchor: CGPoint? = nil,
                          zoom: CGFloat? = nil,
                          bearing: CLLocationDirection? = nil,
                          pitch: CGFloat? = nil,
                          animated: Bool = false,
                          duration: TimeInterval = 0,
                          completion: ((UIViewAnimatingPosition) -> Void)? = nil) {
        let newCamera = CameraOptions(center: centerCoordinate,
                                      padding: padding,
                                      anchor: anchor,
                                      zoom: zoom,
                                      bearing: bearing,
                                      pitch: pitch)

        setCamera(to: newCamera, animated: animated, duration: duration, completion: completion)
    }
    // swiftlint:enable function_parameter_count

    public func cancelTransitions() {
        for animator in cameraAnimators.allObjects where animator.state == .active {
            animator.stopAnimation()
        }
    }

    /** Private func to perform camera animation

        - Parameter animated: Whether the transition should be animated
        - Parameter duration: If animated, how long the animation takes
        - Parameter animation: closure to perform
        - Parameter completion: animation block called on completion
     */
    fileprivate func performCameraAnimation(duration: TimeInterval, animation: @escaping () -> Void, completion: ((UIViewAnimatingPosition) -> Void)? = nil) {
        var animator: CameraAnimator?

        animator = makeCameraAnimator(duration: duration, curve: .easeOut)
        animator?.addAnimations(animation)

        animator?.addCompletion({ (position) in
            completion?(position)
            animator = nil
        })

        animator?.startAnimation()
    }

    /**
     Reset the map's camera to the default style camera.
     */
    public func resetPosition() {
        guard let mapView = mapView else {
            assertionFailure("MapView is nil.")
            return
        }

        let defaultOptions = try! mapView.__map.getStyleDefaultCamera()
        setCamera(to: defaultOptions, completion: nil)
    }

    /**
     Resets the map rotation to a north bearing of `0` degrees.

     - Parameter animated: A boolean indicating if the change should be animated.
     By default, this value is `false`.
     */
    public func resetNorth(_ animated: Bool = false) {
        setCamera(bearing: CLLocationDirection(northBearing),
                  animated: animated)
    }

    // MARK: Fitting the camera specified regions

    /**
     Transitions the viewport to fit a given set of new coordinate bounds,
     optionally animating the change.
     
     This method also accounts for any `UIEdgeInsets` that may have been set
     through the the `CameraView`'s `padding` property.
     
     - Parameter newCoordinateBounds: The coordinate bounds that will be displayed within the viewport.
     - Parameter animated: A boolean indicating if the change should be animated. Defaults to `false`.
     */
    public func transitionCoordinateBounds(newCoordinateBounds: CoordinateBounds,
                                           animated: Bool = false) {
        transitionCoordinateBounds(to: newCoordinateBounds,
                                   edgePadding: UIEdgeInsets.zero,
                                   animated: animated,
                                   completion: nil)
    }

    /**
     Transitions the viewport to fit a given set of new coordinate bounds,
     specifying a custom edge padding, an optional animation change, and an optional
     completion block to execute after the transition occurs.
     
     - Parameter newCoordinateBounds: The new coordinate bounds that will be displayed within the viewport.
     - Parameter edgePadding: The padding the viewport will adjust itself by after transitioning to the new viewport.
     - Parameter animated: A boolean indicating if the change should be animated. Defaults to `false`.
     - Parameter completion: An optional function to execute after the transition has occurred.
     */
    public func transitionCoordinateBounds(to newCoordinateBounds: CoordinateBounds,
                                           edgePadding: UIEdgeInsets,
                                           animated: Bool = false,
                                           completion: ((UIViewAnimatingPosition) -> Void)? = nil) {
        let southeast = CLLocationCoordinate2D(latitude: newCoordinateBounds.northeast.latitude,
                                               longitude: newCoordinateBounds.southwest.longitude)
        let southwest = newCoordinateBounds.southwest
        let northwest = CLLocationCoordinate2D(latitude: newCoordinateBounds.southwest.latitude,
                                               longitude: newCoordinateBounds.northeast.longitude)
        let northeast = newCoordinateBounds.northeast

        transitionVisibleCoordinates(to: [southeast, southwest, northwest, northeast],
                                     edgePadding: edgePadding,
                                     bearing: 0,
                                     duration: 0,
                                     animated: animated,
                                     completion: completion)
    }

    /**
     Transitions the viewport to fit a given array of new coordinates, specifying
     a custom edge padding an optional animation change.
     
     - Parameter newCoordinates: The coordinate bounds that will be displayed within the viewport.
     - Parameter edgePadding: The padding the viewport will adjust itself by after transitioning to the new viewport.
     - Parameter animated: A boolean indicating if the change should be animated. Defaults to `false`.
     */
    public func transitionVisibleCoordinates(newCoordinates: [CLLocationCoordinate2D],
                                             edgePadding: UIEdgeInsets,
                                             animated: Bool = false) {
        transitionVisibleCoordinates(to: newCoordinates,
                                     edgePadding: edgePadding,
                                     bearing: 0,
                                     duration: 0,
                                     animated: animated,
                                     completion: nil)
    }

    /**
     Transitions the viewport to fit a given array of new coordinates, specifying
     a custom edge padding, an optional animation change, and an optional
     completion block to execute after the transition occurs.
     
     - Parameter newCoordinates: The array of coordinates that will be displayed within the viewport.
     - Parameter edgePadding: The padding the viewport will adjust itself by after transitioning to the new viewport.
     - Parameter animated: A boolean indicating if the change should be animated. Defaults to `false`.
     - Parameter completion: An optional closure to execute after the transition has occurred.
     */
    public func transitionVisibleCoordinates(to newCoordinates: [CLLocationCoordinate2D],
                                             edgePadding: UIEdgeInsets,
                                             bearing: CLLocationDirection,
                                             duration: TimeInterval,
                                             animated: Bool = false,
                                             completion: ((UIViewAnimatingPosition) -> Void)? = nil) {
        guard let mapView = mapView else {
            assertionFailure("MapView is nil.")
            return
        }

        // Don't set visible coordinate bounds if the coordinates are
        // outside of the range of bounds specified in the MapCameraOptions.
        if mapCameraOptions.restrictedCoordinateBounds?.contains(newCoordinates) == false { return }

        let padding = edgePadding.toMBXEdgeInsetsValue()
        let bearing = bearing >= 0 ? CLLocationDirection(CGFloat(bearing)) : mapView.bearing
        let coordinates = newCoordinates.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude)}
        let pitch = mapView.pitch

        let cameraOptions = try! mapView.__map.cameraForCoordinates(forCoordinates: coordinates,
                                                                    padding: padding,
                                                                    bearing: NSNumber(value: Float(bearing)),
                                                                    pitch: NSNumber(value: Float(pitch)))

        setCamera(to: cameraOptions, animated: animated, duration: duration, completion: completion)
    }

    /**
     Moves the viewpoint to a different location using a transition animation that
     evokes powered flight and an optional transition duration and timing function

     The transition animation seamlessly incorporates zooming and panning to help
     the user find his or her bearings even after traversing a great distance.

     - Parameter camera: The camera options at the end of the animation. Any camera parameters that are nil will not be animated.
     - Parameter duration: Duration of the animation, measured in seconds. If nil, a suitable calculated duration is used.
     - Parameter completion: Completion handler called when the animation stops
     */
    public func flyTo(to camera: CameraOptions,
                      duration: TimeInterval? = nil,
                      completion: AnimationCompletion? = nil) -> CameraAnimator? {

        guard let mapView = mapView else {
            return nil
        }

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

    /**
    This function optimizes the bearing for set camera so that it is taking the shortest path

    - Parameter startBearting: The current or start bearing of the map viewport
    - Parameter endBearting: The bearing of where the map viewport should end at
    - Returns: A `CLLocationDirection` that represents the correct final bearing accounting for positive and negatives
    */
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

// MARK: Camera Animation
extension CameraManager: CameraAnimatorDelegate {
    // MARK: Animator Functions

    /**
     Convenience to create a `CameraAnimator` and will add it to a List of `CameraAnimators` to track the lifecycle of that animation.

     - Parameter duration: The duration of the animation, in seconds.
     - Parameter timingParameters: The object providing the timing information. This object must adopt the `UITimingCurveProvider` protocol.
     - Parameter animationOwner: Property that conforms to `AnimationOwnerProtocol` to represent who owns that animation.
     - Returns `CameraAnimator`: A class that represents an animator with the provided configuration.
     */
    public func makeCameraAnimator(duration: TimeInterval,
                                   timingParameters parameters: UITimingCurveProvider,
                                   animationOwner: AnimationOwner = .unspecified) -> CameraAnimator {
        let propertyAnimator = UIViewPropertyAnimator(duration: duration, timingParameters: parameters)
        let cameraAnimator = CameraAnimator(delegate: self, propertyAnimator: propertyAnimator, owner: animationOwner)
        cameraAnimators.add(cameraAnimator)
        return cameraAnimator
    }

    /**
     Convenience to create a `CameraAnimator` and will add it to a List of `CameraAnimators` to track the lifecycle of that animation

     - Parameter duration: The duration of the animation, in seconds.
     - Parameter curve: The UIKit timing curve to apply to the animation.
     - Parameter animationOwner: Property that conforms to `AnimationOwnerProtocol` to represent who owns that animation.
     - Parameter animations: The block containing the animations. This block has no return value and takes no parameters.
                             Use this block to modify any animatable view properties. When you start the animations,
                             those properties are animated from their current values to the new values using the specified animation parameters.
     - Returns `CameraAnimator`: A class that represents an animator with the provided configuration.
     */
    public func makeCameraAnimator(duration: TimeInterval,
                                   curve: UIView.AnimationCurve,
                                   animationOwner: AnimationOwner = .unspecified,
                                   animations: (() -> Void)? = nil) -> CameraAnimator {
        let propertyAnimator = UIViewPropertyAnimator(duration: duration, curve: curve, animations: animations)
        let cameraAnimator = CameraAnimator(delegate: self, propertyAnimator: propertyAnimator, owner: animationOwner)
        cameraAnimators.add(cameraAnimator)
        return cameraAnimator
    }

    /**
     Convenience to create a `CameraAnimator` and will add it to a List of `CameraAnimators` to track the lifecycle of that animation

     - Parameter duration: The duration of the animation, in seconds.
     - Parameter controlPoint1: The first control point for the cubic Bézier timing curve.
     - Parameter controlPoint2: The second control point for the cubic Bézier timing curve.
     - Parameter animationOwner: Property that conforms to `AnimationOwnerProtocol` to represent who owns that animation.
     - Parameter animations: The block containing the animations. This block has no return value and takes no parameters.
                             Use this block to modify any animatable view properties. When you start the animations,
                             those properties are animated from their current values to the new values using the specified animation parameters.
     - Returns `CameraAnimator`: A class that represents an animator with the provided configuration.
     */
    public func makeCameraAnimator(duration: TimeInterval,
                                   controlPoint1 point1: CGPoint,
                                   controlPoint2 point2: CGPoint,
                                   animationOwner: AnimationOwner = .unspecified,
                                   animations: (() -> Void)? = nil) -> CameraAnimator {
        let propertyAnimator = UIViewPropertyAnimator(duration: duration, controlPoint1: point1, controlPoint2: point2, animations: animations)
        let cameraAnimator = CameraAnimator(delegate: self, propertyAnimator: propertyAnimator, owner: animationOwner)
        cameraAnimators.add(cameraAnimator)
        return cameraAnimator
    }

    /**
     Convenience to create a `CameraAnimator` and will add it to a List of `CameraAnimators` to track the lifecycle of that animation

     - Parameter duration: The duration of the animation, in seconds.
     - Parameter timingParameters: The type of `AnimationCurve` for the animation.
     - Parameter animationOwner: Property that conforms to `AnimationOwnerProtocol` to represent who owns that animation.
     - Parameter animations: The block containing the animations. This block has no return value and takes no parameters.
                             Use this block to modify any animatable view properties. When you start the animations,
                             those properties are animated from their current values to the new values using the specified animation parameters.
     - Returns `CameraAnimator`: A class that represents an animator with the provided configuration.
     */
    public func makeCameraAnimator(duration: TimeInterval,
                                   dampingRatio ratio: CGFloat,
                                   animationOwner: AnimationOwner = .unspecified,
                                   animations: (() -> Void)? = nil) -> CameraAnimator {
        let propertyAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: ratio, animations: animations)
        let cameraAnimator = CameraAnimator(delegate: self, propertyAnimator: propertyAnimator, owner: animationOwner)
        cameraAnimators.add(cameraAnimator)
        return cameraAnimator
    }

    // MARK: CameraAnimatorDelegate functions
    func schedulePendingCompletion(forAnimator animator: CameraAnimator, completion: @escaping AnimationCompletion, animatingPosition: UIViewAnimatingPosition) {
        guard let mapView = mapView else { return }
        mapView.pendingAnimatorCompletionBlocks.append((completion, animatingPosition))
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
