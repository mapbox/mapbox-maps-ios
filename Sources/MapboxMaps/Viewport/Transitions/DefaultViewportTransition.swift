import UIKit

public struct DefaultViewportTransitionOptions: Hashable {
    public var duration: TimeInterval
    public var curve: UIView.AnimationCurve

    public init(duration: TimeInterval = 0.25,
                curve: UIView.AnimationCurve = .easeOut) {
        self.duration = duration
        self.curve = curve
    }
}

public final class DefaultViewportTransition {

    // modifications to options will take effect the next
    // time run(from:to:completion:) is invoked
    public var options: DefaultViewportTransitionOptions

    private let cameraAnimationsManager: CameraAnimationsManagerProtocol

    internal init(options: DefaultViewportTransitionOptions,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol) {
        self.options = options
        self.cameraAnimationsManager = cameraAnimationsManager
    }
}

extension DefaultViewportTransition: ViewportTransition {
    public func run(from: ViewportState?, to: ViewportState, completion: @escaping (Bool) -> Void) -> Cancelable {
        let resultCancelable = CompositeCancelable()
        var observeDataSourceComplete = false
        resultCancelable.add(to.observeDataSource { [cameraAnimationsManager, options] cameraOptions in
            // the force-unwrap below is safe. ease(to:) always returns non-nil Cancelable.
            // we should update its signature accordingly in the next major version.
            resultCancelable.add(cameraAnimationsManager.ease(
                to: cameraOptions,
                duration: options.duration,
                curve: options.curve) { position in
                    completion(position == .end)
                }!)
            observeDataSourceComplete = true
            // stop receiving updates (ignore moving targets)
            return false
        })
        // we still have to call the completion block if the transition is canceled while waiting for the to camera.
        // if it's canceled during the animation, the basic camera animator's completion block will be invoked.
        resultCancelable.add(BlockCancelable {
            if !observeDataSourceComplete {
                completion(false)
            }
        })
        return resultCancelable
    }
}
