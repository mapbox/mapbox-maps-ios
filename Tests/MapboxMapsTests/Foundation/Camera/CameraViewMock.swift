import UIKit
@testable import MapboxMaps

class CameraViewMock: CameraView {
    
    let localCameraStub = Stub<Void, CameraOptions>(defaultReturnValue: cameraOptionsTestValue)
    override var localCamera: CameraOptions {
        return localCameraStub.call()
    }
    
    
    struct SyncLayerParameters {
        var cameraOptions: CameraOptions
    }
    let syncLayerStub = Stub<SyncLayerParameters, Void>()
    override func syncLayer(to cameraOptions: CameraOptions) {
        syncLayerStub.call(with: .init(cameraOptions: cameraOptions))
    }
    
    
    let removeFromSuperviewStub = Stub<Void, Void>()
    override func removeFromSuperview() {
        removeFromSuperviewStub.call()
    }
    
}
