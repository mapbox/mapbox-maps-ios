import XCTest
@testable import MapboxMaps

final class TouchBeganGestureRecognizerTests: XCTestCase {
    func testRecognizedState() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let view = UIView(frame: window.bounds)
        window.addSubview(view)
        window.makeKeyAndVisible()

        let recognizer = TouchBeganGestureRecognizer()
        view.addGestureRecognizer(recognizer)
        XCTAssertNotEqual(recognizer.state, .recognized)

        recognizer.touchesBegan([UITouch()], with: UIEvent())

        XCTAssertEqual(recognizer.state, .recognized)
    }
}
