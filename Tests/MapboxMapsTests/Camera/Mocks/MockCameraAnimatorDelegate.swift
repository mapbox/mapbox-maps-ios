@testable import MapboxMaps

final class MockCameraAnimatorDelegate: CameraAnimatorDelegate {
    let cameraAnimatorDidStartRunningStub = Stub<CameraAnimatorProtocol, Void>()
    func cameraAnimatorDidStartRunning(_ cameraAnimator: CameraAnimatorProtocol) {
        cameraAnimatorDidStartRunningStub.call(with: cameraAnimator)
    }

    let cameraAnimatorDidStopRunningStub = Stub<CameraAnimatorProtocol, Void>()
    func cameraAnimatorDidStopRunning(_ cameraAnimator: CameraAnimatorProtocol) {
        cameraAnimatorDidStopRunningStub.call(with: cameraAnimator)
    }
}
