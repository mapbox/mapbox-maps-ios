import XCTest
import Hammer
import MapboxMaps

/// Test zoom-out pinch gesture
final class ZoomOutPinchGestureTestCase: GestureTestCase {

    /// Test zoom-outs gesture by some default values
    func testQuickZoomOut() async throws {
        try eventGenerator.fingerPinchClose(duration: Constants.pinchDuration)

        XCTAssertEqual(mapView.cameraState.zoom, 1.737, accuracy: 0.001)
    }

    /// Test that zoom-out gesture change nothing if changed distance is ≤ threshold
    func testZoomOutAsThreshold() async throws {
        camera.zoom = 3

        try eventGenerator.fingerPinch(fromDistance: EventGenerator.pinchSmallDistance + Constants.pinchThreshold,
                                       toDistance: EventGenerator.pinchSmallDistance,
                                       duration: Constants.pinchDuration)

        XCTAssertEqual(mapView.cameraState.zoom, 3)
    }

    /// Test that zooming-out happens if pinch gesture exceeds threshold by 1 point
    func testZoomOutNextAfterThreshold() async throws {
        camera.zoom = 3

        try eventGenerator.fingerPinch(fromDistance: EventGenerator.pinchSmallDistance + Constants.pinchThreshold + 1,
                                       toDistance: EventGenerator.pinchSmallDistance,
                                       duration: Constants.pinchDuration)

        XCTAssertEqual(mapView.cameraState.zoom, 2.930, accuracy: 0.001)
    }

    /// Same as ``testZoomOutNextAfterThreshold`` on city zoom level
    func testZoomOutextAfterThresholdOnCloseZoom() async throws {
        camera.zoom = 13

        try eventGenerator.fingerPinch(fromDistance: EventGenerator.pinchSmallDistance + Constants.pinchThreshold + 1,
                                       toDistance: EventGenerator.pinchSmallDistance,
                                       duration: Constants.pinchDuration)

        XCTAssertEqual(mapView.cameraState.zoom, 12.929, accuracy: 0.001)
    }

    /// Same as ``testZoomOutNextAfterThresholdOnCloseZoom`` but for a few points instead of 1
    /// That help to understand if there any accumulation for first 8 filtered points
    func testZoomOutFewPointsAfterThresholdOnCloseZoom() async throws {
        camera.zoom = 13

        try eventGenerator.fingerPinch(fromDistance: EventGenerator.pinchSmallDistance + Constants.pinchThreshold + 4,
                                       toDistance: EventGenerator.pinchSmallDistance,
                                       duration: Constants.pinchDuration)

        XCTAssertEqual(mapView.cameraState.zoom, 12.737, accuracy: 0.001)
    }
}
