import UIKit

// MARK: Camera Animation
extension CameraManager: CameraAnimatorDelegate {

    // MARK: Animator Functions

    /// Convenience to create a `CameraAnimator` and will add it to a list of `CameraAnimators` to track the lifecycle of that animation.
    ///
    /// NOTE: Keep in mind the lifecycle of a `CameraAnimator`. If a `CameraAnimator` is destroyed, before the animation is finished,
    /// the animation will be interrupted and completion handlers will be called.
    ///
    /// - Parameters:
    ///   - duration: The duration of the animation, in seconds.
    ///   - timingParameters: The object providing the timing information. This object must adopt the `UITimingCurveProvider` protocol.
    ///   - animationOwner: Property that conforms to `AnimationOwnerProtocol` to represent who owns that animation.
    /// - Returns: A class that represents an animator with the provided configuration.
    public func makeCameraAnimator(duration: TimeInterval,
                                   timingParameters parameters: UITimingCurveProvider,
                                   animationOwner: AnimationOwner = .unspecified,
                                   animations: @escaping CameraAnimation) -> CameraAnimator {
        let propertyAnimator = UIViewPropertyAnimator(duration: duration, timingParameters: parameters)
        let cameraAnimator = CameraAnimator(delegate: self, propertyAnimator: propertyAnimator, owner: animationOwner)
        cameraAnimator.addAnimations(animations)
        mapView?.cameraAnimatorsHashTable.add(cameraAnimator)
        return cameraAnimator
    }

    /// Convenience to create a `CameraAnimator` and will add it to a list of `CameraAnimators` to track the lifecycle of that animation.
    ///
    /// NOTE: Keep in mind the lifecycle of a `CameraAnimator`. If a `CameraAnimator` is destroyed, before the animation is finished,
    /// the animation will be interrupted and completion handlers will be called.
    ///
    /// - Parameters:
    ///   - duration: The duration of the animation, in seconds.
    ///   - curve: The UIKit timing curve to apply to the animation.
    ///   - animationOwner: Property that conforms to `AnimationOwnerProtocol` to represent who owns that animation.
    ///   - animations: The block containing the animations. This block has no return value and takes no parameters.
    ///                 Use this block to modify any animatable view properties. When you start the animations,
    ///                 those properties are animated from their current values to the new values using the specified animation parameters.
    /// - Returns: A class that represents an animator with the provided configuration.
    public func makeCameraAnimator(duration: TimeInterval,
                                   curve: UIView.AnimationCurve,
                                   animationOwner: AnimationOwner = .unspecified,
                                   animations: @escaping CameraAnimation) -> CameraAnimator {
        let propertyAnimator = UIViewPropertyAnimator(duration: duration, curve: curve)
        let cameraAnimator = CameraAnimator(delegate: self, propertyAnimator: propertyAnimator, owner: animationOwner)
        cameraAnimator.addAnimations(animations)
        mapView?.cameraAnimatorsHashTable.add(cameraAnimator)
        return cameraAnimator
    }

    /// Convenience to create a `CameraAnimator` and will add it to a list of `CameraAnimators` to track the lifecycle of that animation.
    ///
    /// NOTE: Keep in mind the lifecycle of a `CameraAnimator`. If a `CameraAnimator` is destroyed, before the animation is finished,
    /// the animation will be interrupted and completion handlers will be called.
    ///
    /// - Parameters:
    ///   - duration: The duration of the animation, in seconds.
    ///   - controlPoint1: The first control point for the cubic Bézier timing curve.
    ///   - controlPoint2: The second control point for the cubic Bézier timing curve.
    ///   - animationOwner: Property that conforms to `AnimationOwnerProtocol` to represent who owns that animation.
    ///   - animations: The block containing the animations. This block has no return value and takes no parameters.
    ///                 Use this block to modify any animatable view properties. When you start the animations,
    ///                 those properties are animated from their current values to the new values using the specified animation parameters.
    /// - Returns: A class that represents an animator with the provided configuration.
    public func makeCameraAnimator(duration: TimeInterval,
                                   controlPoint1 point1: CGPoint,
                                   controlPoint2 point2: CGPoint,
                                   animationOwner: AnimationOwner = .unspecified,
                                   animations: @escaping CameraAnimation) -> CameraAnimator {
        let propertyAnimator = UIViewPropertyAnimator(duration: duration, controlPoint1: point1, controlPoint2: point2)
        let cameraAnimator = CameraAnimator(delegate: self, propertyAnimator: propertyAnimator, owner: animationOwner)
        cameraAnimator.addAnimations(animations)
        mapView?.cameraAnimatorsHashTable.add(cameraAnimator)
        return cameraAnimator
    }

    /// Convenience to create a `CameraAnimator` and will add it to a list of `CameraAnimators` to track the lifecycle of that animation.
    ///
    /// NOTE: Keep in mind the lifecycle of a `CameraAnimator`. If a `CameraAnimator` is destroyed, before the animation is finished,
    /// the animation will be interrupted and completion handlers will be called.
    ///
    /// - Parameters:
    ///   - duration: The duration of the animation, in seconds.
    ///   - dampingRatio: The damping ratio to apply to the initial acceleration and oscillation. To smoothly decelerate the animation without oscillation, specify a value of 1.
    ///                   Specify values closer to 0 to create less damping and more oscillation.
    ///   - animationOwner: Property that conforms to `AnimationOwnerProtocol` to represent who owns that animation.
    ///   - animations: The block containing the animations. This block has no return value and takes no parameters.
    ///                 Use this block to modify any animatable view properties. When you start the animations,
    ///                 those properties are animated from their current values to the new values using the specified animation parameters.
    /// - Returns: A class that represents an animator with the provided configuration.
    public func makeCameraAnimator(duration: TimeInterval,
                                   dampingRatio ratio: CGFloat,
                                   animationOwner: AnimationOwner = .unspecified,
                                   animations: @escaping CameraAnimation) -> CameraAnimator {
        let propertyAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: ratio)
        let cameraAnimator = CameraAnimator(delegate: self, propertyAnimator: propertyAnimator, owner: animationOwner)
        cameraAnimator.addAnimations(animations)
        mapView?.cameraAnimatorsHashTable.add(cameraAnimator)
        return cameraAnimator
    }

    // MARK: CameraAnimatorDelegate functions
    func schedulePendingCompletion(forAnimator animator: CameraAnimatorProtocol, completion: @escaping AnimationCompletion, animatingPosition: UIViewAnimatingPosition) {
        guard let mapView = mapView else { return }
        mapView.pendingAnimatorCompletionBlocks.append((completion, animatingPosition))
    }

    var camera: CameraOptions {
        guard let validMapView = mapView else {
            fatalError("MapView cannot be nil.")
        }

        return validMapView.cameraOptions
    }

    func jumpTo(camera: CameraOptions) {
        guard let validMapView = mapView else {
            fatalError("MapView cannot be nil.")
        }

        let mbxCameraOptions = MapboxCoreMaps.CameraOptions(camera)
        validMapView.mapboxMap.__map.setCameraFor(mbxCameraOptions)
    }

    func addViewToViewHeirarchy(_ view: CameraView) {

        guard let validMapView = mapView else {
            fatalError("MapView cannot be nil.")
        }

        validMapView.addSubview(view)

    }

    func anchorAfterPadding() -> CGPoint {

        guard let validMapView = mapView else {
            fatalError("MapView cannot be nil.")
        }

        return validMapView.anchor
    }
}
