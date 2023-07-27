/// A default ``ViewportTransition`` implementation.
///
/// Use ``ViewportManager/makeDefaultViewportTransition(options:)`` to create instances of this
/// class.
public final class DefaultViewportTransition {

    /// Configuration options.
    ///
    /// New values will take effect the next time ``ViewportTransition/run(to:completion:)``
    /// is invoked
    public var options: DefaultViewportTransitionOptions

    private let animationHelper: DefaultViewportTransitionAnimationHelperProtocol

    internal init(options: DefaultViewportTransitionOptions,
                  animationHelper: DefaultViewportTransitionAnimationHelperProtocol) {
        self.options = options
        self.animationHelper = animationHelper
    }
}

extension DefaultViewportTransition: ViewportTransition {

    /// :nodoc:
    /// See ``ViewportTransition/run(to:completion:)``.
    public func run(to toState: ViewportState,
                    completion: @escaping (Bool) -> Void) -> Cancelable {
        let resultCancelable = CompositeCancelable()
        var animation: DefaultViewportTransitionAnimationProtocol!
        resultCancelable.add(toState.observeDataSource { [options, animationHelper] cameraOptions in
            if let animation = animation {
                animation.updateTargetCamera(with: cameraOptions)
            } else {
                animation = animationHelper.makeAnimation(
                    cameraOptions: cameraOptions,
                    maxDuration: options.maxDuration)
                animation.start { isFinished in
                    resultCancelable.cancel()
                    completion(isFinished)
                }
                resultCancelable.add(animation)
            }
            return true
        })
        return resultCancelable
    }
}
