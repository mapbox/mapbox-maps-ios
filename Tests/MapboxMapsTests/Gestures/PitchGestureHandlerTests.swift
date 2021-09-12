import XCTest
@testable import MapboxMaps

final class PitchGestureHandlerTests: XCTestCase {

    var view: UIView!
    var mapboxMap: MockMapboxMap!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    // swiftlint:disable:next weak_delegate
    var delegate: MockGestureManagerDelegate!

    override func setUp() {
        super.setUp()
        view = UIView()
        mapboxMap = MockMapboxMap()
        cameraAnimationsManager = MockCameraAnimationsManager()
        delegate = MockGestureManagerDelegate()
    }

    override func tearDown() {
        delegate = nil
        cameraAnimationsManager = nil
        mapboxMap = nil
        view = nil
        super.tearDown()
    }

    func testPitchSetUp() {
        let pitchGestureHandler = PitchGestureHandler(for: view, mapboxMap: mapboxMap, cameraAnimationsManager: cameraAnimationsManager)
        XCTAssert(pitchGestureHandler.gestureRecognizer is UIPanGestureRecognizer)

        // swiftlint:disable force_cast
        let pitchGesture = pitchGestureHandler.gestureRecognizer as! UIPanGestureRecognizer
        XCTAssertEqual(pitchGesture.minimumNumberOfTouches, 2)
        XCTAssertEqual(pitchGesture.maximumNumberOfTouches, 2)
    }

    func testPitchBegan() {
        let pitchGestureHandler = PitchGestureHandler(for: view, mapboxMap: mapboxMap, cameraAnimationsManager: cameraAnimationsManager)
        pitchGestureHandler.delegate = delegate
        let pitch = UIPanGestureRecognizerMock()
        pitchGestureHandler.handlePitchGesture(pitch)
        XCTAssertEqual(delegate.gestureBeganStub.parameters, [.pitch])
    }

    func testPitchChanged() {
        let pitchHandler = PitchGestureHandler(for: view, mapboxMap: mapboxMap, cameraAnimationsManager: cameraAnimationsManager)
        pitchHandler.dragGestureTranslation = CGPoint.zero
        let panGestureRecognizer = UIPanGestureRecognizerMock()
        mapboxMap.cameraState.pitch = .random(in: 0...25)
        pitchHandler.handlePitchGesture(panGestureRecognizer) // Start gesture to set it to .began
        panGestureRecognizer.mockState = .changed

        pitchHandler.handlePitchGesture(panGestureRecognizer)

        XCTAssertEqual(mapboxMap.setCameraStub.parameters, [CameraOptions(pitch: mapboxMap.cameraState.pitch - (panGestureRecognizer.mockTranslation.y / 2))])
    }

    func testPitchWillNotTrigger() {
        let pitchHandler = PitchGestureHandler(for: view, mapboxMap: mapboxMap, cameraAnimationsManager: cameraAnimationsManager)
        let pitch = UIPanGestureRecognizerMock()
        pitchHandler.dragGestureTranslation = CGPoint.zero
        pitchHandler.handlePitchGesture(pitch) // Start gesture to set it to .began

        pitch.mockState = .changed
        pitch.mockTouchPointA = CGPoint(x: 0, y: 0)
        pitch.mockTouchPointB = CGPoint(x: 100, y: .random(in: 100...200))
        pitchHandler.handlePitchGesture(pitch)
        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 0,
                       "pitch gesture isn't triggered if touch points equals or exceeds 45°")
    }
}

private class UIPanGestureRecognizerMock: UIPanGestureRecognizer {
    var mockState: UIGestureRecognizer.State! = .began
    var mockNumberOfTouches: Int = 2
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
