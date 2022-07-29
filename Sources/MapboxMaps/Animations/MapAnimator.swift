import Foundation

@_spi(Experimental) final public class MapAnimator {

    private let impl: MapAnimatorImpl

    public var owner: AnimationOwner {
        return impl.owner
    }

    public var timingCurve: TimingCurve {
        get { impl.timingCurve }
        set { impl.timingCurve = newValue }
    }

    public var duration: TimeInterval {
        get { impl.duration }
        set { impl.duration = newValue }
    }

    public var isRunning: Bool {
        return impl.isRunning
    }

    public var isReversed: Bool {
        get { impl.isReversed }
        set { impl.isReversed = newValue }
    }

    public var pausesOnCompletion: Bool {
        get { impl.pausesOnCompletion }
        set { impl.pausesOnCompletion = newValue }
    }

    public var fractionComplete: Double {
        get { impl.fractionComplete }
        set { impl.fractionComplete = newValue }
    }

    public var repeatCount: Int {
        get { impl.repeatCount }
        set { impl.repeatCount = newValue }
    }

    public var autoreverses: Bool {
        get { impl.autoreverses }
        set { impl.autoreverses = newValue }
    }

    internal init(impl: MapAnimatorImpl) {
        self.impl = impl
    }

    public init(duration: TimeInterval, curve: TimingCurve, owner: AnimationOwner = .unspecified) {
        self.impl = MapAnimatorImpl(duration: duration, curve: curve, owner: owner, mainQueue: MainQueue())
    }

    public func startAnimation() {
        impl.startAnimation()
    }

    public func startAnimation(afterDelay delay: TimeInterval) {
        impl.startAnimation(afterDelay: delay)
    }

    public func pauseAnimation() {
        impl.pauseAnimation()
    }

    public func stopAnimation() {
        impl.stopAnimation()
    }

    public func addAnimations(_ animation: @escaping (Double) -> Void) {
        impl.addAnimations(animation)
    }

    public func addCompletion(_ completion: @escaping AnimationCompletion) {
        impl.addCompletion(completion)
    }
}
