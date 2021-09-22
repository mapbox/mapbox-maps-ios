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
        cameraAnimationsManager = MockCameraAnimationsManager()
        dateProvider = MockDateProvider()
        panGestureHandler = PanGestureHandler(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager,
            dateProvider: dateProvider)
        delegate = MockGestureHandlerDelegate()
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

        XCTAssertEqual(cameraAnimationsManager.cancelAnimationsStub.invocations.count, 1)
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
        cameraAnimationsManager.cancelAnimationsStub.reset()
        gestureRecognizer.getStateStub.defaultReturnValue = .changed

        gestureRecognizer.sendActions()

        XCTAssertEqual(cameraAnimationsManager.cancelAnimationsStub.invocations.count, 1, line: line)
        XCTAssertEqual(mapboxMap.dragStartStub.parameters, [initialTouchLocation], line: line)
        XCTAssertEqual(mapboxMap.dragCameraOptionsStub.parameters, [
                        .init(from: initialTouchLocation, to: clampedTouchLocation)], line: line)
        let dragCameraOptions = try XCTUnwrap(mapboxMap.dragCameraOptionsStub.returnedValues.first, line: line)
        XCTAssertEqual(mapboxMap.setCameraStub.parameters, [
                        CameraOptions(cameraState: mapboxMap.cameraState),
                        dragCameraOptions], line: line)
        XCTAssertEqual(mapboxMap.dragEndStub.invocations.count, 1, line: line)
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

    func testHandlePanChangedWithHorizontalPanScrollingMode() throws {
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

    func testHandlePanChangedWithVerticalPanScrollingMode() throws {
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
        let initialCameraState = CameraState.random()
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
        cameraAnimationsManager.cancelAnimationsStub.reset()
        mapboxMap.dragStartStub.reset()
        mapboxMap.dragCameraOptionsStub.reset()
        mapboxMap.dragEndStub.reset()
        mapboxMap.setCameraStub.reset()
        mapboxMap.dragCameraOptionsStub.defaultReturnValue = .random()

        gestureRecognizer.getStateStub.defaultReturnValue = .ended
        gestureRecognizer.sendActions()

        XCTAssertEqual(cameraAnimationsManager.decelerateStub.invocations.count, 1, line: line)
        let decelerateParams = cameraAnimationsManager.decelerateStub.parameters.first
        XCTAssertEqual(decelerateParams?.location, endedTouchLocation, line: line)
        XCTAssertEqual(decelerateParams?.velocity, velocity, line: line)
        XCTAssertEqual(decelerateParams?.decelerationFactor, panGestureHandler.decelerationFactor, line: line)
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

    func testHandlePanEndedWithHorizontalPanScrollingMode() throws {
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

    func testHandlePanEndedWithVerticalPanScrollingMode() throws {
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

    func testHandlePanCancelledDoesNotTriggerDecelerationAnimation() {
        gestureRecognizer.getStateStub.defaultReturnValue = .cancelled

        gestureRecognizer.sendActions()

        XCTAssertEqual(cameraAnimationsManager.decelerateStub.invocations.count, 0)
    }

    func testSecondPanGesturePerformsCorrectlyWhenInterruptingDecelerationFromFirstPanGesture() throws {
        gestureRecognizer.getStateStub.returnValueQueue = [.began, .changed, .ended, .began, .changed]
        gestureRecognizer.sendActions() // began 1
        gestureRecognizer.sendActions() // changed 1
        gestureRecognizer.sendActions() // ended 1

        // began 2 - triggers decelerate animation completion as a side effect of cancelling animations
        let decelerateAnimationCompletion = try XCTUnwrap(cameraAnimationsManager.decelerateStub.parameters.first?.completion)
        cameraAnimationsManager.cancelAnimationsStub.sideEffectQueue.append { _ in
            decelerateAnimationCompletion()
        }
        gestureRecognizer.sendActions()
        mapboxMap.setCameraStub.reset()

        // changed 2 should still result in camera updates. a previous
        // implementation had a bug here where the cancellation of the animation
        // cleared the initial state for the subsequent gesture
        gestureRecognizer.sendActions()

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 2)
    }
}
