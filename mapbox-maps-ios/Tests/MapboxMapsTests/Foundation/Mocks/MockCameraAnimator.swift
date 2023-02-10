import Foundation
@testable import MapboxMaps

final class MockCameraAnimator: NSObject, CameraAnimatorProtocol {
    let cancelStub = Stub<Void, Void>()
    func cancel() {
        cancelStub.call()
    }

    let stopAnimationStub = Stub<Void, Void>()
    func stopAnimation() {
        stopAnimationStub.call()
    }

    @Stubbed var state: UIViewAnimatingState = .inactive

    @Stubbed var owner: AnimationOwner = .random()

    @Stubbed var delegate: CameraAnimatorDelegate?

    let addCompletionStub = Stub<AnimationCompletion, Void>()
    func addCompletion(_ completion: @escaping AnimationCompletion) {
        addCompletionStub.call(with: completion)
    }

    let startAnimationStub = Stub<Void, Void>()
    func startAnimation() {
        startAnimationStub.call()
    }

    let updateStub = Stub<Void, Void>()
    func update() {
        updateStub.call()
    }
}
