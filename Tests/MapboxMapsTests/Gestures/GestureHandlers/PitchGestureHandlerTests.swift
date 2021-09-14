import XCTest
@testable import MapboxMaps

final class PitchGestureHandlerTests: XCTestCase {

    var view: UIView!
    var mapboxMap: MockMapboxMap!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var pitchGestureHandler: PitchGestureHandler!
    // swiftlint:disable:next weak_delegate
    var delegate: MockGestureHandlerDelegate!
    var gestureRecognizer: MockPanGestureRecognizer!

    override func setUp() {
        super.setUp()
        view = UIView()
        mapboxMap = MockMapboxMap()
        cameraAnimationsManager = MockCameraAnimationsManager()
        pitchGestureHandler = PitchGestureHandler(
            view: view,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        delegate = MockGestureHandlerDelegate()
        pitchGestureHandler.delegate = delegate
        gestureRecognizer = MockPanGestureRecognizer()
        gestureRecognizer.getViewStub.defaultReturnValue = view
        gestureRecognizer.getNumberOfTouchesStub.defaultReturnValue = 2
    }

    override func tearDown() {
        gestureRecognizer = nil
        delegate = nil
        pitchGestureHandler = nil
        cameraAnimationsManager = nil
        mapboxMap = nil
        view = nil
        super.tearDown()
    }

    func testInitialization() {
        XCTAssertTrue(view.gestureRecognizers?.last === pitchGestureHandler.gestureRecognizer)
        XCTAssertEqual(pitchGestureHandler.gestureRecognizer.minimumNumberOfTouches, 2)
        XCTAssertEqual(pitchGestureHandler.gestureRecognizer.maximumNumberOfTouches, 2)
    }

    func testPitchBegan() {
        gestureRecognizer.getStateStub.defaultReturnValue = .began

        pitchGestureHandler.handlePitchGesture(gestureRecognizer)

        XCTAssertEqual(delegate.gestureBeganStub.parameters, [.pitch])
        XCTAssertEqual(cameraAnimationsManager.cancelAnimationsStub.invocations.count, 1)
        XCTAssertEqual(gestureRecognizer.locationOfTouchStub.invocations.count, 0)
    }

    func testPitchChanged() {
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        mapboxMap.cameraState.pitch = .random(in: 0...25)
        pitchGestureHandler.handlePitchGesture(gestureRecognizer) // Start gesture to set it to .began
        gestureRecognizer.locationOfTouchStub.returnValueQueue = [CGPoint(x: 0, y: 0), CGPoint(x: 100, y: 0)]
        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.minimumNumberOfTouches = 2
        gestureRecognizer.translationStub.defaultReturnValue = CGPoint(x: 0, y: 25)

        pitchGestureHandler.handlePitchGesture(gestureRecognizer)

        XCTAssertEqual(gestureRecognizer.locationOfTouchStub.invocations.count, 2)
        guard gestureRecognizer.locationOfTouchStub.invocations.count == 2 else {
            return
        }
        XCTAssertEqual(gestureRecognizer.locationOfTouchStub.parameters[0].touchIndex, 0)
        XCTAssertEqual(gestureRecognizer.locationOfTouchStub.parameters[1].touchIndex, 1)
        XCTAssertEqual(mapboxMap.setCameraStub.parameters, [CameraOptions(pitch: mapboxMap.cameraState.pitch - 12.5)])
    }

    func testPitchWillNotTrigger() {
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        pitchGestureHandler.handlePitchGesture(gestureRecognizer) // Start gesture to set it to .began
        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.locationOfTouchStub.returnValueQueue = [CGPoint(x: 0, y: 0), CGPoint(x: 100, y: .random(in: 100...200))]
        gestureRecognizer.translationStub.defaultReturnValue = CGPoint(x: 0, y: 25)

        pitchGestureHandler.handlePitchGesture(gestureRecognizer)

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 0,
                       "pitch gesture isn't triggered if touch points equals or exceeds 45°")
    }
}
