import XCTest
import MapboxMaps
import Hammer

final class RotateGestureTestCase: GestureTestCase {

    func testDefaultRotateGesture() async throws {
        mapView.ornaments.options.compass.visibility = .visible

        try eventGenerator.fingerRotate([.rightThumb, .rightIndex],
                                        angle: -90.0 * .pi / 180.0,
                                        duration: Constants.pinchDuration * 2)

        XCTAssertTrue(mapView.camera.cameraAnimators.isEmpty)
        // shouldStartRotating drops 3-15° before the map starts rotating, so a 90° gesture ends at ~75-88° and can land just under 75.
        XCTAssertGreaterThanOrEqual(mapView.mapboxMap.cameraState.bearing, 70)
    }
}
