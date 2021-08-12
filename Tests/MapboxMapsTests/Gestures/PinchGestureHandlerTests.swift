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
        pinchGestureRecognizerMock.mockState = .began
        pinchGestureRecognizerMock.mockScale = 2.0
        pinchGestureRecognizerMock.mockLocationInView = CGPoint(x: 0.0, y: 0.0)
        pinchGestureRecognizerMock.mockNumberOfTouches = 2

        pinchGestureHandler.handlePinch(pinchGestureRecognizerMock)

        pinchGestureRecognizerMock.mockState = .changed
        pinchGestureHandler.handlePinch(pinchGestureRecognizerMock)

        XCTAssertTrue(delegate.cancelTransitionsCalled,
                      "Cancel Transitions was not called before commencing gesture processing")
        XCTAssertEqual(delegate.pinchChangedStub.invocations.count, 1)

        pinchGestureRecognizerMock.mockLocationInView = CGPoint(x: 1.0, y: 1.0)
        pinchGestureHandler.handlePinch(pinchGestureRecognizerMock)

        XCTAssertEqual(delegate.pinchChangedStub.invocations.count, 2)
        XCTAssertEqual(delegate.pinchChangedStub.invocations.last?.parameters.targetAnchor,
                       CGPoint(x: 1.0, y: 1.0),
                       "Offset not calculated correctly")
        XCTAssertEqual(delegate.pinchChangedStub.invocations.last?.parameters.initialAnchor,
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

        XCTAssertEqual(delegate.pinchEndedStub.invocations.count,
                       1,
                      "View was not informed that gesture was ended")
    }
}

private class UIPinchGestureRecognizerMock: UIPinchGestureRecognizer {

    var mockState: UIGestureRecognizer.State = .began
    var mockScale: CGFloat = 2.0
    var mockCenter: CGPoint = .zero
    var mockLocationInView: CGPoint = .zero
    var mockNumberOfTouches: Int = 1

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

    override var numberOfTouches: Int {
        return self.mockNumberOfTouches
    }

    override func location(in view: UIView?) -> CGPoint {
        return mockLocationInView
    }
}
