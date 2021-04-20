
import UIKit


class UIViewPropertyAnimatorMock: UIViewPropertyAnimator {
    
    var shouldReturnState: UIViewAnimatingState = .inactive
    
    override var state: UIViewAnimatingState {
        return shouldReturnState
    }
    
    let startAnimationStub = Stub<Void, Void>()
    override func startAnimation() {
        startAnimationStub.call()
    }
    
    struct StopAnimationParameters {
        var withoutFinishing: Bool
    }
    let stopAnimationStub = Stub<StopAnimationParameters, Void>()
    override func stopAnimation(_ withoutFinishing: Bool) {
        stopAnimationStub.call(with: StopAnimationParameters(withoutFinishing: withoutFinishing))
    }
    
    let pauseAnimationsStub = Stub<Void, Void>()
    override func pauseAnimation() {
        pauseAnimationsStub.call()
    }
    
    struct AddAnimationParameters {
        var animation: () -> Void
    }
    let addAnimationsStub = Stub<AddAnimationParameters, Void>()
    override func addAnimations(_ animation: @escaping () -> Void) {
        addAnimationsStub.call(with: .init(animation: animation))
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
    
    struct FinishAnimationParameters {
        var finalPosition: UIViewAnimatingPosition
    }
    
    let finishAnimationStub = Stub<FinishAnimationParameters, Void>()
    override func finishAnimation(at finalPosition: UIViewAnimatingPosition) {
        finishAnimationStub.call(with: .init(finalPosition: finalPosition))
    }
}
