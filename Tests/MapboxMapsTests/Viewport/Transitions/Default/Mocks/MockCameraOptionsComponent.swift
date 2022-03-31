@testable import MapboxMaps

final class MockCameraOptionsComponent: CameraOptionsComponentProtocol {
    @Stubbed var cameraOptions: CameraOptions = .random()

    let updatedStub = Stub<CameraOptions, CameraOptionsComponentProtocol?>(defaultReturnValue: nil)
    func updated(with cameraOptions: CameraOptions) -> CameraOptionsComponentProtocol? {
        updatedStub.call(with: cameraOptions)
    }
}
