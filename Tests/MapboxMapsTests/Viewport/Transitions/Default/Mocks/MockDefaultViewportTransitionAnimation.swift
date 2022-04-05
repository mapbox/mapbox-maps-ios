@testable import MapboxMaps

final class MockDefaultViewportTransitionAnimation: DefaultViewportTransitionAnimationProtocol {

    let startStub = Stub<(Bool) -> Void, Void>()
    func start(with completion: @escaping (Bool) -> Void) {
        startStub.call(with: completion)
    }

    let updateTargetCameraStub = Stub<CameraOptions, Void>()
    func updateTargetCamera(with cameraOptions: CameraOptions) {
        updateTargetCameraStub.call(with: cameraOptions)
    }

    let cancelStub = Stub<Void, Void>()
    func cancel() {
        cancelStub.call()
    }
}
