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
    let interruptingRecognizers = UIGestureRecognizer.interruptingRecognizers([.longPress, .swipe, .screenEdge, .tap])

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
        interruptingRecognizers.forEach { $0.view?.removeGestureRecognizer($0) }
        super.tearDown()
    }

    func testInitialization() {
        XCTAssertEqual(panGestureHandler.multiFingerPanEnabled, true)
        XCTAssertTrue(gestureRecognizer.maximumNumberOfTouches > 10)
        XCTAssertEqual(gestureRecognizer.minimumNumberOfTouches, 1)
        XCTAssertTrue(gestureRecognizer === panGestureHandler.gestureRecognizer)
    }

    func testHandlePanBegan() {
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        let touchLocation = CGPoint.random()
        gestureRecognizer.locationStub.defaultReturnValue = touchLocation
        mapboxMap.pointIsAboveHorizonStub.defaultReturnValue = false

        gestureRecognizer.sendActions()

        XCTAssertEqual(delegate.gestureBeganStub.invocations.map(\.parameters), [.pan])
    }

    func verifyHandlePanChanged(panMode: PanMode,
                                initialTouchLocation: CGPoint,
                                clampingFunction: (CGPoint) -> CGPoint,
                                line: UInt = #line) throws {
        let initialCameraState = CameraState.random()
        mapboxMap.cameraState = initialCameraState
        mapboxMap.dragCameraOptionsStub.defaultReturnValue = .random()
        mapboxMap.pointIsAboveHorizonStub.defaultReturnValue = false
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

            XCTAssertEqual(mapboxMap.dragCameraOptionsStub.invocations.map(\.parameters), [
                .init(from: clampingFunction(touchLocations[idx - 1]), to: clampingFunction(touchLocations[idx]))], line: line)
            let dragCameraOptions = try XCTUnwrap(mapboxMap.dragCameraOptionsStub.invocations.first?.returnValue, line: line)
            XCTAssertEqual(mapboxMap.setCameraStub.invocations.map(\.parameters), [dragCameraOptions], line: line)
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
        mapboxMap.pointIsAboveHorizonStub.defaultReturnValue = false
        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.sendActions()
        dateProvider.nowStub.defaultReturnValue += 2.0 / 60.0 + .leastNonzeroMagnitude

        gestureRecognizer.getStateStub.defaultReturnValue = .ended
        gestureRecognizer.sendActions()

        XCTAssertEqual(cameraAnimationsManager.decelerateStub.invocations.count, 0)
    }

    func verifyHandlePanEnded(panMode: PanMode,
                              velocityClampingFunction: (CGPoint) -> (CGPoint)) throws {
        mapboxMap.pointIsAboveHorizonStub.defaultReturnValue = false
        panGestureHandler.panMode = panMode
        panGestureHandler.decelerationFactor = .random(in: 0.1...0.99)
        var initialCameraState = CameraState.random()
        initialCameraState.pitch = initialCameraState.pitch.clamped(to: 0...60)
        mapboxMap.cameraState = initialCameraState
        mapboxMap.size.height = .random(in: 100..<1000)
        let endedTouchLocation = CGPoint.random()
        let touchLocations = [.random(), endedTouchLocation, endedTouchLocation]
        gestureRecognizer.locationStub.returnValueQueue = touchLocations
        let velocity = CGPoint.random()
        gestureRecognizer.velocityStub.defaultReturnValue = velocity
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        gestureRecognizer.sendActions()
        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.sendActions()
        mapboxMap.dragCameraOptionsStub.reset()
        mapboxMap.setCameraStub.reset()
        mapboxMap.dragCameraOptionsStub.defaultReturnValue = .random()

        gestureRecognizer.getStateStub.defaultReturnValue = .ended
        gestureRecognizer.sendActions()

        XCTAssertEqual(delegate.gestureEndedStub.invocations.map(\.parameters), [.init(gestureType: .pan, willAnimate: true)])

        XCTAssertEqual(cameraAnimationsManager.decelerateStub.invocations.count, 1)
        let decelerateParams = cameraAnimationsManager.decelerateStub.invocations.first?.parameters
        let expectedDecelerateLocation = CGPoint(
            x: endedTouchLocation.x,
            y: max(endedTouchLocation.y, 3 / 4 * mapboxMap.size.height))
        XCTAssertEqual(decelerateParams?.location, expectedDecelerateLocation)
        XCTAssertEqual(decelerateParams?.velocity, velocityClampingFunction(velocity))
        XCTAssertEqual(decelerateParams?.decelerationFactor, panGestureHandler.decelerationFactor)

        let interpolatedLocations: [CGPoint] = [.random(), .random()]
        let previousLocations = [endedTouchLocation, interpolatedLocations[0]]
        for i in 0..<interpolatedLocations.count {
            mapboxMap.dragCameraOptionsStub.reset()
            mapboxMap.setCameraStub.reset()

            let locationChangeHandler = try XCTUnwrap(decelerateParams?.locationChangeHandler)
            locationChangeHandler(previousLocations[i], interpolatedLocations[i])
            XCTAssertEqual(
                mapboxMap.dragCameraOptionsStub.invocations.map(\.parameters),
                [.init(
                    from: previousLocations[i],
                    to: interpolatedLocations[i])])
            let dragCameraOptions = try XCTUnwrap(mapboxMap.dragCameraOptionsStub.invocations.first?.returnValue)
            XCTAssertEqual(mapboxMap.setCameraStub.invocations.map(\.parameters), [dragCameraOptions])
        }

        let animationEndedCompletion = try XCTUnwrap(decelerateParams?.completion)
        animationEndedCompletion(.end)

        XCTAssertEqual(delegate.animationEndedStub.invocations.map(\.parameters), [.pan])
    }

    func testHandlePanEnded() throws {
        try verifyHandlePanEnded(
            panMode: .horizontalAndVertical,
            velocityClampingFunction: { $0 })
    }

    func testHandlePanEndedWithHorizontalPanMode() throws {
        try verifyHandlePanEnded(
            panMode: .horizontal,
            velocityClampingFunction: {
                CGPoint(
                    x: $0.x,
                    y: 0)
            })
    }

    func testHandlePanEndedWithVerticalPanMode() throws {
        try verifyHandlePanEnded(
            panMode: .vertical,
            velocityClampingFunction: {
                CGPoint(
                    x: 0,
                    y: $0.y)
            })
    }

    func testHandlePanCancelled() {
        mapboxMap.pointIsAboveHorizonStub.defaultReturnValue = false
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        gestureRecognizer.sendActions()
        gestureRecognizer.getStateStub.defaultReturnValue = .cancelled

        gestureRecognizer.sendActions()

        XCTAssertEqual(cameraAnimationsManager.decelerateStub.invocations.count, 0, "Cancelled pan should not trigger deceleration")
        XCTAssertEqual(delegate.gestureEndedStub.invocations.map(\.parameters), [.init(gestureType: .pan, willAnimate: false)])
    }

    func testSecondPanGesturePerformsCorrectlyWhenInterruptingDecelerationFromFirstPanGesture() throws {
        mapboxMap.pointIsAboveHorizonStub.defaultReturnValue = false
        gestureRecognizer.getStateStub.returnValueQueue = [.began, .changed, .ended, .began, .changed]
        gestureRecognizer.sendActions() // began 1
        gestureRecognizer.sendActions() // changed 1
        gestureRecognizer.sendActions() // ended 1

        // began 2
        gestureRecognizer.sendActions()
        mapboxMap.setCameraStub.reset()

        // cancel deceleration *after* the second gesture begins
        let decelerateAnimationCompletion = try XCTUnwrap(cameraAnimationsManager.decelerateStub.invocations.first?.parameters.completion)
        decelerateAnimationCompletion(.current)

        // changed 2 should still result in camera updates. a previous
        // implementation had a bug here where the cancellation of the animation
        // cleared the initial state for the subsequent gesture
        gestureRecognizer.sendActions()

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 1)
    }

    func testGestureDoesNotStartUntilTouchLocationIsBelowHorizon() {
        mapboxMap.pointIsAboveHorizonStub.defaultReturnValue = true
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        gestureRecognizer.sendActions()

        XCTAssertTrue(delegate.gestureBeganStub.invocations.isEmpty)

        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.sendActions()

        XCTAssertTrue(delegate.gestureBeganStub.invocations.isEmpty)
        XCTAssertTrue(mapboxMap.dragCameraOptionsStub.invocations.isEmpty)
        XCTAssertTrue(mapboxMap.setCameraStub.invocations.isEmpty)

        mapboxMap.pointIsAboveHorizonStub.defaultReturnValue = false
        gestureRecognizer.sendActions()

        XCTAssertEqual(delegate.gestureBeganStub.invocations.map(\.parameters), [.pan])
        XCTAssertTrue(mapboxMap.dragCameraOptionsStub.invocations.isEmpty)
        XCTAssertTrue(mapboxMap.setCameraStub.invocations.isEmpty)

        gestureRecognizer.sendActions()

        XCTAssertEqual(mapboxMap.dragCameraOptionsStub.invocations.count, 1)
        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 1)

        // once gesture starts, locations above the horizon continue to be handled
        mapboxMap.pointIsAboveHorizonStub.defaultReturnValue = true
        gestureRecognizer.sendActions()

        XCTAssertEqual(mapboxMap.dragCameraOptionsStub.invocations.count, 2)
        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 2)

        // but deceleration is skipped if the final location is above the horizon
        gestureRecognizer.getStateStub.defaultReturnValue = .ended
        gestureRecognizer.sendActions()

        XCTAssertTrue(cameraAnimationsManager.decelerateStub.invocations.isEmpty)
        XCTAssertEqual(delegate.gestureEndedStub.invocations.map(\.parameters), [.init(gestureType: .pan, willAnimate: false)])
    }

    func testOneToTwoNumberOfTouchesTransitionIsSmooth() throws {
        // given
        let panStartPoint = CGPoint(x: 0, y: 0)
        let panPoint1 = CGPoint(x: 100, y: 100)
        let panPoint2 = CGPoint(x: 101, y: 101)

        panGestureHandler.panMode = .horizontalAndVertical
        mapboxMap.pointIsAboveHorizonStub.defaultReturnValue = false
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        gestureRecognizer.sendActions()

        gestureRecognizer.getNumberOfTouchesStub.defaultReturnValue = 1
        gestureRecognizer.locationOfTouchStub.defaultReturnValue = panStartPoint
        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.sendActions()

        mapboxMap.dragCameraOptionsStub.reset()

        // when
        // number of touches changes from 1 to 2 - this change should be ignored
        gestureRecognizer.getNumberOfTouchesStub.defaultReturnValue = 2
        gestureRecognizer.locationOfTouchStub.defaultReturnValue = panPoint1
        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.sendActions()

        // then
        XCTAssertEqual(mapboxMap.dragCameraOptionsStub.invocations.count, 0)

        // when
        // two-finger gesture emits another event - camera drags from the previous two-figer touch point to the current one
        gestureRecognizer.getNumberOfTouchesStub.defaultReturnValue = 2
        gestureRecognizer.locationOfTouchStub.defaultReturnValue = panPoint2
        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.sendActions()

        // then
        XCTAssertEqual(mapboxMap.dragCameraOptionsStub.invocations.count, 1)
        let params = try XCTUnwrap(mapboxMap.dragCameraOptionsStub.invocations.first?.parameters)
        XCTAssertEqual(params.from, panPoint1)
        XCTAssertEqual(params.to, panPoint2)
    }

    func testTwoToOneNumberOfTouchesTransitionIsSmooth() throws {
        // given
        let panStartPoint = CGPoint(x: 0, y: 0)
        let panPoint1 = CGPoint(x: 100, y: 100)
        let panPoint2 = CGPoint(x: 101, y: 101)

        panGestureHandler.panMode = .horizontalAndVertical
        mapboxMap.pointIsAboveHorizonStub.defaultReturnValue = false
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        gestureRecognizer.sendActions()

        gestureRecognizer.getNumberOfTouchesStub.defaultReturnValue = 2
        gestureRecognizer.locationOfTouchStub.defaultReturnValue = panStartPoint
        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.sendActions()

        mapboxMap.dragCameraOptionsStub.reset()

        // when
        // number of touches changes from 2 to 1 - this change should be ignored
        gestureRecognizer.getNumberOfTouchesStub.defaultReturnValue = 1
        gestureRecognizer.locationOfTouchStub.defaultReturnValue = panPoint1
        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.sendActions()

        // then
        XCTAssertEqual(mapboxMap.dragCameraOptionsStub.invocations.count, 0)

        // when
        // one-finger gesture emits another event - camera drags from the previous one-figer touch point to the current one
        gestureRecognizer.getNumberOfTouchesStub.defaultReturnValue = 1
        gestureRecognizer.locationOfTouchStub.defaultReturnValue = panPoint2
        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.sendActions()

        // then
        XCTAssertEqual(mapboxMap.dragCameraOptionsStub.invocations.count, 1)
        let params = try XCTUnwrap(mapboxMap.dragCameraOptionsStub.invocations.first?.parameters)
        XCTAssertEqual(params.from, panPoint1)
        XCTAssertEqual(params.to, panPoint2)
    }

    func testMultiTouchPanUsesCentroidOfTouches() throws {
        // given
        let numberOfTouches = Int.random(in: 2...1000)
        let initialTouches: [CGPoint] = (0..<numberOfTouches).map { _ in .random() }
        func centroid(_ touches: [CGPoint]) -> CGPoint {
            let touchSum = touches.reduce(into: CGPoint.zero) { partialResult, touchLocation in
                partialResult.x += touchLocation.x
                partialResult.y += touchLocation.y
            }
            return CGPoint(x: touchSum.x / CGFloat(numberOfTouches), y: touchSum.y / CGFloat(numberOfTouches))
        }
        let initialCentroid = centroid(initialTouches)
        let changedTouches: [CGPoint] = (0..<numberOfTouches).map { _ in .random() }
        let changedCentroid = centroid(changedTouches)

        panGestureHandler.panMode = .horizontalAndVertical
        mapboxMap.pointIsAboveHorizonStub.defaultReturnValue = false
        gestureRecognizer.getNumberOfTouchesStub.defaultReturnValue = numberOfTouches

        // when
        // drag begins with initial set of touches
        gestureRecognizer.locationOfTouchStub.returnValueQueue = initialTouches
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        gestureRecognizer.sendActions()

        // when
        // drag changes with a new set of touches
        gestureRecognizer.locationOfTouchStub.returnValueQueue = changedTouches
        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.sendActions()

        // then
        XCTAssertEqual(mapboxMap.dragCameraOptionsStub.invocations.count, 1)
        let dragCameraOptions = try XCTUnwrap(mapboxMap.dragCameraOptionsStub.invocations.first?.parameters)
        XCTAssertEqual(dragCameraOptions.from, initialCentroid)
        XCTAssertEqual(dragCameraOptions.to, changedCentroid)
    }

    func testGestureWithDelayedStartCanStillDecelerate() {
        mapboxMap.pointIsAboveHorizonStub.defaultReturnValue = true
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        gestureRecognizer.sendActions()

        mapboxMap.pointIsAboveHorizonStub.defaultReturnValue = false
        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.sendActions() // this is treated like .began
        gestureRecognizer.sendActions() // so send another changed event to populate required internal state for deceleration

        gestureRecognizer.getStateStub.defaultReturnValue = .ended
        gestureRecognizer.sendActions()

        XCTAssertEqual(cameraAnimationsManager.decelerateStub.invocations.count, 1)
        XCTAssertEqual(delegate.gestureEndedStub.invocations.map(\.parameters), [.init(gestureType: .pan, willAnimate: true)])
    }

    func testGestureEndedWithoutEverBeginning() {
        mapboxMap.pointIsAboveHorizonStub.defaultReturnValue = true
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        gestureRecognizer.sendActions()

        gestureRecognizer.getStateStub.defaultReturnValue = .ended
        gestureRecognizer.sendActions()

        XCTAssertTrue(cameraAnimationsManager.decelerateStub.invocations.isEmpty)
    }

    func testGestureCancelledWithoutEverBeginning() {
        mapboxMap.pointIsAboveHorizonStub.defaultReturnValue = true
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        gestureRecognizer.sendActions()

        gestureRecognizer.getStateStub.defaultReturnValue = .cancelled
        gestureRecognizer.sendActions()

        XCTAssertTrue(cameraAnimationsManager.decelerateStub.invocations.isEmpty)
    }

    func testDisableTwoFingerPan() {
        // when
        panGestureHandler.multiFingerPanEnabled = false

        // then
        XCTAssertEqual(gestureRecognizer.maximumNumberOfTouches, 1)
        XCTAssertEqual(gestureRecognizer.minimumNumberOfTouches, 1)
    }

    func testEnableTwoFingerPan() {
        // given
        panGestureHandler.multiFingerPanEnabled = false
        // when
        panGestureHandler.multiFingerPanEnabled = true

        // then
        XCTAssertTrue(gestureRecognizer.maximumNumberOfTouches > 10)
        XCTAssertEqual(gestureRecognizer.minimumNumberOfTouches, 1)
    }

    func testPanRecognizesSimultaneouslyWithRotationAndPinch() {
        let recognizers = Set([UIRotationGestureRecognizer(), UIPinchGestureRecognizer()])
        recognizers.forEach(view.addGestureRecognizer)

        panGestureHandler.assertRecognizedSimultaneously(gestureRecognizer, with: recognizers)
    }

    func testPinchShouldNotRecognizeSimultaneouslyWithNonRotationAndPinch() {
        interruptingRecognizers.forEach(view.addGestureRecognizer)

        panGestureHandler.assertNotRecognizedSimultaneously(gestureRecognizer, with: interruptingRecognizers)
    }
}
