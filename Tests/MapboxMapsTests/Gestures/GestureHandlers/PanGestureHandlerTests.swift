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
        let touchLocation = CGPoint.random()
        gestureRecognizer.locationStub.defaultReturnValue = touchLocation

        gestureRecognizer.sendActions()

        XCTAssertEqual(mapboxMap.dragStartStub.parameters, [touchLocation])
        XCTAssertEqual(delegate.gestureBeganStub.parameters, [.pan])
    }

    func verifyHandlePanChanged(panMode: PanMode,
                                initialTouchLocation: CGPoint,
                                clampingFunction: (CGPoint) -> CGPoint,
                                line: UInt = #line) throws {
        let initialCameraState = CameraState.random()
        mapboxMap.cameraState = initialCameraState
        mapboxMap.dragCameraOptionsStub.defaultReturnValue = .random()
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        let touchLocations: [CGPoint] = [initialTouchLocation, .random(), .random()]
        gestureRecognizer.locationStub.returnValueQueue = touchLocations
        panGestureHandler.panMode = panMode
        gestureRecognizer.sendActions()

        gestureRecognizer.getStateStub.defaultReturnValue = .changed

        for idx in 1..<touchLocations.count {
            mapboxMap.dragCameraOptionsStub.reset()
            mapboxMap.setCameraStub.reset()

            gestureRecognizer.sendActions()

            XCTAssertEqual(mapboxMap.dragCameraOptionsStub.parameters, [
                .init(from: clampingFunction(touchLocations[idx - 1]), to: clampingFunction(touchLocations[idx]))], line: line)
            let dragCameraOptions = try XCTUnwrap(mapboxMap.dragCameraOptionsStub.returnedValues.first, line: line)
            XCTAssertEqual(mapboxMap.setCameraStub.parameters, [dragCameraOptions], line: line)
        }
    }

    func testHandlePanChanged() throws {
        try verifyHandlePanChanged(
            panMode: .horizontalAndVertical,
            initialTouchLocation: .random(),
            clampingFunction: { $0 })
    }

    func testHandlePanChangedWithHorizontalPanMode() throws {
        let initialTouchLocation = CGPoint.random()

        try verifyHandlePanChanged(
            panMode: .horizontal,
            initialTouchLocation: initialTouchLocation,
            clampingFunction: {
                CGPoint(
                    x: $0.x,
                    y: initialTouchLocation.y)
            })
    }

    func testHandlePanChangedWithVerticalPanMode() throws {
        let initialTouchLocation = CGPoint.random()

        try verifyHandlePanChanged(
            panMode: .vertical,
            initialTouchLocation: initialTouchLocation,
            clampingFunction: {
                CGPoint(
                    x: initialTouchLocation.x,
                    y: $0.y)
            })
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
                              endedTouchLocation: CGPoint,
                              clampingFunction: (CGPoint) -> (CGPoint),
                              line: UInt = #line) throws {
        panGestureHandler.panMode = panMode
        panGestureHandler.decelerationFactor = .random(in: 0.1...0.99)
        var initialCameraState = CameraState.random()
        initialCameraState.pitch = initialCameraState.pitch.clamped(to: 0...60)
        mapboxMap.cameraState = initialCameraState
        let initialTouchLocation = CGPoint.random()
        let touchLocations = [initialTouchLocation, endedTouchLocation, endedTouchLocation]
        gestureRecognizer.locationStub.returnValueQueue = touchLocations
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

        XCTAssertEqual(delegate.gestureEndedStub.parameters, [.init(gestureType: .pan, willAnimate: true)], line: line)

        XCTAssertEqual(cameraAnimationsManager.decelerateStub.invocations.count, 1, line: line)
        let decelerateParams = cameraAnimationsManager.decelerateStub.parameters.first
        XCTAssertEqual(decelerateParams?.location, endedTouchLocation, line: line)
        XCTAssertEqual(decelerateParams?.velocity, velocity, line: line)
        XCTAssertEqual(decelerateParams?.decelerationFactor, panGestureHandler.decelerationFactor, line: line)

        let interpolatedLocations: [CGPoint] = [.random(), .random()]
        let previousLocations = [endedTouchLocation, interpolatedLocations[0]]
        for i in 0..<interpolatedLocations.count {
            mapboxMap.dragCameraOptionsStub.reset()
            mapboxMap.setCameraStub.reset()

            let locationChangeHandler = try XCTUnwrap(decelerateParams?.locationChangeHandler)
            locationChangeHandler(interpolatedLocations[i])
            XCTAssertEqual(
                mapboxMap.dragCameraOptionsStub.parameters,
                [.init(
                    from: clampingFunction(previousLocations[i]),
                    to: clampingFunction(interpolatedLocations[i]))],
                line: line)
            let dragCameraOptions = try XCTUnwrap(mapboxMap.dragCameraOptionsStub.returnedValues.first, line: line)
            XCTAssertEqual(mapboxMap.setCameraStub.parameters, [dragCameraOptions], line: line)
        }

        let animationEndedCompletion = try XCTUnwrap(decelerateParams?.completion)
        animationEndedCompletion()

        XCTAssertEqual(mapboxMap.dragEndStub.invocations.count, 1)
        XCTAssertEqual(delegate.animationEndedStub.parameters, [.pan])
    }

    func testHandlePanEnded() throws {
        try verifyHandlePanEnded(
            panMode: .horizontalAndVertical,
            endedTouchLocation: .random(),
            clampingFunction: { $0 })
    }

    func testHandlePanEndedWithHorizontalPanMode() throws {
        let endedTouchLocation = CGPoint.random()

        try verifyHandlePanEnded(
            panMode: .horizontal,
            endedTouchLocation: endedTouchLocation,
            clampingFunction: {
                CGPoint(
                    x: $0.x,
                    y: endedTouchLocation.y)
            })
    }

    func testHandlePanEndedWithVerticalPanMode() throws {
        let endedTouchLocation = CGPoint.random()

        try verifyHandlePanEnded(
            panMode: .vertical,
            endedTouchLocation: endedTouchLocation,
            clampingFunction: {
                CGPoint(
                    x: endedTouchLocation.x,
                    y: $0.y)
            })
    }

    func testHandlePanCancelled() {
        gestureRecognizer.getStateStub.defaultReturnValue = .cancelled

        gestureRecognizer.sendActions()

        XCTAssertEqual(cameraAnimationsManager.decelerateStub.invocations.count, 0, "Cancelled pan should not trigger deceleration")
        XCTAssertEqual(mapboxMap.dragEndStub.invocations.count, 1)
        XCTAssertEqual(delegate.gestureEndedStub.parameters, [.init(gestureType: .pan, willAnimate: false)])
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

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 1)
    }
}
