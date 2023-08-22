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

    func testPitchDoesntRecognizeSimultaneouslyWithPinchPanAndRotate() async throws {
        let indices: [FingerIndex] = [.rightThumb, .rightIndex]
        let distance = 200.0
        let originalZoomLevel: CGFloat = 5
        let originalLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let originalBearing: CLLocationDirection = 45
        let origin = mapView.center
        let pitchEnd = origin.offsetBy(y: -60)
        let panEnd = pitchEnd.offsetBy(x: -60)
        camera.zoom = originalZoomLevel
        camera.center = originalLocation
        camera.bearing = originalBearing

        try eventGenerator.twoFingerDown(indices, at: origin, withDistance: distance)

        // pitch
        try eventGenerator.twoFingerMove(indices,
                                         to: pitchEnd,
                                         withDistance: distance,
                                         duration: Constants.pinchDuration)
        // pinch(zoom)
        try eventGenerator.twoFingerMove(indices,
                                         to: pitchEnd,
                                         withDistance: 80,
                                         duration: Constants.pinchDuration)
        // pan
        try eventGenerator.twoFingerMove(indices,
                                         to: panEnd,
                                         withDistance: 80,
                                         duration: Constants.pinchDuration)

        // rotate
        try eventGenerator.fingerPivot(indices,
                                       aroundAnchor: panEnd,
                                       byAngle: .pi / 2.0,
                                       duration: Constants.pinchDuration)

        try eventGenerator.twoFingerUp()

        XCTAssertTrue(mapView.camera.cameraAnimators.isEmpty)
        XCTAssertEqual(mapView.cameraState.pitch, 25)
        XCTAssertEqual(mapView.cameraState.zoom, originalZoomLevel)
        XCTAssertEqual(mapView.cameraState.center, originalLocation)
        XCTAssertEqual(mapView.cameraState.bearing, originalBearing)
    }
}

extension CGPoint {
    func offsetBy(x: CGFloat = 0, y: CGFloat = 0) -> CGPoint {
        CGPoint(x: self.x + x, y: self.y + y)
    }
}
