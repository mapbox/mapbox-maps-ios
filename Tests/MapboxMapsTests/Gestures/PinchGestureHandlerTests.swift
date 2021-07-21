import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsGestures
#endif

//swiftlint:disable explicit_acl explicit_top_level_acl
class PinchGestureHandlerTests: XCTestCase {

    var view: UIView!
    // swiftlint:disable weak_delegate
    var delegate: GestureHandlerDelegateMock!

    override func setUp() {
        view = UIView()
        delegate = GestureHandlerDelegateMock()
    }

    override func tearDown() {
        view = nil
    }

    func testSetup() {
        let pinch = PinchGestureHandler(for: view, withDelegate: delegate)
        XCTAssert(pinch.gestureRecognizer is UIPinchGestureRecognizer)
    }

    func testPinchBegan() {

        let pinchGestureHandler = PinchGestureHandler(for: view, withDelegate: delegate)
        let pinchGestureRecognizerMock = UIPinchGestureRecognizerMock()
        pinchGestureHandler.handlePinch(pinchGestureRecognizerMock)

        XCTAssertTrue(delegate.cancelTransitionsCalled,
                      "Cancel Transitions was not called before commencing gesture processing")

        XCTAssertTrue(delegate.gestureBeganMethod.wasCalled,
                      "Gesture Supportable view should be notified when gesture begins")
    }

    func testPinchChanged() {

        let pinchGestureHandler = PinchGestureHandler(for: view, withDelegate: delegate)

        let pinchGestureRecognizerMock = UIPinchGestureRecognizerMock()
        pinchGestureRecognizerMock.mockState = .changed
        pinchGestureRecognizerMock.mockScale = 2.0
        pinchGestureRecognizerMock.mockLocationInView = CGPoint(x: 0.0, y: 0.0)

        pinchGestureHandler.handlePinch(pinchGestureRecognizerMock)

        XCTAssertTrue(delegate.cancelTransitionsCalled,
                      "Cancel Transitions was not called before commencing gesture processing")

        XCTAssertTrue(delegate.pinchChangedMethod.wasCalled, "Pinch scale not recalculated")

        XCTAssertTrue(delegate.pinchChangedMethod.anchor == CGPoint(x: 0.0, y: 0.0),
                      "Invalid pinch center point")

        pinchGestureRecognizerMock.mockLocationInView = CGPoint(x: 1.0, y: 1.0)
        pinchGestureHandler.handlePinch(pinchGestureRecognizerMock)

        XCTAssertTrue(delegate.pinchChangedMethod.wasCalled, "Pinch Center not recalculated")
        XCTAssertEqual(delegate.pinchChangedMethod.anchor,
                       CGPoint(x: 1.0, y: 1.0),
                       "Offset not calculated correctly")
        XCTAssertEqual(delegate.pinchChangedMethod.previousAnchor,
                       CGPoint(x: 0.0, y: 0.0),
                       "Offset not calculated correctly")
    }

    func testPinchEnded() {

        let pinchGestureHandler = PinchGestureHandler(for: view, withDelegate: delegate)

        let pinchGestureRecognizerMock = UIPinchGestureRecognizerMock()
        pinchGestureRecognizerMock.mockState = .ended

        pinchGestureHandler.handlePinch(pinchGestureRecognizerMock)

        XCTAssertTrue(delegate.cancelTransitionsCalled,
                      "Cancel Transitions was not called before commencing gesture processing")

        XCTAssertTrue(delegate.pinchEndedMethod.wasCalled,
                      "View was not informed that gesture was ended")

        XCTAssertTrue(delegate.pinchEndedMethod.anchor == CGPoint(x: 0.0, y: 0.0),
                      "Anchor not calculated correctly")
    }
}

private class UIPinchGestureRecognizerMock: UIPinchGestureRecognizer {

    var mockState: UIGestureRecognizer.State = .began
    var mockScale: CGFloat = 2.0
    var mockCenter: CGPoint = .zero
    var mockLocationInView: CGPoint = .zero

    override var state: UIGestureRecognizer.State {
        get {
            return self.mockState
        } set {
            self.state = newValue
        }
    }

    override var scale: CGFloat {
        get {
            return mockScale
        } set {
            self.scale = newValue
        }
    }

    override func location(in view: UIView?) -> CGPoint {
        return mockLocationInView
    }
}
