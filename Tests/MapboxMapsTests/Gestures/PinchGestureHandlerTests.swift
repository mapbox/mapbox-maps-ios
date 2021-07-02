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

        XCTAssertEqual(delegate.scaleForZoomStub.invocations.count, 1, "Initial scale was not calculated")

        XCTAssertTrue(delegate.gestureBeganMethod.wasCalled,
                      "Gesture Supportable view should be notified when gesture begins")
    }

    func testPinchChanged() {

        let pinchGestureHandler = PinchGestureHandler(for: view, withDelegate: delegate)
        pinchGestureHandler.scale = pow(2, 10.0)

        let pinchGestureRecognizerMock = UIPinchGestureRecognizerMock()
        pinchGestureRecognizerMock.mockState = .changed
        pinchGestureRecognizerMock.mockScale = 2.0
        pinchGestureRecognizerMock.mockLocationInView = CGPoint(x: 0.0, y: 0.0)

        pinchGestureHandler.handlePinch(pinchGestureRecognizerMock)

        XCTAssertTrue(delegate.cancelTransitionsCalled,
                      "Cancel Transitions was not called before commencing gesture processing")

        XCTAssertTrue(delegate.pinchScaleChangedMethod.wasCalled, "Pinch scale not recalculated")

        XCTAssertEqual(delegate.pinchScaleChangedMethod.newScale, 11.0, "New scale not calculated properly")

        XCTAssertTrue(delegate.pinchScaleChangedMethod.anchor == CGPoint(x: 0.0, y: 0.0),
                      "Invalid pinch center point")

        pinchGestureRecognizerMock.mockLocationInView = CGPoint(x: 1.0, y: 1.0)
        pinchGestureHandler.handlePinch(pinchGestureRecognizerMock)

        XCTAssertTrue(delegate.pinchCenterChangedMethod.wasCalled, "Pinch Center not recalculated")
        XCTAssertEqual(delegate.pinchCenterChangedMethod.offset,
                       CGSize(width: 1.0, height: 1.0),
                       "Offset not calculated correctly")
    }

    func testPinchEnded() {

        let pinchGestureHandler = PinchGestureHandler(for: view, withDelegate: delegate)
        pinchGestureHandler.scale = 10.0

        let pinchGestureRecognizerMock = UIPinchGestureRecognizerMock()
        pinchGestureRecognizerMock.mockState = .ended
        pinchGestureRecognizerMock.mockScale = 2.0

        pinchGestureHandler.handlePinch(pinchGestureRecognizerMock)

        XCTAssertTrue(delegate.cancelTransitionsCalled,
                      "Cancel Transitions was not called before commencing gesture processing")

        XCTAssertTrue(delegate.pinchEndedMethod.wasCalled,
                      "View was not informed that gesture was ended")

        XCTAssertTrue(delegate.pinchEndedMethod.anchor == CGPoint(x: 0.0, y: 0.0),
                      "Anchor not calculated correctly")

        XCTAssertTrue(delegate.pinchEndedMethod.drift == false,
                      "Drift not correctly calculated")
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
