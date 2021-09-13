import XCTest
@testable import MapboxMaps

final class GestureRecognizerDelegateTests: XCTestCase {

    var gestureRecognizerDelegate: GestureRecognizerDelegate!

    override func setUp() {
        super.setUp()
        gestureRecognizerDelegate = GestureRecognizerDelegate()
    }

    override func tearDown() {
        gestureRecognizerDelegate = nil
        super.tearDown()
    }

    func testAllowedSimultaneousGestures() {
        let pinchGestureRecognizer = UIPinchGestureRecognizer()
        let rotateGestureRecognizer = UIRotationGestureRecognizer()
        XCTAssertTrue(gestureRecognizerDelegate.gestureRecognizer(pinchGestureRecognizer,
                                                                  shouldRecognizeSimultaneouslyWith: rotateGestureRecognizer))
    }

    func testDisallowedSimultaneousGestures() {
        let panGestureRecognizer = UIPanGestureRecognizer()
        let tapGestureRecognizer = UITapGestureRecognizer()
        let pinchGestureRecognizer = UIPinchGestureRecognizer()
        let rotateGestureRecognizer = UIRotationGestureRecognizer()

        XCTAssertFalse(gestureRecognizerDelegate.gestureRecognizer(panGestureRecognizer,
                                                                   shouldRecognizeSimultaneouslyWith: pinchGestureRecognizer))
        XCTAssertFalse(gestureRecognizerDelegate.gestureRecognizer(panGestureRecognizer,
                                                                   shouldRecognizeSimultaneouslyWith: rotateGestureRecognizer))
        XCTAssertFalse(gestureRecognizerDelegate.gestureRecognizer(panGestureRecognizer,
                                                                   shouldRecognizeSimultaneouslyWith: tapGestureRecognizer))

        XCTAssertFalse(gestureRecognizerDelegate.gestureRecognizer(tapGestureRecognizer,
                                                                   shouldRecognizeSimultaneouslyWith: pinchGestureRecognizer))
        XCTAssertFalse(gestureRecognizerDelegate.gestureRecognizer(tapGestureRecognizer,
                                                                   shouldRecognizeSimultaneouslyWith: rotateGestureRecognizer))
    }
}
