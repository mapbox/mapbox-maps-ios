import XCTest
@testable import MapboxMaps

final class AnyTouchGestureRecognizerTests: XCTestCase {

    var gestureRecognizer: AnyTouchGestureRecognizer!

    override func setUp() {
        super.setUp()
        gestureRecognizer = AnyTouchGestureRecognizer()
    }

    override func tearDown() {
        gestureRecognizer = nil
        super.tearDown()
    }

    func testCanBePreventedBy() {
        XCTAssertFalse(gestureRecognizer.canBePrevented(by: MockGestureRecognizer()))
    }

    func testCanPrevent() {
        XCTAssertFalse(gestureRecognizer.canPrevent(MockGestureRecognizer()))
    }

    func testTouchHandling() {
        let touches = [UITouch(), UITouch(), UITouch()]
        let event = UIEvent()

        gestureRecognizer.touchesBegan([touches[0]], with: event)

        XCTAssertEqual(gestureRecognizer.state, .began)

        gestureRecognizer.touchesBegan([touches[1]], with: event)

        XCTAssertEqual(gestureRecognizer.state, .began)

        gestureRecognizer.touchesCancelled([touches[0]], with: event)

        XCTAssertEqual(gestureRecognizer.state, .began)

        gestureRecognizer.touchesEnded([touches[1]], with: event)

        XCTAssertEqual(gestureRecognizer.state, .ended)
    }
}
