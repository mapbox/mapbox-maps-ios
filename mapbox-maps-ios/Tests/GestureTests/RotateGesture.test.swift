import XCTest
import MapboxMaps
import Hammer

final class RotateGestureTestCase: GestureTestCase {

    func testDefaultRotateGesture() async throws {
        mapView.ornaments.options.compass.visibility = .visible

        try eventGenerator.fingerRotate([.rightThumb, .rightIndex],
                                        angle: -90.0 * .pi / 180.0,
                                        duration: Constants.pinchDuration)

        XCTAssertTrue(mapView.camera.cameraAnimators.isEmpty)
        XCTAssertGreaterThanOrEqual(mapView.cameraState.bearing, 70)
    }
}
