import XCTest
@testable import MapboxMaps

final class CameraAnimatorDelegateMock: CameraAnimatorDelegate {

    let addViewToViewHeirarchyStub = Stub<CameraView, Void>()
    func addViewToViewHeirarchy(_ view: CameraView) {
        addViewToViewHeirarchyStub.call(with: view)
    }
}
