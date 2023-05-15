import XCTest
import MapboxMaps
import Hammer

final class PitchGestureTestCase: GestureTestCase {

    func testDefaultPitchGesture() async throws {
        let distance = 100.0
        let yOffset = -60.0
        try eventGenerator.twoFingerDown(at: mapView.center,
                                         withDistance: distance)
        try eventGenerator.twoFingerMove(to: mapView.center.offsetBy(y: yOffset),
                                         withDistance: distance,
                                         duration: Constants.pinchDuration)
        try eventGenerator.twoFingerUp()

        XCTAssertTrue(mapView.camera.cameraAnimators.isEmpty)
        XCTAssertEqual(mapView.cameraState.pitch, 25)
    }

    func testDefaultPitchGesture2() async throws {
        camera.zoom = 12

        let distance = 100.0
        let yOffset = -360.0
        let startPoint = mapView.center.offsetBy(y: 200)
        try eventGenerator.twoFingerDown(at: startPoint,
                                         withDistance: distance)
        try eventGenerator.twoFingerMove(to: startPoint.offsetBy(y: yOffset),
                                         withDistance: distance,
                                         duration: Constants.pinchDuration + 3)
        try eventGenerator.twoFingerUp()

        XCTAssertTrue(mapView.camera.cameraAnimators.isEmpty)
        XCTAssertEqual(mapView.cameraState.pitch, 85)
    }
}

extension CGPoint {
    func offsetBy(x: CGFloat = 0, y: CGFloat = 0) -> CGPoint {
        CGPoint(x: self.x + x, y: self.y + y)
    }
}
