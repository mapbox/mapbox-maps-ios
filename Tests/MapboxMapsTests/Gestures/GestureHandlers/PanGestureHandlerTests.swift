import XCTest
@testable import MapboxMaps

final class PanGestureHandlerTests: XCTestCase {
    var view: UIView!
    var gestureRecognizer: MockPanGestureRecognizer!
    var mapboxMap: MockMapboxMap!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var dateProvider: MockDateProvider!
    var panGestureHandler: PanGestureHandler!
    // swiftlint:disable:next weak_delegate
    var delegate: MockGestureHandlerDelegate!

    override func setUp() {
        super.setUp()
        view = UIView()
        gestureRecognizer = MockPanGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        mapboxMap = MockMapboxMap()
        delegate = MockGestureHandlerDelegate()
        cameraAnimationsManager = MockCameraAnimationsManager()
        dateProvider = MockDateProvider()
        panGestureHandler = PanGestureHandler(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager,
            dateProvider: dateProvider)
        panGestureHandler.delegate = delegate
        panGestureHandler.decelerationFactor = .random(in: 0.99...0.999)
        panGestureHandler.panMode = PanMode.allCases.randomElement()!
    }

    override func tearDown() {
        delegate = nil
        panGestureHandler = nil
        dateProvider = nil
        cameraAnimationsManager = nil
        mapboxMap = nil
        gestureRecognizer = nil
        view = nil
        super.tearDown()
    }

    func testInitialization() {
        XCTAssertEqual(gestureRecognizer.maximumNumberOfTouches, 1)
        XCTAssertTrue(gestureRecognizer === panGestureHandler.gestureRecognizer)
    }

    func testHandlePanBegan() {
        gestureRecognizer.getStateStub.defaultReturnValue = .began

        gestureRecognizer.sendActions()

        XCTAssertEqual(delegate.gestureBeganStub.parameters, [.pan])
    }

    func verifyHandlePanChanged(panMode: PanMode,
                                initialTouchLocation: CGPoint,
                                changedTouchLocation: CGPoint,
                                clampedTouchLocation: CGPoint,
                                line: UInt = #line) throws {
        let initialCameraState = CameraState.random()
        mapboxMap.cameraState = initialCameraState
        mapboxMap.dragCameraOptionsStub.defaultReturnValue = .random()
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        gestureRecognizer.locationStub.returnValueQueue = [
            initialTouchLocation, changedTouchLocation]
        panGestureHandler.panMode = panMode
        gestureRecognizer.sendActions()
        gestureRecognizer.getStateStub.defaultReturnValue = .changed

        gestureRecognizer.sendActions()

        XCTAssertEqual(mapboxMap.dragStartStub.parameters, [initialTouchLocation], line: line)
        XCTAssertEqual(mapboxMap.dragCameraOptionsStub.parameters, [
                        .init(from: initialTouchLocation, to: clampedTouchLocation)], line: line)
        let dragCameraOptions = try XCTUnwrap(mapboxMap.dragCameraOptionsStub.returnedValues.first, line: line)
        XCTAssertEqual(mapboxMap.setCameraStub.parameters, [
                        CameraOptions(cameraState: mapboxMap.cameraState),
                        dragCameraOptions], line: line)
        XCTAssertEqual(mapboxMap.dragEndStub.invocations.count, 1, line: line)
        if delegate.gestureEndedStub.parameters.first?.willAnimate == true {
            XCTAssertEqual(delegate.animationEndedStub.invocations.count, 1)
            XCTAssertEqual(delegate.animationEndedStub.parameters, [.pan])
        }
    }

    func testHandlePanChanged() throws {
        let initialTouchLocation = CGPoint.random()
        let changedTouchLocation = CGPoint.random()
        let clampedTouchLocation = changedTouchLocation

        try verifyHandlePanChanged(
            panMode: .horizontalAndVertical,
            initialTouchLocation: initialTouchLocation,
            changedTouchLocation: changedTouchLocation,
            clampedTouchLocation: clampedTouchLocation)
    }

