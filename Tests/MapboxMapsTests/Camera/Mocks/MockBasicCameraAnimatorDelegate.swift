@testable import MapboxMaps

final class MockBasicCameraAnimatorDelegate: BasicCameraAnimatorDelegate {
    let basicCameraAnimatorDidStartRunningStub = Stub<BasicCameraAnimatorProtocol, Void>()
    func basicCameraAnimatorDidStartRunning(_ animator: BasicCameraAnimatorProtocol) {
        basicCameraAnimatorDidStartRunningStub.call(with: animator)
    }

    let basicCameraAnimatorDidStopRunningStub = Stub<BasicCameraAnimatorProtocol, Void>()
    func basicCameraAnimatorDidStopRunning(_ animator: BasicCameraAnimatorProtocol) {
        basicCameraAnimatorDidStopRunningStub.call(with: animator)
    }
}
