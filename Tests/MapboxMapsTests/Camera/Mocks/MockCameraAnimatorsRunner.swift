@testable import MapboxMaps

final class MockCameraAnimatorsRunner: CameraAnimatorsRunnerProtocol {
    @Stubbed var animationsEnabled: Bool = true

    @Stubbed var cameraAnimators: [CameraAnimator] = []

    let updateStub = Stub<Void, Void>()
    func update() {
        updateStub.call()
    }

    let cancelAnimationsStub = Stub<Void, Void>()
    func cancelAnimations() {
        cancelAnimationsStub.call()
    }

    let cancelAnimationsWithOwnersStub = Stub<[AnimationOwner], Void>()
    func cancelAnimations(withOwners owners: [AnimationOwner]) {
        cancelAnimationsWithOwnersStub.call(with: owners)
    }

    let addStub = Stub<CameraAnimatorProtocol, Void>()
    func add(_ animator: CameraAnimatorProtocol) {
        addStub.call(with: animator)
    }
}
