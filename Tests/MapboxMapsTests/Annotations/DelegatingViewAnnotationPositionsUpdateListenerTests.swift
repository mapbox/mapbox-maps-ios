import XCTest
@testable import MapboxMaps

final class ViewAnnotationPositionsUpdateListenerImplTests: XCTestCase {

    func testOnViewAnnotationPositionsUpdate() {
        let stub = Stub<[ViewAnnotationPositionDescriptor], Void>()
        let me = ViewAnnotationPositionsUpdateListenerImpl(callback: stub.call(with:))

        let descriptor = ViewAnnotationPositionDescriptor(
            identifier: "test",
            frame: .init(x: 100, y: 100, width: 100, height: 50)
        )

        me.onViewAnnotationPositionsUpdate(forPositions: [descriptor])

        XCTAssertEqual(stub.invocations.last?.parameters, [descriptor])
    }

}
