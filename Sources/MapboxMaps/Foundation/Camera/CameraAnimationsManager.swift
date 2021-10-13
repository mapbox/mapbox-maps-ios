import UIKit
@_implementationOnly import MapboxCommon_Private

internal protocol CameraAnimationsManagerProtocol: AnyObject {
    @discardableResult
    func ease(to camera: CameraOptions,
              duration: TimeInterval,
              curve: UIView.AnimationCurve,
              completion: AnimationCompletion?) -> Cancelable?

    func decelerate(location: CGPoint,
                    velocity: CGPoint,
                    decelerationFactor: CGFloat,
                    locationChangeHandler: @escaping (CGPoint) -> Void,
                    completion: @escaping () -> Void)

    func cancelAnimations()

    var animationsEnabled: Bool { get set }
}

/// An object that manages a camera's view lifecycle.
public class CameraAnimationsManager: CameraAnimationsManagerProtocol {

    /// List of animators currently alive
    public var cameraAnimators: [CameraAnimator] {
        return cameraAnimatorsSet.allObjects
    }

    /// Pointer HashTable for holding camera animators
    private var cameraAnimatorsSet = WeakSet<CameraAnimatorInterface>()

    private var runningCameraAnimators = [CameraAnimator]()

    /// Internal camera animator used for animated transition
    internal var internalAnimator: CameraAnimator?

    /// May want to convert to an enum.
    fileprivate let northBearing: CGFloat = 0

    internal var animationsEnabled: Bool = true

    private let cameraViewContainerView: UIView

    private let mapboxMap: MapboxMapProtocol

    internal init(cameraViewContainerView: UIView, mapboxMap: MapboxMapProtocol) {
        self.cameraViewContainerView = cameraViewContainerView
        self.mapboxMap = mapboxMap
    }

    internal func update() {
        guard animationsEnabled else {
            cancelAnimations()
            return
        }
        for animator in cameraAnimatorsSet.allObjects {
            animator.update()
        }
    }

    // MARK: Setting a new camera

