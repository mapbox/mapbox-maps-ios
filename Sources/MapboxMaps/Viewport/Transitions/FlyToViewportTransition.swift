import UIKit

public final class FlyToViewportTransition {

    public let duration: TimeInterval?

    private let cameraAnimationsManager: CameraAnimationsManagerProtocol

    internal init(duration: TimeInterval?,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol) {
        self.duration = duration
        self.cameraAnimationsManager = cameraAnimationsManager
    }
}

extension FlyToViewportTransition: ViewportTransition {
    public func run(from: ViewportState?, to: ViewportState, completion: @escaping (Bool) -> Void) -> Cancelable {
        let resultCancelable = CompositeCancelable()
        var observeCameraComplete = false
        resultCancelable.add(to.observeCamera { [cameraAnimationsManager, duration] cameraOptions in
            // the force-unwrap below is safe. ease(to:) always returns non-nil Cancelable.
            // we should update its signature accordingly in the next major version.
            resultCancelable.add(cameraAnimationsManager.fly(
                to: cameraOptions,
                duration: duration) { position in
                    completion(position == .end)
                }!)
            observeCameraComplete = true
            // stop receiving updates (ignore moving targets)
            return false
        })
        // we still have to call the completion block if the transition is canceled while waiting for the to camera.
        // if it's canceled during the animation, the fly-to camera animator's completion block will be invoked.
        resultCancelable.add(BlockCancelable {
            if !observeCameraComplete {
                completion(false)
            }
        })
        return resultCancelable
    }
}
