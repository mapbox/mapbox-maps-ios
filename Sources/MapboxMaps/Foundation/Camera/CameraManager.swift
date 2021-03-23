// swiftlint:disable file_length
import UIKit
import Turf

/// Camera Manager transition states.
public enum TransitionState: String {
    /// A  state for when it's possible to initiate a transition.
    case possible

    /// A state for when a transition is ongoing.
    case transitioning

    /// A state for when a transition was canceled.
    case canceled
}

public extension Notification.Name {
    /// Posted by the SDK when CameraManager changes its transitionState property.
    static let cameraManagerTransitionState = Notification.Name("com.mapbox.cameraManagerTransitionState")
}

/// An object that manages a camera's view lifecycle.
// swiftlint:disable type_body_length
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

    /// The transition state of the `CameraManager`.
    public var transitionState: TransitionState = .possible {
        didSet {
            if transitionState == .canceled {
                transitionState = .possible
            }
            let userInfo = ["transitionState": transitionState.rawValue]
            NotificationCenter.default.post(name: .cameraManagerTransitionState, object: self, userInfo: userInfo)
        }
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
    /**
     Transition the camera view to a new map camera, optionally animating the change
     and executing a completion block after the transition occurs.
     
     - Parameter newCamera: The new map camera the viewport will transition to.
     - Parameter animated: A boolean indicating if the change should be animated.
                           By default, this value is `false`
     - Parameter completion: The completion block to execute after the transition has occurred.
     */

    public func setCamera(to camera: CameraOptions,
                          animated: Bool = false,
                          duration: TimeInterval = 0,
                          completion: ((Bool) -> Void)? = nil) {
        guard let mapView = mapView else {
            assertionFailure("MapView is nil.")
            completion?(false)
            return
        }

        let clampedCamera = CameraOptions(center: camera.center,
                                          padding: camera.padding,
                                          anchor: camera.anchor,
                                          zoom: camera.zoom?.clamped(to: mapCameraOptions.minimumZoomLevel...mapCameraOptions.maximumZoomLevel),
                                          bearing: optimizeBearing(startBearing: mapView.bearing, endBearing: camera.bearing),
                                          pitch: camera.pitch?.clamped(to: mapCameraOptions.minimumPitch...mapCameraOptions.maximumPitch))

        guard mapView.cameraView.camera != clampedCamera else {
            completion?(true)
            return
        }

        let animation = {
            mapView.cameraView.camera = clampedCamera
        }

        performCameraAnimation(animated: animated, duration: duration, animation: animation, completion: completion)
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
     - Parameter animated: A boolean indicating if the change should be animated.
                           By default, this value is `false`
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
                          completion: ((Bool) -> Void)? = nil) {
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
        transitionState = .canceled
        if let mapView = mapView {
            mapView.cameraView.layer.removeAllAnimations()
        }
    }

    /** Private func to perform camera animation

        - Parameters:
        - animated: Whether the transition should be animated
        - duration: If animated, how long the animation takes
        - animation: closure to perform
        - completion: animation block called on completion
     */
    fileprivate func performCameraAnimation(animated: Bool, duration: TimeInterval, animation: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        if animated {
            UIView.animate(withDuration: duration,
                           delay: 0,
                           options: [.curveEaseOut, .allowUserInteraction],
                           animations: animation,
                           completion: completion)
        } else {
            animation()
            completion?(true)
        }
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
                                           completion: (() -> Void)?) {
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
     - Parameter completion: An optional function to execute after the transition has occurred.
     */
    public func transitionVisibleCoordinates(to newCoordinates: [CLLocationCoordinate2D],
                                             edgePadding: UIEdgeInsets,
                                             bearing: CLLocationDirection,
                                             duration: TimeInterval,
                                             animated: Bool = false,
                                             completion: (() -> Void)?) {
        guard let mapView = mapView else {
            assertionFailure("MapView is nil.")
            completion?()
            return
        }

        // Don't set visible coordinate bounds if the coordinates are
        // outside of the range of bounds specified in the MapCameraOptions.
        if mapCameraOptions.restrictedCoordinateBounds?.contains(newCoordinates) == false { return }

        let padding = edgePadding.toMBXEdgeInsetsValue()
        let bearing = bearing >= 0 ? CGFloat(bearing) : mapView.cameraView.bearing
        let coordinates = newCoordinates.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude)}
        let pitch = mapView.cameraView.pitch

        let cameraOptions = try! mapView.__map.cameraForCoordinates(forCoordinates: coordinates,
                                                                    padding: padding,
                                                                    bearing: NSNumber(value: Float(bearing)),
                                                                    pitch: NSNumber(value: Float(pitch)))

        let animation = {
            mapView.cameraView.camera = cameraOptions
        }

        performCameraAnimation(animated: animated, duration: duration, animation: animation) { _ in
            completion?()
        }
    }

    /**
     Moves the camera by given values with an optional animation.

     - Parameter offset: The `CGPoint` value to shift the map's center by.
     - Parameter rotation: The angle to rotate the camera by.
     - Parameter pitch: The degrees to adjust the map's tilt by.
     - Parameter zoom: The amount to adjust the camera's zoom level by.
     - Parameter animated: Indicates  whether the camera changes should be animated.
     - Parameter pitchedDrift: This hack indicates that the calling function wants to simulate drift. Therefore we need to do some additional calculations
     */
    public func moveCamera(by offset: CGPoint? = nil, rotation: CGFloat? = nil, pitch: CGFloat? = nil, zoom: CGFloat? = nil, animated: Bool = false, pitchedDrift: Bool = false) {
        guard let mapView = mapView else {
            assertionFailure("MapView is nil.")
            return
        }

        let centerCoordinate = shiftCenterCoordinate(by: offset ?? .zero, pitchedDrift: pitchedDrift)

        var newBearing: CGFloat = 0
        if let angle = rotation {
            newBearing = angle * 180.0 / .pi * -1
            newBearing = newBearing.truncatingRemainder(dividingBy: 360.0)
        }

        var newPitch: CGFloat = 0
        if let pitchAngle = pitch {
            newPitch = mapView.pitch - pitchAngle
        }

        var newZoom: CGFloat = 0
        if let zoomDelta = zoom {
            newZoom = mapView.zoom + zoomDelta
        }

        let animation = {
            // IMPORTANT: To trigger an immediate update, cameraView properties that are structs
            // should always be animated using the camera layer instead.

            // Check whether each value has been updated before adding to the block
            if offset != nil {
                mapView.cameraView.centerCoordinate = centerCoordinate
            }

            if rotation != nil {
                mapView.cameraView.bearing = newBearing
            }

            if pitch != nil {
                mapView.cameraView.pitch = newPitch
            }

            if zoom != nil {
                mapView.cameraView.zoom = newZoom
            }
        }

        performCameraAnimation(animated: animated, duration: Double(mapCameraOptions.decelerationRate), animation: animation)
    }

    /**
     Return a new center coordinate shifted by a given offset value.
     - Parameter offset: The `CGPoint` value to shift the map's center by.
     - Parameter pitchedDrift: This hack indicates that the calling function wants to simulate drift. Therefore we need to do some additional calculations
     */
    func shiftCenterCoordinate(by offset: CGPoint, pitchedDrift: Bool = false) -> CLLocationCoordinate2D {
        guard let mapView = mapView else {
            assertionFailure("MapView is nil.")
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }

        /// Stop gap solution until we land on a fix all
        var pitchFactor: CGFloat = mapView.pitch
        if pitchedDrift {
            if pitchFactor != 0.0 {
                // These calculations are creating a multiplier for the offset to normalize the offset for pitched maps
                pitchFactor /= 10.0
                pitchFactor += 1.5
            } else {
                pitchFactor = 1.0 // We do not want divide by 0
            }
        } else {
            pitchFactor = 1.0 // We do not want divide by 0
        }

        let mapViewSize    = mapView.frame.size
        let cameraPadding     = mapView.cameraView.localPadding
        let viewPortSize      = CGSize(width: mapViewSize.width - cameraPadding.left - cameraPadding.right,
                                       height: mapViewSize.height - cameraPadding.top - cameraPadding.bottom)
        let viewPortCenter    = CGPoint(x: (viewPortSize.width / 2) + cameraPadding.left,
                                        y: (viewPortSize.height / 2) + cameraPadding.top)
        let newViewPortCenter = CGPoint(x: viewPortCenter.x - (offset.x / pitchFactor), y: viewPortCenter.y - (offset.y / pitchFactor))
        var centerCoordinate  = mapView.coordinate(for: newViewPortCenter)

        var newLong: Double

        // This logic is to prevent a rubber band effect when a pan's drift takes you across the antimeridian.

        // First calculate the scalar projection of the offset onto the unit vector pointing due east.
        // offset.y is negated so that the two coordinate systems (iOS graphics, map bearing) match.
        let bearingInRadians = CGFloat(mapView.cameraView.localBearing.toRadians())
        let offsetAlongLongitudinalAxis = offset.x * cos(bearingInRadians) - offset.y * sin(bearingInRadians)

        // If the offset is negative, the map center needs to move east, suggesting that the new longitude
        // should be greater than the old one. However, if the antimeridian was crossed, the new longitude
        // will actually be less than the old one at this point. To deal with that, we'll add 360 to ensure
        // that the new value is in the right direction relative to the old one.
        if offsetAlongLongitudinalAxis < 0 {
            newLong = centerCoordinate.longitude
            while newLong < Double(mapView.cameraView.localCenterCoordinate.longitude) {
                newLong += 360
            }
            centerCoordinate = CLLocationCoordinate2D(latitude: centerCoordinate.latitude, longitude: newLong)
        }
        // If it's positive, the map center needs to move west, and the opposite antimeridian adjustment is required
        else if offsetAlongLongitudinalAxis > 0 {
            newLong = centerCoordinate.longitude
            while newLong > Double(mapView.cameraView.localCenterCoordinate.longitude) {
                newLong -= 360
            }
            centerCoordinate = CLLocationCoordinate2D(latitude: centerCoordinate.latitude, longitude: newLong)
        }

        return centerCoordinate
    }

    /// Moves the viewpoint to a different location using a transition animation that
    /// evokes powered flight and an optional transition duration and timing function
    ///
    /// The transition animation seamlessly incorporates zooming and panning to help
    /// the user find his or her bearings even after traversing a great distance.
    ///
    /// - Parameters:
    ///   - camera: The camera options at the end of the animation. Any camera parameters that are nil will not be animated.
    ///   - duration: Duration of the animation, measured in seconds. If nil, a suitable calculated duration is used.
    ///   - completion: Completion handler called when the animation stops
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
     - Parameter animations: The block containing the animations. This block has no return value and takes no parameters. Use this block to modify any animatable view properties. When you start the animations, those properties are animated from their current values to the new values using the specified animation parameters.
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
     - Parameter animations: The block containing the animations. This block has no return value and takes no parameters. Use this block to modify any animatable view properties. When you start the animations, those properties are animated from their current values to the new values using the specified animation parameters.
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
     - Parameter animations: The block containing the animations. This block has no return value and takes no parameters. Use this block to modify any animatable view properties. When you start the animations, those properties are animated from their current values to the new values using the specified animation parameters.
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

    /**
     Convenience to create a `CameraAnimator` and will add it to a List of `CameraAnimators` to track the lifecycle of that animation

     - Parameter duration: The duration of the animation, in seconds.
     - Parameter delay: The number of seconds to wait before starting the animations. Specify 0 to begin the animations immediately.
     - Parameter options: The options to apply to the animations. You can specify most options, but transition-related options and options related to the animation direction are ignored.
     - Parameter animationOwner: Property that conforms to `AnimationOwnerProtocol` to represent who owns that animation.
     - Parameter animations: The block containing the animations. This block has no return value and takes no parameters. Use this block to modify any animatable view properties. When you start the animations, those properties are animated from their current values to the new values using the specified animation parameters.
     - Parameter completion: Completion block to be passed through for when an animation is stopped
     - Returns `CameraAnimator`: A class that represents an animator with the provided configuration.
     */
    public func runningCameraAnimator(duration: TimeInterval,
                                      delay: TimeInterval,
                                      options: UIView.AnimationOptions = [],
                                      animationOwner: AnimationOwner = .unspecified,
                                      animations: @escaping () -> Void,
                                      completion: AnimationCompletion? = nil) -> CameraAnimator {
        let runningAnimator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration,
                                                                             delay: delay,
                                                                             options: options,
                                                                             animations: animations,
                                                                             completion: nil)

        let cameraAnimator = CameraAnimator(delegate: self, propertyAnimator: runningAnimator, owner: animationOwner)

        runningAnimator.addCompletion({ [weak self] animatingPosition in
            guard let completion = completion,
                  let self = self
            else { return }

            self.schedulePendingCompletion(forAnimator: cameraAnimator, completion: completion, animatingPosition: animatingPosition)
        })
        cameraAnimators.add(cameraAnimator)
        return cameraAnimator
    }

    // MARK: CameraAnimatorDelegate functions
    func schedulePendingCompletion(forAnimator animator: CameraAnimator, completion: @escaping AnimationCompletion, animatingPosition: UIViewAnimatingPosition) {
        guard let mapView = mapView else { return }
        mapView.pendingAnimatorCompletionBlocks.append((completion, animatingPosition))
        removeAnimator(animator: animator)
    }

    func animatorIsFinished(forAnimator animator: CameraAnimator) {
        removeAnimator(animator: animator)
    }

    private func removeAnimator(animator: CameraAnimator) {
        if cameraAnimators.contains(animator) {
            cameraAnimators.remove(animator)
        }
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
