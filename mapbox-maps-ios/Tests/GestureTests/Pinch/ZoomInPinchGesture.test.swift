import XCTest
import Hammer
import MapboxMaps

/// Test zoom-in pinch gesture
final class ZoomInPinchGestureTestCase: GestureTestCase {

    /// Test zoom-in gesture by some default values
    func testQuickZoomIn() async throws {
        try eventGenerator.fingerPinchOpen(duration: Constants.pinchDuration)

        XCTAssertEqual(mapView.cameraState.zoom, 7.836, accuracy: 0.001)
    }

    /// Test that zoom-in gesture change nothing if changed distance is ≤ threshold
    func testZoomInAsThreshold() async throws {
        camera.zoom = 3

        try eventGenerator.fingerPinch(fromDistance: EventGenerator.pinchSmallDistance,
                                       toDistance: EventGenerator.pinchSmallDistance + Constants.pinchThreshold,
                                       duration: Constants.pinchDuration)

        XCTAssertEqual(mapView.cameraState.zoom, 3)
    }

    /// Test that zooming-in happens if pinch gesture exceeds threshold by 1 point
    func testZoomInNextAfterThreshold() async throws {
        camera.zoom = 3

        try eventGenerator.fingerPinch(fromDistance: EventGenerator.pinchSmallDistance,
                                       toDistance: EventGenerator.pinchSmallDistance + Constants.pinchThreshold + 1,
                                       duration: Constants.pinchDuration)

        XCTAssertEqual(mapView.cameraState.zoom, 3.050, accuracy: 0.001)
    }

    /// Same as ``testZoomInNextAfterThreshold`` on city zoom level
    func testZoomInNextAfterThresholdOnCloseZoom() async throws {
        camera.zoom = 13

        try eventGenerator.fingerPinch(fromDistance: EventGenerator.pinchSmallDistance,
                                       toDistance: EventGenerator.pinchSmallDistance + Constants.pinchThreshold + 1,
                                       duration: Constants.pinchDuration)

        XCTAssertEqual(mapView.cameraState.zoom, 13.050, accuracy: 0.001)
    }

    /// Same as ``testZoomInNextAfterThresholdOnCloseZoom`` but for a few points instead of 1
    /// That help to understand if there any accumulation for first 8 filtered points
    func testZoomInFewPointsAfterThresholdOnCloseZoom() async throws {
        camera.zoom = 13

        try eventGenerator.fingerPinch(fromDistance: EventGenerator.pinchSmallDistance,
                                       toDistance: EventGenerator.pinchSmallDistance + Constants.pinchThreshold + 4,
                                       duration: Constants.pinchDuration)

        XCTAssertEqual(mapView.cameraState.zoom, 13.192, accuracy: 0.001)
    }
}
