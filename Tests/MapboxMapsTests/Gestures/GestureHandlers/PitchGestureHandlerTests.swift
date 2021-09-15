import XCTest
@testable import MapboxMaps

final class PitchGestureHandlerTests: XCTestCase {
    var view: UIView!
    var gestureRecognizer: MockPanGestureRecognizer!
    var mapboxMap: MockMapboxMap!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var pitchGestureHandler: PitchGestureHandler!
    // swiftlint:disable:next weak_delegate
    var delegate: MockGestureHandlerDelegate!

    override func setUp() {
        super.setUp()
        view = UIView()
        gestureRecognizer = MockPanGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        mapboxMap = MockMapboxMap()
        cameraAnimationsManager = MockCameraAnimationsManager()
        pitchGestureHandler = PitchGestureHandler(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        delegate = MockGestureHandlerDelegate()
        pitchGestureHandler.delegate = delegate
        gestureRecognizer.getNumberOfTouchesStub.defaultReturnValue = 2
    }

    override func tearDown() {
        delegate = nil
        pitchGestureHandler = nil
        cameraAnimationsManager = nil
        mapboxMap = nil
        gestureRecognizer = nil
        view = nil
        super.tearDown()
    }

    func testInitialization() {
        XCTAssertTrue(gestureRecognizer === pitchGestureHandler.gestureRecognizer)
        XCTAssertEqual(gestureRecognizer.minimumNumberOfTouches, 2)
        XCTAssertEqual(gestureRecognizer.maximumNumberOfTouches, 2)
    }

    func testGestureShouldBegin() {
        // Touch angle < 45 degrees
        gestureRecognizer.locationOfTouchStub.returnValueQueue = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 100, y: .random(in: 0..<100))]

        XCTAssertTrue(pitchGestureHandler.gestureRecognizerShouldBegin(gestureRecognizer))

        // Touch angle < 45 degrees with the opposite slope
        gestureRecognizer.locationOfTouchStub.returnValueQueue = [
            CGPoint(x: 0, y: .random(in: 0..<100)),
            CGPoint(x: 100, y: 0)]

        XCTAssertTrue(pitchGestureHandler.gestureRecognizerShouldBegin(gestureRecognizer))

        // Touch angle >= 45 degrees
        gestureRecognizer.locationOfTouchStub.returnValueQueue = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 100, y: .random(in: 100...200))]

        XCTAssertFalse(pitchGestureHandler.gestureRecognizerShouldBegin(gestureRecognizer))

        // Touch angle >= 45 degrees with the opposite slope
        gestureRecognizer.locationOfTouchStub.returnValueQueue = [
            CGPoint(x: 0, y: .random(in: 100...200)),
            CGPoint(x: 100, y: 0)]

        XCTAssertFalse(pitchGestureHandler.gestureRecognizerShouldBegin(gestureRecognizer))
    }

    func testPitchBegan() {
        gestureRecognizer.getStateStub.defaultReturnValue = .began

        gestureRecognizer.sendActions()

        XCTAssertEqual(delegate.gestureBeganStub.parameters, [.pitch])
        XCTAssertEqual(cameraAnimationsManager.cancelAnimationsStub.invocations.count, 1)
        XCTAssertEqual(gestureRecognizer.locationOfTouchStub.invocations.count, 0)
    }

    func testPitchChanged() {
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        mapboxMap.cameraState.pitch = .random(in: 0...25)
        gestureRecognizer.sendActions() // Start gesture to set it to .began
        gestureRecognizer.locationOfTouchStub.returnValueQueue = [CGPoint(x: 0, y: 0), CGPoint(x: 100, y: 0)]
        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.translationStub.defaultReturnValue = CGPoint(x: 0, y: 25)

        gestureRecognizer.sendActions()

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
        gestureRecognizer.sendActions() // Start gesture to set it to .began
        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.locationOfTouchStub.returnValueQueue = [CGPoint(x: 0, y: 0), CGPoint(x: 100, y: .random(in: 100...200))]
        gestureRecognizer.translationStub.defaultReturnValue = CGPoint(x: 0, y: 25)

        gestureRecognizer.sendActions()

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 0,
                       "pitch gesture isn't triggered if touch points equals or exceeds 45°")
    }
}