    func testHandlePanChangedWithHorizontalPanMode() throws {
        let initialTouchLocation = CGPoint.random()
        let changedTouchLocation = CGPoint.random()
        let clampedTouchLocation = CGPoint(
            x: changedTouchLocation.x,
            y: initialTouchLocation.y)

        try verifyHandlePanChanged(
            panMode: .horizontal,
            initialTouchLocation: initialTouchLocation,
            changedTouchLocation: changedTouchLocation,
            clampedTouchLocation: clampedTouchLocation)
    }

    func testHandlePanChangedWithVerticalPanMode() throws {
        let initialTouchLocation = CGPoint.random()
        let changedTouchLocation = CGPoint.random()
        let clampedTouchLocation = CGPoint(
            x: initialTouchLocation.x,
            y: changedTouchLocation.y)

        try verifyHandlePanChanged(
            panMode: .vertical,
            initialTouchLocation: initialTouchLocation,
            changedTouchLocation: changedTouchLocation,
            clampedTouchLocation: clampedTouchLocation)
    }

    func testHandlePanEndedAfterDelay() {
        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.sendActions()
        dateProvider.nowStub.defaultReturnValue += 2.0 / 60.0 + .leastNonzeroMagnitude

        gestureRecognizer.getStateStub.defaultReturnValue = .ended
        gestureRecognizer.sendActions()

        XCTAssertEqual(cameraAnimationsManager.decelerateStub.invocations.count, 0)
    }

    func verifyHandlePanEnded(panMode: PanMode,
                              initialTouchLocation: CGPoint,
                              interpolatedTouchLocation: CGPoint,
                              clampedTouchLocation: CGPoint,
                              line: UInt = #line) throws {
        panGestureHandler.panMode = panMode
        panGestureHandler.decelerationFactor = .random(in: 0.1...0.99)
        var initialCameraState = CameraState.random()
        initialCameraState.pitch = initialCameraState.pitch.clamped(to: 0...60)
        mapboxMap.cameraState = initialCameraState
        let endedTouchLocation = CGPoint.random()
        gestureRecognizer.locationStub.returnValueQueue = [
            initialTouchLocation, .random(), endedTouchLocation]
        let velocity = CGPoint.random()
        gestureRecognizer.velocityStub.defaultReturnValue = velocity
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        gestureRecognizer.sendActions()
        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.sendActions()
        mapboxMap.dragStartStub.reset()
        mapboxMap.dragCameraOptionsStub.reset()
        mapboxMap.dragEndStub.reset()
        mapboxMap.setCameraStub.reset()
        mapboxMap.dragCameraOptionsStub.defaultReturnValue = .random()

        gestureRecognizer.getStateStub.defaultReturnValue = .ended
        gestureRecognizer.sendActions()

        XCTAssertEqual(delegate.gestureEndedStub.invocations.count, 1)
        XCTAssertEqual(delegate.gestureEndedStub.parameters.first?.gestureType, .pan)
        let willAnimate = try XCTUnwrap(delegate.gestureEndedStub.parameters.first?.willAnimate)
        XCTAssertTrue(willAnimate)

        XCTAssertEqual(cameraAnimationsManager.decelerateStub.invocations.count, 1, line: line)
        let decelerateParams = cameraAnimationsManager.decelerateStub.parameters.first
        XCTAssertEqual(decelerateParams?.location, endedTouchLocation, line: line)
        XCTAssertEqual(decelerateParams?.velocity, velocity, line: line)
        XCTAssertEqual(decelerateParams?.decelerationFactor, panGestureHandler.decelerationFactor * (1 - initialCameraState.pitch / 5000), line: line)
        let locationChangeHandler = try XCTUnwrap(decelerateParams?.locationChangeHandler)
        locationChangeHandler(interpolatedTouchLocation)
        XCTAssertEqual(mapboxMap.dragStartStub.parameters, [initialTouchLocation], line: line)
        XCTAssertEqual(mapboxMap.dragCameraOptionsStub.parameters, [
                        .init(from: initialTouchLocation, to: clampedTouchLocation)], line: line)
        let dragCameraOptions = try XCTUnwrap(mapboxMap.dragCameraOptionsStub.returnedValues.first, line: line)
        XCTAssertEqual(mapboxMap.setCameraStub.parameters, [
                        CameraOptions(cameraState: initialCameraState),
                        dragCameraOptions], line: line)
        XCTAssertEqual(mapboxMap.dragEndStub.invocations.count, 1, line: line)

        let animationEndedCompletion = try XCTUnwrap(decelerateParams?.completion)
        animationEndedCompletion()

        XCTAssertEqual(delegate.animationEndedStub.parameters, [.pan])
    }

