import XCTest
import MapboxMaps
import Hammer

final class DoubleTapGestureTestCase: GestureTestCase {
    /// That test validates that after double tap gesture at the end of camera animation
    /// zoom level will be incresed by 1 level
    func testDefaultQuickZoomInTwoTaps() async throws {
        try eventGenerator.fingerTap(numberOfTimes: 2)

        XCTAssertFalse(mapView.camera.cameraAnimators.isEmpty)
        await mapView.camera.cameraAnimators.waitForAllAnimations()

        XCTAssertTrue(mapView.camera.cameraAnimators.isEmpty)
        XCTAssertEqual(mapView.cameraState.zoom, 6, accuracy: 0)
    }

    /// That test validates that after triple tap gesture at the end of camera animation
    /// zoom level will be incresed by 1 level
    func testQuickZoomInThreeTaps() async throws {
        try eventGenerator.fingerTap(numberOfTimes: 3)

        await mapView.camera.cameraAnimators.waitForAllAnimations()

        XCTAssertEqual(mapView.cameraState.zoom, 6, accuracy: 0)
    }

    /// That test validates that after triple tap gesture at the end of camera animation
    /// zoom level will be incresed by 1 level
    func testQuickZoomInFourTaps() async throws {
        try eventGenerator.fingerTap(numberOfTimes: 4)

        await mapView.camera.cameraAnimators.waitForAllAnimations()

        XCTAssertEqual(mapView.cameraState.zoom, 7, accuracy: 0)
    }

    /// That test validates that after triple tap gesture at the end of camera animation
    /// zoom level will be incresed by 1 level
    func testQuickZoomInFourFastTaps() async throws {
        try eventGenerator.fingerTap(numberOfTimes: 4, interval: 0)

        await mapView.camera.cameraAnimators.waitForAllAnimations()

        XCTExpectFailure("<https://mapbox.atlassian.net/jira/software/c/projects/MAPSIOS/issues/?jql=project%20%3D%20%22MAPSIOS%22%20AND%20text%20~%20%22Double%20Tap%22%20ORDER%20BY%20created%20DESC> Potential bug. TODO: Create a ticket") {
            XCTAssertEqual(mapView.cameraState.zoom, 7, accuracy: 0)
        }

    }

    /// Test that quick zoom gesture doesn't trigger when it disabled with options
    func testQuickZoomDisabled() async throws {
        mapView.gestures.options.doubleTapToZoomInEnabled = false

        try eventGenerator.fingerDoubleTap()

        XCTAssertTrue(mapView.camera.cameraAnimators.isEmpty)
        XCTAssertEqual(mapView.cameraState.zoom, 5, accuracy: 0)
    }
}
