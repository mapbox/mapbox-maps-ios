import UIKit

internal protocol CameraAnimatorsFactoryProtocol: AnyObject {
    func makeFlyToAnimator(toCamera: CameraOptions,
                           duration: TimeInterval?,
                           curve: TimingCurve,
                           animationOwner: AnimationOwner) -> CameraAnimatorProtocol
    func makeBasicCameraAnimator(duration: TimeInterval,
                                 timingParameters: UITimingCurveProvider,
                                 animationOwner: AnimationOwner,
                                 animations: @escaping (inout CameraTransition) -> Void) -> BasicCameraAnimatorProtocol
    func makeBasicCameraAnimator(duration: TimeInterval,
                                 curve: UIView.AnimationCurve,
                                 animationOwner: AnimationOwner,
                                 animations: @escaping (inout CameraTransition) -> Void) -> BasicCameraAnimatorProtocol
    func makeBasicCameraAnimator(duration: TimeInterval,
                                 controlPoint1: CGPoint,
                                 controlPoint2: CGPoint,
                                 animationOwner: AnimationOwner,
                                 animations: @escaping (inout CameraTransition) -> Void) -> BasicCameraAnimatorProtocol
    func makeBasicCameraAnimator(duration: TimeInterval,
                                 dampingRatio: CGFloat,
                                 animationOwner: AnimationOwner,
                                 animations: @escaping (inout CameraTransition) -> Void) -> BasicCameraAnimatorProtocol
    func makeGestureDecelerationCameraAnimator(location: CGPoint,
                                               velocity: CGPoint,
                                               decelerationFactor: CGFloat,
                                               animationOwner: AnimationOwner,
                                               locationChangeHandler: @escaping (_ fromLocation: CGPoint, _ toLocation: CGPoint) -> Void) -> CameraAnimatorProtocol
    func makeSimpleCameraAnimator(from: CameraOptions,
                                  to: CameraOptions,
                                  duration: TimeInterval,
                                  curve: TimingCurve,
                                  owner: AnimationOwner) -> SimpleCameraAnimatorProtocol
}

internal final class CameraAnimatorsFactory: CameraAnimatorsFactoryProtocol {

    private let cameraViewContainerView: UIView
    private let mapboxMap: MapboxMapProtocol
    private let mainQueue: MainQueueProtocol
    private let dateProvider: DateProvider
    private let cameraOptionsInterpolator: CameraOptionsInterpolatorProtocol

    internal init(cameraViewContainerView: UIView,
                  mapboxMap: MapboxMapProtocol,
                  mainQueue: MainQueueProtocol,
                  dateProvider: DateProvider,
                  cameraOptionsInterpolator: CameraOptionsInterpolatorProtocol) {
        self.cameraViewContainerView = cameraViewContainerView
        self.mapboxMap = mapboxMap
        self.mainQueue = mainQueue
        self.dateProvider = dateProvider
        self.cameraOptionsInterpolator = cameraOptionsInterpolator
    }

    internal func makeFlyToAnimator(toCamera: CameraOptions,
                                    duration: TimeInterval?,
                                    curve: TimingCurve,
                                    animationOwner: AnimationOwner) -> CameraAnimatorProtocol {
        return FlyToCameraAnimator(
            toCamera: toCamera,
            duration: duration,
            curve: curve,
            owner: animationOwner,
            mapboxMap: mapboxMap,
            mainQueue: mainQueue,
            dateProvider: dateProvider)
    }

    internal func makeBasicCameraAnimator(duration: TimeInterval,
                                          timingParameters: UITimingCurveProvider,
                                          animationOwner: AnimationOwner,
                                          animations: @escaping (inout CameraTransition) -> Void) -> BasicCameraAnimatorProtocol {
        let propertyAnimator = UIViewPropertyAnimator(
            duration: duration,
            timingParameters: timingParameters)
        return makeBasicCameraAnimator(
            propertyAnimator: propertyAnimator,
            animationOwner: animationOwner,
            animations: animations)
    }

    internal func makeBasicCameraAnimator(duration: TimeInterval,
                                          curve: UIView.AnimationCurve,
                                          animationOwner: AnimationOwner,
                                          animations: @escaping (inout CameraTransition) -> Void) -> BasicCameraAnimatorProtocol {
        let propertyAnimator = UIViewPropertyAnimator(
            duration: duration,
            curve: curve)
        return makeBasicCameraAnimator(
            propertyAnimator: propertyAnimator,
            animationOwner: animationOwner,
            animations: animations)
    }

    internal func makeBasicCameraAnimator(duration: TimeInterval,
                                          controlPoint1: CGPoint,
                                          controlPoint2: CGPoint,
                                          animationOwner: AnimationOwner,
                                          animations: @escaping (inout CameraTransition) -> Void) -> BasicCameraAnimatorProtocol {
        let propertyAnimator = UIViewPropertyAnimator(
            duration: duration,
            controlPoint1: controlPoint1,
            controlPoint2: controlPoint2)
        return makeBasicCameraAnimator(
            propertyAnimator: propertyAnimator,
            animationOwner: animationOwner,
            animations: animations)
    }

    internal func makeBasicCameraAnimator(duration: TimeInterval,
                                          dampingRatio: CGFloat,
                                          animationOwner: AnimationOwner,
                                          animations: @escaping (inout CameraTransition) -> Void) -> BasicCameraAnimatorProtocol {
        let propertyAnimator = UIViewPropertyAnimator(
            duration: duration,
            dampingRatio: dampingRatio)
        return makeBasicCameraAnimator(
            propertyAnimator: propertyAnimator,
            animationOwner: animationOwner,
            animations: animations)
    }

    private func makeBasicCameraAnimator(propertyAnimator: UIViewPropertyAnimator,
                                         animationOwner: AnimationOwner,
                                         animations: @escaping (inout CameraTransition) -> Void) -> BasicCameraAnimatorProtocol {
        let cameraView = CameraView()
        cameraViewContainerView.addSubview(cameraView)
        let cameraAnimator = BasicCameraAnimatorImpl(
            propertyAnimator: propertyAnimator,
            owner: animationOwner,
            mapboxMap: mapboxMap,
            mainQueue: mainQueue,
            cameraView: cameraView,
            animation: animations)
        return cameraAnimator
    }

    internal func makeGestureDecelerationCameraAnimator(location: CGPoint,
                                                        velocity: CGPoint,
                                                        decelerationFactor: CGFloat,
                                                        animationOwner: AnimationOwner,
                                                        locationChangeHandler: @escaping (_ fromLocation: CGPoint, _ toLocation: CGPoint) -> Void) -> CameraAnimatorProtocol {
        return GestureDecelerationCameraAnimator(
            location: location,
            velocity: velocity,
            decelerationFactor: decelerationFactor,
            owner: animationOwner,
            locationChangeHandler: locationChangeHandler,
            mainQueue: mainQueue,
            dateProvider: dateProvider)
    }

    internal func makeSimpleCameraAnimator(from: CameraOptions,
                                           to: CameraOptions,
                                           duration: TimeInterval,
                                           curve: TimingCurve,
                                           owner: AnimationOwner) -> SimpleCameraAnimatorProtocol {
        return SimpleCameraAnimator(
            from: from,
            to: to,
            duration: duration,
            curve: curve,
            owner: owner,
            mapboxMap: mapboxMap,
            mainQueue: mainQueue,
            cameraOptionsInterpolator: cameraOptionsInterpolator,
            dateProvider: dateProvider)
    }
}
