import XCTest
@testable import MapboxMaps

final class PinchGestureHandlerTests: XCTestCase {
    var view: UIView!
    var gestureRecognizer: MockPinchGestureRecognizer!
    var mapboxMap: MockMapboxMap!
    var pinchGestureHandler: PinchGestureHandler!
    // swiftlint:disable:next weak_delegate
    var delegate: MockGestureHandlerDelegate!
    var initialPinchMidpoint: CGPoint!
    let interruptingRecognizers = UIGestureRecognizer.interruptingRecognizers([.longPress, .swipe, .screenEdge, .pan])

    override func setUp() {
        super.setUp()
        view = UIView()
        gestureRecognizer = MockPinchGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        mapboxMap = MockMapboxMap()
        pinchGestureHandler = PinchGestureHandler(gestureRecognizer: gestureRecognizer, mapboxMap: mapboxMap)
        delegate = MockGestureHandlerDelegate()
        pinchGestureHandler.delegate = delegate

        pinchGestureHandler.zoomEnabled = .random()
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
        mapboxMap = nil
        gestureRecognizer = nil
        view = nil
        interruptingRecognizers.forEach { $0.view?.removeGestureRecognizer($0) }
        super.tearDown()
    }

    func sendActions(with state: UIGestureRecognizer.State, numberOfTouches: Int) {
        gestureRecognizer.getStateStub.defaultReturnValue = state
        gestureRecognizer.getNumberOfTouchesStub.defaultReturnValue = numberOfTouches
        gestureRecognizer.sendActions()
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

        XCTAssertEqual(delegate.gestureBeganStub.invocations.count, 0)
    }

    func testPinchBeganWith2Touches() throws {
        sendActions(with: .began, numberOfTouches: 2)

        verifyGestureBegan()
    }

    // the following tests are named according to which events are sent
    // which which number of touches

    func testBegin1Ended() {
        sendActions(with: .began, numberOfTouches: 1)
        sendActions(with: .ended, numberOfTouches: 1)

        XCTAssertEqual(delegate.gestureEndedStub.invocations.count, 0)
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

        XCTAssertEqual(delegate.gestureEndedStub.invocations.count, 0)
    }

    func testBegin1Changed2Ended() {
        sendActions(with: .began, numberOfTouches: 1)

        sendActions(with: .changed, numberOfTouches: 2)

        verifyGestureBegan()

        sendActions(with: .ended, numberOfTouches: 2)

        verifyGestureEnded()
    }

    func testBegin2Changed2Ended() throws {
        let initialZoom = mapboxMap.cameraState.zoom
        sendActions(with: .began, numberOfTouches: 2)

        let pinchMidpoint = CGPoint.random()
        gestureRecognizer.locationStub.defaultReturnValue = pinchMidpoint
        let pinchScale = CGFloat.random(in: 0.1..<10)
        gestureRecognizer.getScaleStub.defaultReturnValue = pinchScale
        gestureRecognizer.locationOfTouchStub.returnValueQueue = [
            CGPoint(x: 1, y: 0),
            CGPoint(x: 1, y: 1)]
        sendActions(with: .changed, numberOfTouches: 2)

        XCTAssertEqual(
            mapboxMap.setCameraStub.invocations.map(\.parameters),
            [CameraOptions(anchor: pinchMidpoint, zoom: initialZoom + log2(pinchScale))])

        sendActions(with: .ended, numberOfTouches: 2)

        verifyGestureEnded()
    }

    func testUpdate() {
        // given
        let pinchScale = CGFloat.random(in: 0.1..<10)
        let pinchMidpoint = CGPoint.random()
        let initialZoom = mapboxMap.cameraState.zoom

        gestureRecognizer.locationStub.defaultReturnValue = pinchMidpoint
        gestureRecognizer.getScaleStub.defaultReturnValue = pinchScale
        gestureRecognizer.getStateStub.returnValueQueue = [.began, .changed]

        // when
        gestureRecognizer.sendActions() // began
        gestureRecognizer.sendActions() // changed

        // then
        // verify that only one camera changed notification was emitted
        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 1)
        XCTAssertEqual(
            mapboxMap.setCameraStub.invocations.map(\.parameters),
            [CameraOptions(anchor: pinchMidpoint, zoom: initialZoom + log2(pinchScale))])

    }

    func testFocalPoint() {
        // given
        let focalPoint = CGPoint.random()
        pinchGestureHandler.focalPoint = focalPoint
        gestureRecognizer.getStateStub.returnValueQueue = [.began, .changed]

        // when
        gestureRecognizer.sendActions() // began
        gestureRecognizer.sendActions() // changed

        // then
        XCTAssertEqual(mapboxMap.setCameraStub.invocations.first?.parameters.anchor, focalPoint)
    }

    func testBegin2Changed2Changed1Changed2Ended() {
        sendActions(with: .began, numberOfTouches: 2)
        delegate.gestureBeganStub.reset()

        sendActions(with: .changed, numberOfTouches: 2)
        sendActions(with: .changed, numberOfTouches: 1)

        XCTAssertEqual(gestureRecognizer.setScaleStub.invocations.map(\.parameters), [1])

        gestureRecognizer.locationOfTouchStub.returnValueQueue = [
            CGPoint(x: -1, y: -1),
            CGPoint(x: 1, y: 1)]
        sendActions(with: .changed, numberOfTouches: 2)
        XCTAssertEqual(delegate.gestureBeganStub.invocations.count, 0)

        sendActions(with: .ended, numberOfTouches: 2)
        verifyGestureEnded()
    }

    func testSimultaneousRotateAndPinchZoomEnabledDefaultValue() {
        XCTAssertEqual(pinchGestureHandler.simultaneousRotateAndPinchZoomEnabled, true)
    }

    func testPinchGestureDelegateShouldNotPreventAlienGestures() {
        let shouldRecognize = pinchGestureHandler.gestureRecognizer(UITapGestureRecognizer(),
                                shouldRecognizeSimultaneouslyWith: UIPanGestureRecognizer())
        XCTAssertTrue(shouldRecognize)

    }

    func testPinchRecognizesSimultaneouslyWithRotationAndSingleTouchPan() {
        let singleTouchPan = UIPanGestureRecognizer()
        singleTouchPan.maximumNumberOfTouches = 1
        let recognizers = [singleTouchPan, UIRotationGestureRecognizer()]
        recognizers.forEach(view.addGestureRecognizer)

        pinchGestureHandler.assertRecognizedSimultaneously(gestureRecognizer, with: Set(recognizers))
    }

    func testPinchShouldNotRecognizeSimultaneouslyWhenRotateAndPinchDisabled() {
        let rotationRecognizer = UIRotationGestureRecognizer()
        view.addGestureRecognizer(rotationRecognizer)
        pinchGestureHandler.simultaneousRotateAndPinchZoomEnabled = false

        pinchGestureHandler.assertNotRecognizedSimultaneously(gestureRecognizer, with: [rotationRecognizer])
    }

    func testShouldNotRecognizeSimultaneouslyWithRecognizerOtherThanRotation() {
        interruptingRecognizers.forEach(view.addGestureRecognizer)

        pinchGestureHandler.assertNotRecognizedSimultaneously(gestureRecognizer, with: interruptingRecognizers)
    }

    func testShouldRecognizeSimultaneouslyWithAnyRecognizerAttachedToDifferentView() {
        pinchGestureHandler.assertRecognizedSimultaneously(gestureRecognizer, with: interruptingRecognizers)
    }
}
