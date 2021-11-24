import XCTest
@testable import MapboxMaps

final class DelegatingViewAnnotationPositionsUpdateListenerTests: XCTestCase {

    func testOnViewAnnotationPositionsUpdate() {
        let receiver = MockDelegatingViewAnnotationPositionsUpdateListenerDelegate()
        let delegatingPositionsListener = DelegatingViewAnnotationPositionsUpdateListener()
        delegatingPositionsListener.delegate = receiver

        let descriptor = ViewAnnotationPositionDescriptor(
            identifier: "test",
            width: 100,
            height: 50,
            leftTopCoordinate: CGPoint(x: 100.0, y: 100.0)
        )

        delegatingPositionsListener.onViewAnnotationPositionsUpdate(forPositions: [descriptor])

        XCTAssertEqual(receiver.onViewAnnotationPositionsUpdateStub.invocations.last?.parameters, [descriptor])
    }

}
