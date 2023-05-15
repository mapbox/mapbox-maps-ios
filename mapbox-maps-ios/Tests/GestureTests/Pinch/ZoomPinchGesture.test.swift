import XCTest
import Hammer
import MapboxMaps

/// Test zoom in-and-out and out-and-in pinch gestures
final class ZoomPinchGestureTestCase: GestureTestCase {

    /// Test that zooming-in and zooming-out to _almost_ the same place will return zoom level back
    /// It is _almost_ the same to compensate initial zooming theshold affect
    func testZoomInAndOutForSameDistanceHorizontally() async throws {
        let startCameraState = mapView.cameraState

        try eventGenerator.twoFingerDown(at: mapView.center, withDistance: 20)
        try eventGenerator.twoFingerMove(to: mapView.center, withDistance: 200,
                                         duration: Constants.pinchDuration)
        try eventGenerator.twoFingerMove(to: mapView.center, withDistance: 20 + Constants.pinchThreshold,
                                         duration: Constants.pinchDuration)
        try eventGenerator.twoFingerUp()

        XCTAssertEqual(mapView.cameraState.zoom, startCameraState.zoom, accuracy: 0.001)
    }

    /// Test that zooming-in and zooming-out to _almost_ the same place will return zoom level back
    /// It is _almost_ the same to compensate initial zooming theshold affect
    /// This function also applies 35° angle to simulate real finger touches.
    func testZoomInAndOutForSameDistanceWithRealFingersIncline() async throws {
        let startCameraState = mapView.cameraState

        let angle = -35 * (Double.pi / 180.0)
        try eventGenerator.twoFingerDown(at: mapView.center, withDistance: 20, angle: angle)
        try eventGenerator.twoFingerMove(to: mapView.center, withDistance: 200, angle: angle,
                                         duration: Constants.pinchDuration)
        try eventGenerator.twoFingerMove(to: mapView.center, withDistance: 20 + Constants.pinchThreshold, angle: angle,
                                         duration: Constants.pinchDuration)
        try eventGenerator.twoFingerUp()

        XCTExpectFailure("Bug in Hammer: angle arg interprets incorrectly") {
            XCTAssertEqual(mapView.cameraState.zoom, startCameraState.zoom, accuracy: 0.001)
        }
    }

    /// Test that zooming-out and zooming-in to _almost_ the same place will return zoom level back
    /// It is _almost_ the same to compensate initial zooming theshold affect
    func testZoomOutAndInForSameDistanceHorizontally() async throws {
        camera.zoom = 8
        let startCameraState = mapView.cameraState

        try eventGenerator.twoFingerDown(at: mapView.center, withDistance: 200)
        try eventGenerator.twoFingerMove(to: mapView.center, withDistance: 40,
                                         duration: Constants.pinchDuration)
        try eventGenerator.twoFingerMove(to: mapView.center, withDistance: 200 - Constants.pinchThreshold,
                                         duration: Constants.pinchDuration)
        try eventGenerator.twoFingerUp()

        XCTAssertEqual(mapView.cameraState.zoom, startCameraState.zoom, accuracy: 0.001)
    }

    /// Test that zooming-out and zooming-in to _almost_ the same place will return zoom level back
    /// It is _almost_ the same to compensate initial zooming theshold affect
    func testZoomOutAndInForSameDistanceWithRealFingersIncline() async throws {
        camera.zoom = 8
        let startCameraState = mapView.cameraState

        let angle = -35 * (Double.pi / 180.0)
        try eventGenerator.twoFingerDown(at: mapView.center, withDistance: 200, angle: angle)
        try eventGenerator.twoFingerMove(to: mapView.center, withDistance: 40, angle: angle,
                                         duration: Constants.pinchDuration)
        try eventGenerator.twoFingerMove(to: mapView.center, withDistance: 200 - Constants.pinchThreshold, angle: angle,
                                         duration: Constants.pinchDuration)
        try eventGenerator.twoFingerUp()

        XCTExpectFailure("Bug in Hammer: angle arg interprets incorrectly") {
            XCTAssertEqual(mapView.cameraState.zoom, startCameraState.zoom, accuracy: 0.001)
        }
    }
}
