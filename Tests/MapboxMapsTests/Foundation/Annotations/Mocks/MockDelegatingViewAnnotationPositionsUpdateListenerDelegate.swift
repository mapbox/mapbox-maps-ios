import XCTest
@testable import MapboxMaps

final class MockDelegatingViewAnnotationPositionsUpdateListenerDelegate: DelegatingViewAnnotationPositionsUpdateListenerDelegate {

    let onViewAnnotationPositionsUpdateStub = Stub<[ViewAnnotationPositionDescriptor], Void>()
    func onViewAnnotationPositionsUpdate(forPositions positions: [ViewAnnotationPositionDescriptor]) {
        onViewAnnotationPositionsUpdateStub.call(with: positions)
    }

}
