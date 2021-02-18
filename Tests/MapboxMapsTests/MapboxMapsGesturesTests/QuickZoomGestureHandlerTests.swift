import XCTest
#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsGestures
#endif

//swiftlint:disable explicit_acl explicit_top_level_acl
class QuickZoomGestureHandlerTest: XCTestCase {
    var view: UIView!
    // swiftlint:disable weak_delegate
    var delegate: GestureHandlerDelegateMock!

    override func setUp() {
        self.view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        self.delegate = GestureHandlerDelegateMock()
    }

    func testQuickZoomSetUp() {
        let quickZoomHandler = QuickZoomGestureHandler(for: self.view, withDelegate: self.delegate)
        XCTAssert(quickZoomHandler.gestureRecognizer is UILongPressGestureRecognizer)

        // swiftlint:disable force_cast
        let quickZoom = quickZoomHandler.gestureRecognizer as! UILongPressGestureRecognizer
        XCTAssertEqual(quickZoom.numberOfTapsRequired, 1)
    }

    func testQuickZoomBegan() {
        let quickZoomHandler = QuickZoomGestureHandler(for: self.view, withDelegate: self.delegate)
        let quickZoom = UILongPressGestureRecognizerMock()
        quickZoomHandler.handleQuickZoom(quickZoom)
        XCTAssertTrue(self.delegate.gestureBeganMethod.wasCalled)
        XCTAssertEqual(self.delegate.gestureBeganMethod.type, GestureType.quickZoom)
    }

    func testQuickZoomChanged() {

        let quickZoomHandler = QuickZoomGestureHandler(for: self.view, withDelegate: self.delegate)
        let quickZoom = UILongPressGestureRecognizerMock()
        quickZoomHandler.handleQuickZoom(quickZoom)

        quickZoom.mockState = .changed
        quickZoomHandler.handleQuickZoom(quickZoom)
        XCTAssertTrue(self.delegate.quickZoomChangedMethod.wasCalled)

        let bounds = view.bounds
        let anchor = CGPoint(x: bounds.midX, y: bounds.midY)
        XCTAssertEqual(anchor.x, self.delegate.quickZoomChangedMethod.anchor?.x)
        XCTAssertEqual(anchor.y, self.delegate.quickZoomChangedMethod.anchor?.y)
    }

    func testQuickZoomEnded() {
        let quickZoomHandler = QuickZoomGestureHandler(for: self.view, withDelegate: self.delegate)
        let quickZoom = UILongPressGestureRecognizerMock()
        quickZoom.mockState = .ended
        quickZoomHandler.handleQuickZoom(quickZoom)

        XCTAssertTrue(self.delegate.quickZoomEndedMethod)
    }
}

private class UILongPressGestureRecognizerMock: UILongPressGestureRecognizer {
    var mockState: UIGestureRecognizer.State! = .began
    var mockQuickZoomStart: CGFloat = 2.0
    var mockQuickZoomChanged: CGFloat = 10.0

    override var state: UIGestureRecognizer.State {
        get {
            return self.mockState
        } set {
            self.state = newValue
        }
    }

    override func location(in view: UIView?) -> CGPoint {
        if self.state == .began {
            return CGPoint(x: 0, y: mockQuickZoomStart)
        } else {
            return CGPoint(x: 0, y: mockQuickZoomChanged)
        }
    }
}
