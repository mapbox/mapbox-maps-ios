import XCTest
@testable import MapboxMaps

final class TouchBeganGestureRecognizerTests: XCTestCase {
    func testRecognizedState() {
        let recognizer = TouchBeganGestureRecognizer()
        XCTAssertNotEqual(recognizer.state, .recognized)

        recognizer.touchesBegan([UITouch()], with: UIEvent())

        XCTAssertEqual(recognizer.state, .recognized)
    }
}
