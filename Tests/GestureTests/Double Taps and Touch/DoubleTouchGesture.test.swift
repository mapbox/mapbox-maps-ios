import XCTest
import MapboxMaps
import Hammer

final class DoubleTouchGestureTestCase: GestureTestCase {
    /// Test that tap with two fingers gestures change zoom level by -1
    func testDefaultDoubleTouch() async throws {
        try eventGenerator.twoFingerTap()
        await mapView.camera.cameraAnimators.waitForAllAnimations()

        XCTAssertEqual(mapView.cameraState.zoom, 4)
    }
}
