@testable import MapboxMaps
import UIKit

final class MockSimpleCameraAnimator: SimpleCameraAnimatorProtocol {
    @Stubbed var state: UIViewAnimatingState = .inactive

    @Stubbed var owner: AnimationOwner = .random()

    @Stubbed var animationType: AnimationType = .unspecified

    @Stubbed var to: CameraOptions = .random()

    @TestSignal var onCameraAnimatorStatusChanged: Signal<CameraAnimatorStatus>

    let cancelStub = Stub<Void, Void>()
    func cancel() {
        cancelStub.call()
    }

    let stopAnimationStub = Stub<Void, Void>()
    func stopAnimation() {
        stopAnimationStub.call()
    }

    let addCompletionStub = Stub<AnimationCompletion, Void>()
    func addCompletion(_ completion: @escaping AnimationCompletion) {
        addCompletionStub.call(with: completion)
    }

    let startAnimationStub = Stub<Void, Void>()
    func startAnimation() {
        startAnimationStub.call()
    }

    let startAnimationAfterDelayStub = Stub<TimeInterval, Void>()
    func startAnimation(afterDelay delay: TimeInterval) {
        startAnimationAfterDelayStub.call(with: delay)
    }

    let updateStub = Stub<Void, Void>()
    func update() {
        updateStub.call()
    }
}
