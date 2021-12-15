import UIKit

public final class EaseToViewportTransition {

    public let duration: TimeInterval
    public let curve: UIView.AnimationCurve

    private let cameraAnimationsManager: CameraAnimationsManagerProtocol

    internal init(duration: TimeInterval,
                  curve: UIView.AnimationCurve,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol) {
        self.duration = duration
        self.curve = curve
        self.cameraAnimationsManager = cameraAnimationsManager
    }
}

extension EaseToViewportTransition: ViewportTransition {
    public func run(from: ViewportState?, to: ViewportState, completion: @escaping (Bool) -> Void) -> Cancelable {
        let resultCancelable = CompositeCancelable()
        var observeCameraComplete = false
        resultCancelable.add(to.observeCamera { [cameraAnimationsManager, duration, curve] cameraOptions in
            // the force-unwrap below is safe. ease(to:) always returns non-nil Cancelable.
            // we should update its signature accordingly in the next major version.
            resultCancelable.add(cameraAnimationsManager.ease(
                to: cameraOptions,
                duration: duration,
                curve: curve) { position in
                    completion(position == .end)
                }!)
            observeCameraComplete = true
            // stop receiving updates (ignore moving targets)
            return false
        })
        // we still have to call the completion block if the transition is canceled while waiting for the to camera.
        // if it's canceled during the animation, the basic camera animator's completion block will be invoked.
        resultCancelable.add(BlockCancelable {
            if !observeCameraComplete {
                completion(false)
            }
        })
        return resultCancelable
    }
}
