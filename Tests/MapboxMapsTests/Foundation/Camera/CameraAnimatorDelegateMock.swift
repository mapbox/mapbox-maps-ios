import XCTest
@testable import MapboxMaps

final class CameraAnimatorDelegateMock: CameraAnimatorDelegate {

    var camera: CameraState {
        let cameraStateObjc = MapboxCoreMaps.CameraState(
            center: .init(latitude: 10, longitude: 10),
            padding: .init(top: 10, left: 10, bottom: 10, right: 10),
            zoom: 10,
            bearing: 10,
            pitch: 20)

        return CameraState(cameraStateObjc)
    }

    let addViewToViewHeirarchyStub = Stub<CameraView, Void>()
    func addViewToViewHeirarchy(_ view: CameraView) {
        addViewToViewHeirarchyStub.call(with: view)
    }

    let anchorAfterPaddingStub = Stub<Void, CGPoint>(defaultReturnValue: .zero)
    func anchorAfterPadding() -> CGPoint {
        return anchorAfterPaddingStub.call()
    }
}
