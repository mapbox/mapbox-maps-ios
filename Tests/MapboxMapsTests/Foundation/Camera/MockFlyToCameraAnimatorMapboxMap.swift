@testable import MapboxMaps

final class MockFlyToCameraAnimatorMapboxMap: FlyToCameraAnimatorMapboxMap {
    let setCameraStub = Stub<CameraOptions, Void>()
    func setCamera(to cameraOptions: CameraOptions) {
        setCameraStub.call(with: cameraOptions)
    }
}
