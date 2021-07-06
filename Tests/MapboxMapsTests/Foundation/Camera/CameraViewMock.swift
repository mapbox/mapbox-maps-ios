import UIKit
@testable import MapboxMaps

class CameraViewMock: CameraView {
    let localCameraStub = Stub<Void, CameraOptions>(defaultReturnValue: cameraOptionsTestValue)
    override var localCamera: CameraOptions {
        return localCameraStub.call()
    }

    let syncLayerStub = Stub<CameraOptions, Void>()
    override func syncLayer(to cameraOptions: CameraOptions) {
        syncLayerStub.call(with: cameraOptions)
    }
}
