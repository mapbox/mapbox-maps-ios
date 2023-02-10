@testable import MapboxMaps

final class MockCameraView: CameraView {
    let syncLayerStub = Stub<CameraOptions, Void>()
    override func syncLayer(to cameraOptions: CameraOptions) {
        syncLayerStub.call(with: cameraOptions)
    }

    let removeFromSuperviewStub = Stub<Void, Void>()
    override func removeFromSuperview() {
        removeFromSuperviewStub.call()
    }
}
