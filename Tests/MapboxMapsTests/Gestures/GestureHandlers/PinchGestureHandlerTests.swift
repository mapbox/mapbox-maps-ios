import XCTest
@testable import MapboxMaps

final class PinchGestureHandlerTests: XCTestCase {
    var view: UIView!
    var gestureRecognizer: MockPinchGestureRecognizer!
    var mapboxMap: MockMapboxMap!
    var pinchBehaviorProvider: MockPinchBehaviorProvider!
    var pinchGestureHandler: PinchGestureHandler!
    // swiftlint:disable:next weak_delegate
    var delegate: MockGestureHandlerDelegate!
    var initialPinchMidpoint: CGPoint!

    override func setUp() {
        super.setUp()
        view = UIView()
        gestureRecognizer = MockPinchGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        mapboxMap = MockMapboxMap()
        pinchBehaviorProvider = MockPinchBehaviorProvider()
        pinchGestureHandler = PinchGestureHandler(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap,
            pinchBehaviorProvider: pinchBehaviorProvider)
        delegate = MockGestureHandlerDelegate()
        pinchGestureHandler.delegate = delegate

        pinchGestureHandler.panEnabled = .random()
        pinchGestureHandler.zoomEnabled = .random()
        pinchGestureHandler.rotateEnabled = .random()
        gestureRecognizer.locationOfTouchStub.returnValueQueue = [
            CGPoint(x: -1, y: -1),
            CGPoint(x: 1, y: 1)]
        initialPinchMidpoint = CGPoint(x: 0.0, y: 0.0)
        mapboxMap.cameraState = .random()
    }

    override func tearDown() {
        initialPinchMidpoint = nil
        delegate = nil
        pinchGestureHandler = nil
        pinchBehaviorProvider = nil
        mapboxMap = nil
        gestureRecognizer = nil
        view = nil
        super.tearDown()
    }

    func sendActions(with state: UIGestureRecognizer.State, numberOfTouches: Int) {
        gestureRecognizer.getStateStub.defaultReturnValue = state
        gestureRecognizer.getNumberOfTouchesStub.defaultReturnValue = numberOfTouches
        gestureRecognizer.sendActions()
    }

    func verifyMakePinchBehavior() {
        guard pinchBehaviorProvider.makePinchBehaviorStub.invocations.count == 1 else {
            XCTFail("makePinchBehavior was not invoked exactly 1 time.")
            return
        }
        let parameters = pinchBehaviorProvider.makePinchBehaviorStub.invocations[0].parameters
        XCTAssertEqual(parameters.panEnabled, pinchGestureHandler.panEnabled)
        XCTAssertEqual(parameters.zoomEnabled, pinchGestureHandler.zoomEnabled)
        XCTAssertEqual(parameters.rotateEnabled, pinchGestureHandler.rotateEnabled)
        XCTAssertEqual(parameters.initialCameraState, mapboxMap.cameraState)
        XCTAssertEqual(parameters.initialPinchMidpoint, initialPinchMidpoint)
        XCTAssertEqual(parameters.initialPinchAngle, .pi / 4)
    }

    func verifyGestureBegan() {
        XCTAssertEqual(delegate.gestureBeganStub.invocations.map(\.parameters), [.pinch])
    }

    func verifyGestureEnded() {
        XCTAssertEqual(
            delegate.gestureEndedStub.invocations.map(\.parameters),
            [.init(gestureType: .pinch, willAnimate: false)])
    }

    func testInitialization() {
        XCTAssertTrue(gestureRecognizer === pinchGestureHandler.gestureRecognizer)
    }

    // This doesn't seem like a scenario that would actually happen; however, we received
    // crash reports that suggest that it does in some situations, so we added some
    // defensive mechanisms to make sure it does not result in a crash. We confirmed that
    // these changes cleared up the crashes for the developers who were seeing them.
    func testPinchBeganWith1Touch() {
        sendActions(with: .began, numberOfTouches: 1)

        assertMethodNotCall(pinchBehaviorProvider.makePinchBehaviorStub)
        assertMethodNotCall(delegate.gestureBeganStub)
    }

    func testPinchBeganWith2Touches() throws {
        sendActions(with: .began, numberOfTouches: 2)

        verifyMakePinchBehavior()
        verifyGestureBegan()
    }

    // the following tests are named according to which events are sent
    // which which number of touches

    func testBegin1Ended() {
        sendActions(with: .began, numberOfTouches: 1)
        sendActions(with: .ended, numberOfTouches: 1)

        assertMethodNotCall(delegate.gestureEndedStub)
    }

    func testBegin2Ended() {
        sendActions(with: .began, numberOfTouches: 2)
        sendActions(with: .ended, numberOfTouches: 2)

        verifyGestureEnded()
    }

    func testBegin1Changed1Ended() {
        sendActions(with: .began, numberOfTouches: 1)
        sendActions(with: .changed, numberOfTouches: 1)
        sendActions(with: .ended, numberOfTouches: 1)

        assertMethodNotCall(delegate.gestureEndedStub)
    }

    func testBegin1Changed2Ended() {
        sendActions(with: .began, numberOfTouches: 1)

        sendActions(with: .changed, numberOfTouches: 2)

        verifyMakePinchBehavior()
        verifyGestureBegan()

        sendActions(with: .ended, numberOfTouches: 2)

        verifyGestureEnded()
    }

    func testBegin2Changed2Ended() throws {
        sendActions(with: .began, numberOfTouches: 2)

        let pinchMidpoint = CGPoint.random()
        gestureRecognizer.locationStub.defaultReturnValue = pinchMidpoint
        let pinchScale = CGFloat.random(in: 0.1..<10)
        gestureRecognizer.getScaleStub.defaultReturnValue = pinchScale
        gestureRecognizer.locationOfTouchStub.returnValueQueue = [
            CGPoint(x: 1, y: 0),
            CGPoint(x: 1, y: 1)]
        sendActions(with: .changed, numberOfTouches: 2)

        let behavior = try XCTUnwrap(
            pinchBehaviorProvider.makePinchBehaviorStub.invocations.first?.returnValue as? MockPinchBehavior)
        XCTAssertEqual(
            behavior.updateStub.invocations.map(\.parameters),
            [.init(
                pinchMidpoint: pinchMidpoint,
                pinchScale: pinchScale,
                pinchAngle: .pi / 2)])

        sendActions(with: .ended, numberOfTouches: 2)

        verifyGestureEnded()
    }

    func testBegin2Changed2Changed1Changed2Ended() {
        sendActions(with: .began, numberOfTouches: 2)
        pinchBehaviorProvider.makePinchBehaviorStub.reset()
        delegate.gestureBeganStub.reset()

        sendActions(with: .changed, numberOfTouches: 2)
        sendActions(with: .changed, numberOfTouches: 1)

        XCTAssertEqual(gestureRecognizer.setScaleStub.invocations.map(\.parameters), [1])

        gestureRecognizer.locationOfTouchStub.returnValueQueue = [
            CGPoint(x: -1, y: -1),
            CGPoint(x: 1, y: 1)]
        sendActions(with: .changed, numberOfTouches: 2)
        verifyMakePinchBehavior()
        assertMethodNotCall(delegate.gestureBeganStub)

        sendActions(with: .ended, numberOfTouches: 2)
        verifyGestureEnded()
    }
}
