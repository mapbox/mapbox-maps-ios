@testable import MapboxMaps

final class MockCameraAnimatorDelegate: CameraAnimatorDelegate {
    let cameraAnimatorDidStartRunningStub = Stub<CameraAnimator, Void>()
    func cameraAnimatorDidStartRunning(_ cameraAnimator: CameraAnimator) {
        cameraAnimatorDidStartRunningStub.call(with: cameraAnimator)
    }

    let cameraAnimatorDidStopRunningStub = Stub<CameraAnimator, Void>()
    func cameraAnimatorDidStopRunning(_ cameraAnimator: CameraAnimator) {
        cameraAnimatorDidStopRunningStub.call(with: cameraAnimator)
    }
}
