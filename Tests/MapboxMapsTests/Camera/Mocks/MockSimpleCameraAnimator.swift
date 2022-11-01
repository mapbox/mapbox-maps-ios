@testable import MapboxMaps

final class MockSimpleCameraAnimator: SimpleCameraAnimatorProtocol {
    @Stubbed var state: UIViewAnimatingState = .inactive

    @Stubbed var owner: AnimationOwner = .random()

    @Stubbed var delegate: CameraAnimatorDelegate?

    @Stubbed var to: CameraOptions = .random()

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
