import XCTest
@testable import MapboxMaps

final class DelegatingViewAnnotationPositionsUpdateListenerTests: XCTestCase {

    private class Receiver: DelegatingViewAnnotationPositionsUpdateListenerDelegate {

        var positions: [ViewAnnotationPositionDescriptor] = []

        internal func onViewAnnotationPositionsUpdate(forPositions positions: [ViewAnnotationPositionDescriptor]) {
            self.positions = positions
        }

    }

    func testOnViewAnnotationPositionsUpdate() {
        let receiver = Receiver()
        let delegatingPositionsListener = DelegatingViewAnnotationPositionsUpdateListener()
        delegatingPositionsListener.delegate = receiver

        let descriptor = ViewAnnotationPositionDescriptor(
            __identifier: "test",
            width: UInt32(100),
            height: UInt32(50),
            leftTopCoordinate: ScreenCoordinate(x: 100.0, y: 100.0)
        )

        delegatingPositionsListener.onViewAnnotationPositionsUpdate(forPositions: [descriptor])

        XCTAssertEqual(receiver.positions, [descriptor])
    }

}
