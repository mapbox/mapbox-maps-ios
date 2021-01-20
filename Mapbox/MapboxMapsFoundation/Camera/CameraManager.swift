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
    public var mapCameraOptions: MapCameraOptions!

    /// Used to update the map's camera options and pass them to the core Map.
    public func updateMapCameraOptions(newOptions: MapCameraOptions) {
        let boundOptions = BoundOptions(__bounds: newOptions.restrictedCoordinateBounds ?? nil,
                                        maxZoom: newOptions.maximumZoomLevel as NSNumber,
                                        minZoom: newOptions.minimumZoomLevel as NSNumber,
                                        maxPitch: newOptions.maximumPitch as NSNumber,
                                        minPitch: newOptions.minimumPitch as NSNumber)
        try! mapView?.__map.setBoundsFor(boundOptions)
        self.mapCameraOptions = newOptions
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

    public func setCamera(to newCamera: CameraOptions,
                             animated: Bool = false,
                             duration: TimeInterval? = 0,
                             completion: ((Bool) -> Void)?) {
        guard let mapView = mapView else {
            assertionFailure("MapView is nil.")
            completion?(false)
            return
        }

        guard mapView.cameraView.camera != newCamera else {
            completion?(true)
            return
        }

        let animation = {
            mapView.cameraView.camera = newCamera
        }

        performCameraAnimation(animated: animated, duration: duration, animation: animation, completion: completion)
    }

    // swiftlint:disable function_parameter_count
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
                          duration: TimeInterval? = nil,
                          completion: ((Bool) -> Void)? = nil) {
        guard let mapView = mapView else {
            assertionFailure("MapView is nil.")
            completion?(false)
            return
        }

        let clampedZoom: CGFloat? = zoom?.clamp(withMax: mapCameraOptions.maximumZoomLevel,
                                                andMin: mapCameraOptions.minimumZoomLevel)

        let newCamera = CameraOptions(center: centerCoordinate,
                                      padding: padding,
                                      anchor: anchor,
                                      zoom: clampedZoom,
                                      bearing: bearing,
                                      pitch: pitch)

        guard mapView.cameraView.camera != newCamera else { return }

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
    fileprivate func performCameraAnimation(animated: Bool, duration: TimeInterval?, animation: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        if animated {
            UIView.animate(withDuration: duration ?? 0,
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
        self.setCamera(to: defaultOptions, completion: nil)
    }

    /**
     Resets the map rotation to a north bearing of `0` degrees.

     - Parameter animated: A boolean indicating if the change should be animated.
     By default, this value is `false`.
     */
    public func resetNorth(_ animated: Bool = false) {
        self.setCamera(bearing: CLLocationDirection(northBearing),
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
        self.transitionCoordinateBounds(to: newCoordinateBounds,
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

        self.transitionVisibleCoordinates(to: [southeast, southwest, northwest, northeast],
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
        self.transitionVisibleCoordinates(to: newCoordinates,
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
     */
    public func moveCamera(by offset: CGPoint? = nil, rotation: CGFloat? = nil, pitch: CGFloat? = nil, zoom: CGFloat? = nil, animated: Bool = false) {
        guard let mapView = mapView else {
            assertionFailure("MapView is nil.")
            return
        }

        let centerCoordinate = self.shiftCenterCoordinate(by: offset ?? .zero)

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
            if let cameraLayer = mapView.cameraView.layer as? CameraLayer {
                // Check whether each value has been updated before adding to the block
                if offset != nil {
                    cameraLayer.centerCoordinateLatitude = CGFloat(centerCoordinate.latitude)
                    cameraLayer.centerCoordinateLongitude = CGFloat(centerCoordinate.longitude)
                }

                if rotation != nil {
                    cameraLayer.bearing = newBearing
                }

                if pitch != nil {
                    cameraLayer.pitch = newPitch
                }

                if zoom != nil {
                    cameraLayer.zoom = newZoom
                }
            }
        }

        performCameraAnimation(animated: animated, duration: Double(mapCameraOptions.decelerationRate), animation: animation)
    }

    /**
     Return a new center coordinate shifted by a given offset value.
     - Parameter offset: The `CGPoint` value to shift the map's center by.
     */
    func shiftCenterCoordinate(by offset: CGPoint) -> CLLocationCoordinate2D {
        guard let mapView = mapView else {
            assertionFailure("MapView is nil.")
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
        guard let cameraLayer = mapView.cameraView.layer as? CameraLayer else {
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }

        let cameraViewSize    = mapView.cameraView.frame.size
        let cameraPadding     = mapView.cameraView.padding
        let viewPortSize      = CGSize(width: cameraViewSize.width - cameraPadding.left - cameraPadding.right,
                                       height: cameraViewSize.height - cameraPadding.top - cameraPadding.bottom)
        let viewPortCenter    = CGPoint(x: (viewPortSize.width / 2) + cameraPadding.left,
                                        y: (viewPortSize.height / 2) + cameraPadding.top)
        let newViewPortCenter = CGPoint(x: viewPortCenter.x - offset.x, y: viewPortCenter.y - offset.y)
        var centerCoordinate  = mapView.coordinate(for: newViewPortCenter)

        var newLong: Double

        // This logic is to prevent a rubber band effect when a pan's drift takes you across the antimeridian.
        if offset.x < 0 {
            newLong = centerCoordinate.longitude
            while newLong < Double(cameraLayer.centerCoordinateLongitude) {
                newLong += 360
            }
            centerCoordinate = CLLocationCoordinate2D(latitude: centerCoordinate.latitude, longitude: newLong)
        } else if offset.x > 0 {
            newLong = centerCoordinate.longitude
            while newLong > Double(cameraLayer.centerCoordinateLongitude) {
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
    ///   - camera: The camera at the end of the animation. Any camera parameters that are nil will not be animated.
    ///   - duration: Duration of the animation, measured in seconds. If nil, a suitable calculated duration is used.
    ///   - timingFunction: Timing function, defaults to "ease out"
    ///   - completion: Completion handler called when the animation stops
    public func fly(to camera: CameraOptions, duration: TimeInterval? = nil, timingFunction: CAMediaTimingFunction = CAMediaTimingFunction(name: .easeOut), completion: ((Bool) -> Void)? = nil) {
        guard let mapView = mapView else {
            assertionFailure("MapView is nil.")
            completion?(false)
            return
        }

        guard let flyTo = FlyToInterpolator(from: mapView.cameraView.camera,
                                      to: camera,
                                      size: mapView.bounds.size) else {
            completion?(false)
            assertionFailure("FlyToInterpolator could not be created.")
            return
        }

        var time = duration ?? -1.0

        // If there was no duration specified, or a negative argument, use a default
        if time < 0.0 {
            time = flyTo.duration()
        }

        guard time > 0.0 else {
            setCamera(to: camera, completion: completion)
            return
        }

        // TODO: Consider timesteps based on the flyTo curve, for example, it would be beneficial to have a higher
        // density of time steps at towards the start and end of the animation to avoid jiggling.
        let timeSteps = stride(from: 0.0, through: 1.0, by: 0.025)
        let keyTimes: [NSNumber] = Array(timeSteps).map {
            NSNumber(floatLiteral: $0)
        }

        var animations: [CAAnimation] = []

        if camera.zoom != nil {
            let zoomLevels: [Double] = keyTimes.map { (number) -> Double in
                return flyTo.zoom(at: number.doubleValue)
            }

            let zoomAnimation = CAKeyframeAnimation(keyPath: "zoom")
            zoomAnimation.keyTimes              = keyTimes
            zoomAnimation.values                = zoomLevels
            zoomAnimation.duration              = time
            zoomAnimation.isAdditive            = false
            zoomAnimation.calculationMode       = .cubic
            zoomAnimation.isRemovedOnCompletion = false
            zoomAnimation.fillMode              = .forwards

            animations.append(zoomAnimation)
        }

        if camera.center != nil {
            let coords: [CLLocationCoordinate2D] = keyTimes.map { (number) -> CLLocationCoordinate2D in
                return flyTo.coordinate(at: number.doubleValue)
            }

            let latitudes = coords.map {
                $0.latitude
            }

            let longitudes = coords.map {
                $0.longitude
            }

            let centerAnimationLatitude = CAKeyframeAnimation(keyPath: "centerCoordinateLatitude")
            centerAnimationLatitude.keyTimes              = keyTimes
            centerAnimationLatitude.values                = latitudes
            centerAnimationLatitude.duration              = time
            centerAnimationLatitude.isAdditive            = false
            centerAnimationLatitude.calculationMode       = .cubic
            centerAnimationLatitude.isRemovedOnCompletion = false
            centerAnimationLatitude.fillMode              = .forwards

            let centerAnimationLongitude = CAKeyframeAnimation(keyPath: "centerCoordinateLongitude")
            centerAnimationLongitude.keyTimes              = keyTimes
            centerAnimationLongitude.values                = longitudes
            centerAnimationLongitude.duration              = time
            centerAnimationLongitude.isAdditive            = false
            centerAnimationLongitude.calculationMode       = .cubic
            centerAnimationLongitude.isRemovedOnCompletion = false
            centerAnimationLongitude.fillMode              = .forwards

            animations.append(contentsOf: [centerAnimationLatitude, centerAnimationLongitude])
        }

        if camera.bearing != nil {
            // Note - these are NOT using CAKeyframeAnimation
            let bearingAnimation = CABasicAnimation(keyPath: "bearing")
            bearingAnimation.toValue               = flyTo.destBearing
            bearingAnimation.duration              = time
            bearingAnimation.beginTime             = 0.0
            bearingAnimation.isRemovedOnCompletion = false
            bearingAnimation.fillMode              = .forwards

            animations.append(bearingAnimation)
        }

        if camera.pitch != nil {
            let pitchAnimation = CABasicAnimation(keyPath: "pitch")
            pitchAnimation.toValue               = flyTo.destPitch
            pitchAnimation.duration              = time
            pitchAnimation.beginTime             = 0.0
            pitchAnimation.isRemovedOnCompletion = false
            pitchAnimation.fillMode              = .forwards

            animations.append(pitchAnimation)
        }

        let animationKey = String( camera.hashValue)
        let cameraLayer = mapView.cameraView.layer
        let animationGroup = MapboxAnimationGroup()
        animationGroup.duration       = time
        animationGroup.animations     = animations
        animationGroup.fillMode       = .forwards
        animationGroup.timingFunction = timingFunction

        /// Setting `isRemovedOnCompletion` to `true` causes
        /// the camera to reset at the end of the animation.
        animationGroup.isRemovedOnCompletion = false

        /// Remove the animation group once the animation is done.
        animationGroup.completionBlock = { [weak cameraLayer] finished in
            cameraLayer?.removeAnimation(forKey: animationKey)

            // Temp?
            self.setCamera(to: camera, completion: completion)
        }

        animationGroup.delegate = animationGroup
        cameraLayer.add(animationGroup, forKey: animationKey)
    }
}

internal class MapboxAnimationGroup: CAAnimationGroup {
    fileprivate var completionBlock: ((Bool) -> Void)?
}

extension MapboxAnimationGroup: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {

        if let executeBlock = completionBlock {
            executeBlock(flag)
        }
    }
}

internal extension CGFloat {
    func clamp(withMax max: CGFloat, andMin min: CGFloat) -> CGFloat {
        if self > max {
            return max
        }

        if self < min {
            return min
        }
        return self
    }
}

fileprivate extension CoordinateBounds {
    func contains(_ coordinates: [CLLocationCoordinate2D]) -> Bool {
        let latitudeRange = self.southwest.latitude...self.northeast.latitude
        let longitudeRange = self.southwest.longitude...self.northeast.longitude

        for coordinate in coordinates {
            if latitudeRange.contains(coordinate.latitude) || longitudeRange.contains(coordinate.longitude) {
                return true
            }
        }
        return false
    }
}