    /// Interrupts all `active` animation.
    /// The camera remains at the last point before the cancel request was invoked, i.e.,
    /// the camera is not reset or fast-forwarded to the end of the transition.
    /// Canceled animations cannot be restarted / resumed. The animator must be recreated.
    public func cancelAnimations() {
        for animator in cameraAnimators where animator.state == .active {
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

        guard let flyToAnimator = FlyToCameraAnimator(
                initial: mapboxMap.cameraState,
                final: camera,
                cameraBounds: mapboxMap.cameraBounds,
                owner: AnimationOwner(rawValue: "com.mapbox.maps.cameraAnimationsManager.flyToAnimator"),
                duration: duration,
                mapSize: mapboxMap.size,
                mapboxMap: mapboxMap,
                dateProvider: DefaultDateProvider(),
                delegate: self) else {
            Log.warning(forMessage: "Unable to start fly-to animation", category: "CameraManager")
            return nil
        }

        // Stop the `internalAnimator` before beginning a `flyTo`
        internalAnimator?.stopAnimation()

        cameraAnimatorsSet.add(flyToAnimator)

        flyToAnimator.addCompletion { [weak self, weak flyToAnimator] (position) in
            if self?.internalAnimator === flyToAnimator {
                self?.internalAnimator = nil
            }
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
        animator.addCompletion { [weak self, weak animator] (position) in
            if self?.internalAnimator === animator {
                self?.internalAnimator = nil
            }
            completion?(position)
        }

        animator.startAnimation()
        internalAnimator = animator

        return internalAnimator
    }

    // MARK: Animator Functions

    /// Convenience to create a `BasicCameraAnimator` and will add it to a list of `BasicCameraAnimator`s to track the lifecycle of that animation.
    ///
    /// NOTE: Keep in mind the lifecycle of a `BasicCameraAnimator`. If a `BasicCameraAnimator` is destroyed, before the animation is finished,
    /// the animation will be interrupted and completion handlers will not be called.
    ///
    /// - Parameters:
    ///   - duration: The duration of the animation, in seconds.
    ///   - timingParameters: The object providing the timing information. This object must adopt the `UITimingCurveProvider` protocol.
    ///   - animationOwner: Property that conforms to `AnimationOwner` to represent who owns that animation.
    /// - Returns: A class that represents an animator with the provided configuration.
    public func makeAnimator(duration: TimeInterval,
                             timingParameters parameters: UITimingCurveProvider,
                             animationOwner: AnimationOwner = .unspecified,
                             animations: @escaping (inout CameraTransition) -> Void) -> BasicCameraAnimator {
        let propertyAnimator = UIViewPropertyAnimator(duration: duration, timingParameters: parameters)
        let cameraAnimator = BasicCameraAnimator(
            propertyAnimator: propertyAnimator,
            owner: animationOwner,
            mapboxMap: mapboxMap,
            cameraView: makeCameraView(),
            delegate: self)
        cameraAnimator.addAnimations(animations)
        cameraAnimatorsSet.add(cameraAnimator)
        return cameraAnimator
    }

    /// Convenience to create a `BasicCameraAnimator` and will add it to a list of `BasicCameraAnimator` to track the lifecycle of that animation.
    ///
    /// NOTE: Keep in mind the lifecycle of a `BasicCameraAnimator`. If a `BasicCameraAnimator` is destroyed, before the animation is finished,
    /// the animation will be interrupted and completion handlers will not be called.
    ///
    /// - Parameters:
    ///   - duration: The duration of the animation, in seconds.
    ///   - curve: The UIKit timing curve to apply to the animation.
    ///   - animationOwner: Property that conforms to `AnimationOwner` to represent who owns that animation.
    ///   - animations: The block containing the animations. This block has no return value and takes no parameters.
    ///                 Use this block to modify any animatable view properties. When you start the animations,
    ///                 those properties are animated from their current values to the new values using the specified animation parameters.
    /// - Returns: A class that represents an animator with the provided configuration.
    public func makeAnimator(duration: TimeInterval,
                             curve: UIView.AnimationCurve,
                             animationOwner: AnimationOwner = .unspecified,
                             animations: @escaping (inout CameraTransition) -> Void) -> BasicCameraAnimator {
        let propertyAnimator = UIViewPropertyAnimator(duration: duration, curve: curve)
        let cameraAnimator = BasicCameraAnimator(
            propertyAnimator: propertyAnimator,
            owner: animationOwner,
            mapboxMap: mapboxMap,
            cameraView: makeCameraView(),
            delegate: self)
        cameraAnimator.addAnimations(animations)
        cameraAnimatorsSet.add(cameraAnimator)
        return cameraAnimator
    }

    /// Convenience to create a `BasicCameraAnimator` and will add it to a list of `BasicCameraAnimator` to track the lifecycle of that animation.
    ///
    /// NOTE: Keep in mind the lifecycle of a `BasicCameraAnimator`. If a `BasicCameraAnimator` is destroyed, before the animation is finished,
    /// the animation will be interrupted and completion handlers will not be called.
    ///
    /// - Parameters:
    ///   - duration: The duration of the animation, in seconds.
    ///   - controlPoint1: The first control point for the cubic Bézier timing curve.
    ///   - controlPoint2: The second control point for the cubic Bézier timing curve.
    ///   - animationOwner: Property that conforms to `AnimationOwner` to represent who owns that animation.
    ///   - animations: The block containing the animations. This block has no return value and takes no parameters.
    ///                 Use this block to modify any animatable view properties. When you start the animations,
    ///                 those properties are animated from their current values to the new values using the specified animation parameters.
    /// - Returns: A class that represents an animator with the provided configuration.
    public func makeAnimator(duration: TimeInterval,
                             controlPoint1 point1: CGPoint,
                             controlPoint2 point2: CGPoint,
                             animationOwner: AnimationOwner = .unspecified,
                             animations: @escaping (inout CameraTransition) -> Void) -> BasicCameraAnimator {
        let propertyAnimator = UIViewPropertyAnimator(duration: duration, controlPoint1: point1, controlPoint2: point2)
        let cameraAnimator = BasicCameraAnimator(
            propertyAnimator: propertyAnimator,
            owner: animationOwner,
            mapboxMap: mapboxMap,
            cameraView: makeCameraView(),
            delegate: self)
        cameraAnimator.addAnimations(animations)
        cameraAnimatorsSet.add(cameraAnimator)
        return cameraAnimator
    }

    /// Convenience to create a `BasicCameraAnimator` and will add it to a list of `BasicCameraAnimator` to track the lifecycle of that animation.
    ///
    /// NOTE: Keep in mind the lifecycle of a `BasicCameraAnimator`. If a `BasicCameraAnimator` is destroyed, before the animation is finished,
    /// the animation will be interrupted and completion handlers will not be called.
    ///
    /// - Parameters:
    ///   - duration: The duration of the animation, in seconds.
    ///   - dampingRatio: The damping ratio to apply to the initial acceleration and oscillation. To smoothly decelerate the animation without oscillation, specify a value of 1.
    ///                   Specify values closer to 0 to create less damping and more oscillation.
    ///   - animationOwner: Property that conforms to `AnimationOwner` to represent who owns that animation.
    ///   - animations: The block containing the animations. This block has no return value and takes no parameters.
    ///                 Use this block to modify any animatable view properties. When you start the animations,
    ///                 those properties are animated from their current values to the new values using the specified animation parameters.
    /// - Returns: A class that represents an animator with the provided configuration.
    public func makeAnimator(duration: TimeInterval,
                             dampingRatio ratio: CGFloat,
                             animationOwner: AnimationOwner = .unspecified,
                             animations: @escaping (inout CameraTransition) -> Void) -> BasicCameraAnimator {
        let propertyAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: ratio)
        let cameraAnimator = BasicCameraAnimator(
            propertyAnimator: propertyAnimator,
            owner: animationOwner,
            mapboxMap: mapboxMap,
            cameraView: makeCameraView(),
            delegate: self)
        cameraAnimator.addAnimations(animations)
        cameraAnimatorsSet.add(cameraAnimator)
        return cameraAnimator
    }

    private func makeCameraView() -> CameraView {
        let cameraView = CameraView()
        cameraViewContainerView.addSubview(cameraView)
        return cameraView
    }

    /// This function will handle the natural decelration of a gesture when there is a velocity provided. A use case for this is the pan gesture.
    /// - Parameters:
    ///   - location: Current location of center coordinate
    ///   - velocity: The speed at which the map should move over time
    ///   - decelerationFactor: A multiplication factor that determines the speed at which the velocity should slow down.
    ///   - locationChangeHandler: Change handler to be passed through to the animator
    ///   - completion: Completion to be called after animation has finished
    internal func decelerate(location: CGPoint,
                             velocity: CGPoint,
                             decelerationFactor: CGFloat,
                             locationChangeHandler: @escaping (CGPoint) -> Void,
                             completion: @escaping () -> Void) {

        // Stop the `internalAnimator` before beginning a deceleration
        internalAnimator?.stopAnimation()

        let decelerateAnimator = GestureDecelerationCameraAnimator(
            location: location,
            velocity: velocity,
            decelerationFactor: decelerationFactor,
            locationChangeHandler: locationChangeHandler,
            dateProvider: DefaultDateProvider(),
            delegate: self)

        decelerateAnimator.completion = { [weak self, weak decelerateAnimator] in
           if self?.internalAnimator === decelerateAnimator {
               self?.internalAnimator = nil
           }
           completion()
        }

        cameraAnimatorsSet.add(decelerateAnimator)
        decelerateAnimator.startAnimation()
        internalAnimator = decelerateAnimator
    }
}

internal extension CameraAnimationsManager: CameraAnimatorDelegate {
    /// When an animator starts running, `CameraAnimationsManager` takes a strong reference to it
    /// so that it stays alive while it is running. It also calls `beginAnimation` on `MapboxMap`.
    ///
    /// This solution replaces a previous implementation in which each animator was responsible for
    /// keeping itself alive while it was running (if desired). That approach was problematic because
    /// it was possible for it to result in a memory leak if the owning `MapView` (and corresponding display
    /// link) was deallocated, resulting in no more calls to `update()` which would prevent some
    /// animators from ever breaking their strong self references.
    ///
    /// Moving this responsibility to `CameraAnimationsManager` means that if the `MapView` is
    /// deallocated, these strong references will be released as well.
    func cameraAnimatorDidStartRunning(_ cameraAnimator: CameraAnimator) {
        if !runningCameraAnimators.contains(where: { $0 === cameraAnimator }) {
            runningCameraAnimators.append(cameraAnimator)
            mapboxMap.beginAnimation()
        }
    }

    /// When an animator stops running, `CameraAnimationsManager` releases its strong reference to
    /// it so that it can be deinited if there are no other owning references. It also calls `endAnimation`
    /// on `MapboxMap`.
    ///
    /// See `cameraAnimatorDidStartRunning(_:)` for further discussion of the rationale for this
    /// architecture.
    func cameraAnimatorDidStopRunning(_ cameraAnimator: CameraAnimator) {
        if runningCameraAnimators.contains(where: { $0 === cameraAnimator }) {
            runningCameraAnimators.removeAll { $0 === cameraAnimator }
            mapboxMap.endAnimation()
        }
    }
}
