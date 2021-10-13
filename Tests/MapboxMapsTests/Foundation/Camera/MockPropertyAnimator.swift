import UIKit

final class MockPropertyAnimator: UIViewPropertyAnimator {

    let setIsReversedStub = Stub<Bool, Void>()
    override var isReversed: Bool {
        get {
            return super.isReversed
        }
        set {
            super.isReversed = newValue
            setIsReversedStub.call(with: newValue)
        }
    }

    let startAnimationStub = Stub<Void, Void>()
    override func startAnimation() {
        super.startAnimation()
        startAnimationStub.call()
    }

    let stopAnimationStub = Stub<Bool, Void>()
    override func stopAnimation(_ withoutFinishing: Bool) {
        super.stopAnimation(withoutFinishing)
        stopAnimationStub.call(with: withoutFinishing)
    }

    let addAnimationsStub = Stub<() -> Void, Void>()
    override func addAnimations(_ animation: @escaping () -> Void) {
        super.addAnimations(animation)
        addAnimationsStub.call(with: animation)
    }

    let addCompletionStub = Stub<(UIViewAnimatingPosition) -> Void, Void>()
    override func addCompletion(_ completion: @escaping (UIViewAnimatingPosition) -> Void) {
        super.addCompletion(completion)
        addCompletionStub.call(with: completion)
    }

    let finishAnimationStub = Stub<UIViewAnimatingPosition, Void>()
    override func finishAnimation(at finalPosition: UIViewAnimatingPosition) {
        super.finishAnimation(at: finalPosition)
        finishAnimationStub.call(with: finalPosition)
    }
}
