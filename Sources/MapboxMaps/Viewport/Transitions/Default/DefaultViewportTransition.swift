/// A default ``ViewportTransition`` implementation.
///
/// Use ``Viewport/makeDefaultViewportTransition(options:)`` to create instances of this
/// class.
@_spi(Experimental) public final class DefaultViewportTransition {

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
        resultCancelable.add(toState.observeDataSource { [options, animationHelper] cameraOptions in
            resultCancelable.add(animationHelper.animate(
                to: cameraOptions,
                maxDuration: options.maxDuration,
                completion: completion))
            // stop receiving updates (ignore moving targets)
            return false
        })
        return resultCancelable
    }
}
