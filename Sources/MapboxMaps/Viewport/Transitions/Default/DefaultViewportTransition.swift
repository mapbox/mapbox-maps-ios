public final class DefaultViewportTransition {

    // modifications to options will take effect the next
    // time run(from:to:completion:) is invoked
    public var options: DefaultViewportTransitionOptions

    private let animationHelper: DefaultViewportTransitionAnimationHelperProtocol

    internal init(options: DefaultViewportTransitionOptions,
                  animationHelper: DefaultViewportTransitionAnimationHelperProtocol) {
        self.options = options
        self.animationHelper = animationHelper
    }
}

extension DefaultViewportTransition: ViewportTransition {
    public func run(from fromState: ViewportState?,
                    to toState: ViewportState,
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