    func testHandlePanEnded() throws {
        let initialTouchLocation = CGPoint.random()
        let interpolatedTouchLocation = CGPoint.random()
        let clampedTouchLocation = interpolatedTouchLocation

        try verifyHandlePanEnded(
            panMode: .horizontalAndVertical,
            initialTouchLocation: initialTouchLocation,
            interpolatedTouchLocation: interpolatedTouchLocation,
            clampedTouchLocation: clampedTouchLocation)
    }

    func testHandlePanEndedWithHorizontalPanMode() throws {
        let initialTouchLocation = CGPoint.random()
        let interpolatedTouchLocation = CGPoint.random()
        let clampedTouchLocation =  CGPoint(
            x: interpolatedTouchLocation.x,
            y: initialTouchLocation.y)

        try verifyHandlePanEnded(
            panMode: .horizontal,
            initialTouchLocation: initialTouchLocation,
            interpolatedTouchLocation: interpolatedTouchLocation,
            clampedTouchLocation: clampedTouchLocation)
    }

    func testHandlePanEndedWithVerticalPanMode() throws {
        let initialTouchLocation = CGPoint.random()
        let interpolatedTouchLocation = CGPoint.random()
        let clampedTouchLocation =  CGPoint(
            x: initialTouchLocation.x,
            y: interpolatedTouchLocation.y)

        try verifyHandlePanEnded(
            panMode: .vertical,
            initialTouchLocation: initialTouchLocation,
            interpolatedTouchLocation: interpolatedTouchLocation,
            clampedTouchLocation: clampedTouchLocation)
    }

    func testHandlePanEndedWithPitchGreaterThan60DoesNotDecelerate() throws {
        mapboxMap.cameraState = .random()
        mapboxMap.cameraState.pitch = 61
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        gestureRecognizer.sendActions()
        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.sendActions()

        gestureRecognizer.getStateStub.defaultReturnValue = .ended
        gestureRecognizer.sendActions()

        XCTAssertEqual(delegate.gestureEndedStub.invocations.count, 1)
        XCTAssertEqual(delegate.gestureEndedStub.parameters.first?.gestureType, .pan)
        let willAnimate = try XCTUnwrap(delegate.gestureEndedStub.parameters.first?.willAnimate)
        XCTAssertFalse(willAnimate)
    }

    func testHandlePanCancelledDoesNotTriggerDecelerationAnimation() throws {
        gestureRecognizer.getStateStub.defaultReturnValue = .cancelled

        gestureRecognizer.sendActions()

        XCTAssertEqual(cameraAnimationsManager.decelerateStub.invocations.count, 0)
        XCTAssertEqual(delegate.gestureEndedStub.invocations.count, 1)
        let gestureType = try XCTUnwrap(delegate.gestureEndedStub.parameters.first?.gestureType)
        XCTAssertEqual(gestureType, GestureType.pan)
        let willAnimate = try XCTUnwrap(delegate.gestureEndedStub.parameters.first?.willAnimate)
        XCTAssertFalse(willAnimate)
    }

    func testSecondPanGesturePerformsCorrectlyWhenInterruptingDecelerationFromFirstPanGesture() throws {
        gestureRecognizer.getStateStub.returnValueQueue = [.began, .changed, .ended, .began, .changed]
        gestureRecognizer.sendActions() // began 1
        gestureRecognizer.sendActions() // changed 1
        gestureRecognizer.sendActions() // ended 1

        // began 2
        gestureRecognizer.sendActions()
        mapboxMap.setCameraStub.reset()

        // cancel deceleration *after* the second gesture begins
        let decelerateAnimationCompletion = try XCTUnwrap(cameraAnimationsManager.decelerateStub.parameters.first?.completion)
        decelerateAnimationCompletion()

        // changed 2 should still result in camera updates. a previous
        // implementation had a bug here where the cancellation of the animation
        // cleared the initial state for the subsequent gesture
        gestureRecognizer.sendActions()

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 2)
    }
}
