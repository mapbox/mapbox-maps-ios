import UIKit

final class MockPropertyAnimator: UIViewPropertyAnimator {

    let stateStub = Stub<Void, UIViewAnimatingState>(defaultReturnValue: .inactive)
    override var state: UIViewAnimatingState {
        stateStub.call()
    }

    let startAnimationStub = Stub<Void, Void>()
    override func startAnimation() {
        startAnimationStub.call()
    }

    let stopAnimationStub = Stub<Bool, Void>()
    override func stopAnimation(_ withoutFinishing: Bool) {
        stopAnimationStub.call(with: withoutFinishing)
    }

    let pauseAnimationsStub = Stub<Void, Void>()
    override func pauseAnimation() {
        pauseAnimationsStub.call()
    }

    let addAnimationsStub = Stub<() -> Void, Void>()
    override func addAnimations(_ animation: @escaping () -> Void) {
        addAnimationsStub.call(with: animation)
    }

    let addCompletionStub = Stub<Void, Void>()
    override func addCompletion(_ completion: @escaping (UIViewAnimatingPosition) -> Void) {
        addCompletionStub.call()
    }

    struct ContinueAnimationParameters {
        var parameters: UITimingCurveProvider?
        var durationFactor: CGFloat
    }
    let continueAnimationStub = Stub<ContinueAnimationParameters, Void>()
    override func continueAnimation(withTimingParameters parameters: UITimingCurveProvider?, durationFactor: CGFloat) {
        continueAnimationStub.call(with: .init(parameters: parameters, durationFactor: durationFactor))
    }

    let finishAnimationStub = Stub<UIViewAnimatingPosition, Void>()
    override func finishAnimation(at finalPosition: UIViewAnimatingPosition) {
        finishAnimationStub.call(with: finalPosition)
    }
}
