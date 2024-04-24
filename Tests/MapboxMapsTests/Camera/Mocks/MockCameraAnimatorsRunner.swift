@testable import MapboxMaps

final class MockCameraAnimatorsRunner: CameraAnimatorsRunnerProtocol {
    @Stubbed var isEnabled: Bool = false
    @Stubbed var cameraAnimators: [CameraAnimator] = []
    @TestSignal var onCameraAnimatorStatusChanged: Signal<CameraAnimatorStatusPayload>

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

    let cancelAnimationsOwnersTypesStub = Stub<(owners: [AnimationOwner], types: [AnimationType]), Void>()
    func cancelAnimations(withOwners owners: [AnimationOwner], andTypes types: [AnimationType]) {
        cancelAnimationsOwnersTypesStub.call(with: (owners: owners, types: types))
    }

    let addStub = Stub<CameraAnimatorProtocol, Void>()
    func add(_ animator: CameraAnimatorProtocol) {
        addStub.call(with: animator)
    }
}
