@testable import MapboxMaps

final class MockBasicCameraAnimatorMapboxMap: BasicCameraAnimatorMapboxMap {
    let setCameraStub = Stub<CameraOptions, Void>()
    func setCamera(to cameraOptions: CameraOptions) {
        setCameraStub.call(with: cameraOptions)
    }
}
