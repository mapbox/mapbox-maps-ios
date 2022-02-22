import XCTest
@testable import MapboxMaps

final class PitchGestureHandlerTests: XCTestCase {
    var view: UIView!
    var gestureRecognizer: MockPanGestureRecognizer!
    var mapboxMap: MockMapboxMap!
    var pitchGestureHandler: PitchGestureHandler!
    // swiftlint:disable:next weak_delegate
    var delegate: MockGestureHandlerDelegate!

    override func setUp() {
        super.setUp()
        view = UIView()
        gestureRecognizer = MockPanGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        mapboxMap = MockMapboxMap()
        pitchGestureHandler = PitchGestureHandler(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap)
        delegate = MockGestureHandlerDelegate()
        pitchGestureHandler.delegate = delegate
        gestureRecognizer.getNumberOfTouchesStub.defaultReturnValue = 2
    }

    override func tearDown() {
        delegate = nil
        pitchGestureHandler = nil
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

        XCTAssertEqual(mapboxMap.setCameraStub.parameters, [CameraOptions(pitch: mapboxMap.cameraState.pitch - 12.5)])
    }

    func testPitchEnded() throws {
        gestureRecognizer.getStateStub.defaultReturnValue = .ended

        gestureRecognizer.sendActions()

        assertMethodCall(delegate.gestureEndedStub)
        XCTAssertEqual(delegate.gestureEndedStub.parameters.first?.gestureType, .pitch)

        let willAnimate = try XCTUnwrap(delegate.gestureEndedStub.parameters.first?.willAnimate)
        XCTAssertFalse(willAnimate)
    }
}
