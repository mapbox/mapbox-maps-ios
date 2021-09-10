import XCTest
@testable import MapboxMaps

final class PitchGestureHandlerTests: XCTestCase {

    var view: UIView!
    // swiftlint:disable weak_delegate
    var delegate: GestureHandlerDelegateMock!
    var mapboxMap: MockMapboxMap!

    override func setUp() {
        super.setUp()
        view = UIView()
        delegate = GestureHandlerDelegateMock()
        mapboxMap = MockMapboxMap()
    }

    override func tearDown() {
        mapboxMap = nil
        delegate = nil
        view = nil
        super.tearDown()
    }

    func testPitchSetUp() {
        let pitchGestureHandler = PitchGestureHandler(for: view, withDelegate: delegate, mapboxMap: mapboxMap)
        XCTAssert(pitchGestureHandler.gestureRecognizer is UIPanGestureRecognizer)

        // swiftlint:disable force_cast
        let pitchGesture = pitchGestureHandler.gestureRecognizer as! UIPanGestureRecognizer
        XCTAssertEqual(pitchGesture.minimumNumberOfTouches, 2)
        XCTAssertEqual(pitchGesture.maximumNumberOfTouches, 2)
    }

    func testPitchBegan() {
        let pitchGestureHandler = PitchGestureHandler(for: view, withDelegate: delegate, mapboxMap: mapboxMap)
        let pitch = UIPanGestureRecognizerMock()
        pitchGestureHandler.handlePitchGesture(pitch)
        XCTAssertTrue(delegate.gestureBeganMethod.wasCalled)
        XCTAssertEqual(delegate.gestureBeganMethod.type, GestureType.pitch)
    }

    func testPitchChanged() {
        let pitchHandler = PitchGestureHandler(for: view, withDelegate: delegate, mapboxMap: mapboxMap)
        let pitch = UIPanGestureRecognizerMock()
        pitchHandler.dragGestureTranslation = CGPoint.zero
        pitchHandler.handlePitchGesture(pitch) // Start gesture to set it to .began

        pitch.mockState = .changed
        pitchHandler.handlePitchGesture(pitch)
        XCTAssert(delegate.pitchChangedMethod.wasCalled)
        let mockPitch = pitch.mockPitchChanged
        XCTAssertEqual(delegate.pitchChangedMethod.newPitch, mockPitch)
    }

    func testPitchWillNotTrigger() {
        let pitchHandler = PitchGestureHandler(for: view, withDelegate: delegate, mapboxMap: mapboxMap)
        let pitch = UIPanGestureRecognizerMock()
        pitchHandler.dragGestureTranslation = CGPoint.zero
        pitchHandler.handlePitchGesture(pitch) // Start gesture to set it to .began

        pitch.mockState = .changed
        pitch.mockTouchPointA = CGPoint(x: 0, y: 0)
        pitch.mockTouchPointB = CGPoint(x: 100, y: 100)
        pitchHandler.handlePitchGesture(pitch)
        XCTAssertFalse(delegate.pitchChangedMethod.wasCalled,
                       "pitch gesture isn't triggered if touch points exceed 45°")
    }

    func testPitchEnded() {
        let pitchHandler = PitchGestureHandler(for: view, withDelegate: delegate, mapboxMap: mapboxMap)
        let pitch = UIPanGestureRecognizerMock()
        pitch.mockState = .ended
        pitchHandler.handlePitchGesture(pitch)

        XCTAssertTrue(delegate.pitchEndedMethod)
    }
}

// TODO: This would be better off as a UI test
private class UIPanGestureRecognizerMock: UIPanGestureRecognizer {
    var mockState: UIGestureRecognizer.State! = .began
    var mockNumberOfTouches: Int = 2
    var mockPitchChanged: CGFloat = -12.5
    var mockTouchPointA = CGPoint(x: 0, y: 0)
    var mockTouchPointB = CGPoint(x: 100, y: 25)
    var mockTranslation: CGPoint {
        return CGPoint(x: (mockTouchPointB.x - mockTouchPointA.x),
                       y: (mockTouchPointB.y - mockTouchPointA.y))
    }

    override var numberOfTouches: Int {
        return mockNumberOfTouches
    }

    override var state: UIGestureRecognizer.State {
        get {
            return self.mockState
        } set {
            self.state = newValue
        }
    }

    override func location(ofTouch touchIndex: Int, in view: UIView?) -> CGPoint {

        if state == .changed {
            if touchIndex == 0 {
                return mockTouchPointA
            }

            if touchIndex == 1 {
                return mockTouchPointB
            }
        }

        return CGPoint.zero
    }

    override func translation(in view: UIView?) -> CGPoint {
        return mockTranslation
    }
}
