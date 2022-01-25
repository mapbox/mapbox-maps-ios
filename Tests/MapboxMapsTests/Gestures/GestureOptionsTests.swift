@_spi(Experimental) import MapboxMaps
import XCTest

final class GestureOptionsTests: XCTestCase {
    func testDefaultValues() {
        let options = GestureOptions()

        XCTAssertTrue(options.panEnabled)
        XCTAssertTrue(options.pinchEnabled)
        XCTAssertTrue(options.pinchRotateEnabled)
        XCTAssertEqual(options.pinchBehavior, .tracksTouchLocationsWhenPanningAfterZoomChange)
        XCTAssertTrue(options.pitchEnabled)
        XCTAssertTrue(options.doubleTapToZoomInEnabled)
        XCTAssertTrue(options.doubleTouchToZoomOutEnabled)
        XCTAssertTrue(options.quickZoomEnabled)
        XCTAssertEqual(options.panMode, .horizontalAndVertical)
        XCTAssertEqual(options.panDecelerationFactor, UIScrollView.DecelerationRate.normal.rawValue)
    }
}
