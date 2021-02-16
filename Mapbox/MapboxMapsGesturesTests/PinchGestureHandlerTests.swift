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
        self.view = UIView()
        self.delegate = GestureHandlerDelegateMock()
    }

    override func tearDown() {
        self.view = nil
    }

    func testSetup() {
        let pinch = PinchGestureHandler(for: self.view, withDelegate: self.delegate)
        XCTAssert(pinch.gestureRecognizer is UIPinchGestureRecognizer)
    }

    func testPinchBegan() {

        let pinchGestureHandler = PinchGestureHandler(for: self.view, withDelegate: self.delegate)
        let pinchGestureRecognizerMock = UIPinchGestureRecognizerMock()
        pinchGestureHandler.handlePinch(pinchGestureRecognizerMock)

        XCTAssertTrue(self.delegate.cancelTransitionsCalled,
                      "Cancel Transitions was not called before commencing gesture processing")

        XCTAssertEqual(self.delegate.scaleForZoomStub.invocations.count, 1, "Initial scale was not calculated")

        XCTAssertTrue(self.delegate.gestureBeganMethod.wasCalled,
                      "Gesture Supportable view should be notified when gesture begins")
    }

    func testPinchChanged() {

        let pinchGestureHandler = PinchGestureHandler(for: self.view, withDelegate: self.delegate)
        pinchGestureHandler.scale = pow(2, 10.0)

        let pinchGestureRecognizerMock = UIPinchGestureRecognizerMock()
        pinchGestureRecognizerMock.mockState = .changed
        pinchGestureRecognizerMock.mockScale = 2.0

        pinchGestureHandler.handlePinch(pinchGestureRecognizerMock)

        XCTAssertTrue(self.delegate.cancelTransitionsCalled,
                      "Cancel Transitions was not called before commencing gesture processing")

        XCTAssertTrue(self.delegate.pinchScaleChangedMethod.wasCalled, "Pinch scale not recalculated")

        XCTAssertEqual(self.delegate.pinchScaleChangedMethod.newScale, 11.0, "New scale not calculated properly")

        XCTAssertTrue(self.delegate.pinchScaleChangedMethod.anchor == CGPoint(x: 0.0, y: 0.0),
                      "Invalid pinch center point")
    }

    func testPinchEnded() {

        let pinchGestureHandler = PinchGestureHandler(for: self.view, withDelegate: self.delegate)
        pinchGestureHandler.scale = 10.0

        let pinchGestureRecognizerMock = UIPinchGestureRecognizerMock()
        pinchGestureRecognizerMock.mockState = .ended
        pinchGestureRecognizerMock.mockScale = 2.0

        pinchGestureHandler.handlePinch(pinchGestureRecognizerMock)

        XCTAssertTrue(self.delegate.cancelTransitionsCalled,
                      "Cancel Transitions was not called before commencing gesture processing")

        XCTAssertTrue(self.delegate.pinchEndedMethod.wasCalled,
                      "View was not informed that gesture was ended")

        XCTAssertTrue(self.delegate.pinchEndedMethod.anchor == CGPoint(x: 0.0, y: 0.0),
                      "Anchor not calculated correctly")

        XCTAssertTrue(self.delegate.pinchEndedMethod.drift == false,
                      "Drift not correctly calculated")
    }
}

private class UIPinchGestureRecognizerMock: UIPinchGestureRecognizer {

    var mockState: UIGestureRecognizer.State = .began
    var mockScale: CGFloat = 2.0

    override var state: UIGestureRecognizer.State {
        get {
            return self.mockState
        } set {
            self.state = newValue
        }
    }

    override var scale: CGFloat {
        get {
            return self.mockScale
        } set {
            self.scale = newValue
        }
    }

}
