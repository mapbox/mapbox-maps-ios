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
    public func run(from fromState: ViewportState?,
                    to toState: ViewportState,
                    completion: @escaping () -> Void) -> Cancelable {
        let resultCancelable = CompositeCancelable()
        resultCancelable.add(toState.observeDataSource { [cameraAnimationsManager, options] cameraOptions in
            // the force-unwrap below is safe. ease(to:) always returns non-nil Cancelable.
            // we should update its signature accordingly in the next major version.
            resultCancelable.add(cameraAnimationsManager.ease(
                to: cameraOptions,
                duration: options.duration,
                curve: options.curve) { position in
                    // only invoke the completion block if the animation was not canceled
                    // (for this API, that means it ended at .start (if someone reversed it) or .end)
                    if position != .current {
                        completion()
                    }
                }!)
            // stop receiving updates (ignore moving targets)
            return false
        })
        return resultCancelable
    }
}
