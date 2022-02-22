import MapboxMaps
import XCTest

final class GestureOptionsTests: XCTestCase {
    func testDefaultValues() {
        let options = GestureOptions()

        XCTAssertTrue(options.panEnabled)
        XCTAssertTrue(options.pinchEnabled)
        XCTAssertTrue(options.pinchRotateEnabled)
        XCTAssertTrue(options.pinchZoomEnabled)
        XCTAssertTrue(options.pinchPanEnabled)
        XCTAssertTrue(options.pitchEnabled)
        XCTAssertTrue(options.doubleTapToZoomInEnabled)
        XCTAssertTrue(options.doubleTouchToZoomOutEnabled)
        XCTAssertTrue(options.quickZoomEnabled)
        XCTAssertEqual(options.panMode, .horizontalAndVertical)
        XCTAssertEqual(options.panDecelerationFactor, UIScrollView.DecelerationRate.normal.rawValue)
        XCTAssertNil(options.focalPoint)
    }

    func testPinchPanEnabledResetsFocalPoint() {
        var options = GestureOptions()
        options.focalPoint = .random()

        options.pinchPanEnabled = true

        XCTAssertNil(options.focalPoint)
    }

    func testSetFocalPointDisablesPinchPan() {
        var options = GestureOptions()
        options.pinchPanEnabled = true

        options.focalPoint = .random()

        XCTAssertFalse(options.pinchPanEnabled)
    }
}
