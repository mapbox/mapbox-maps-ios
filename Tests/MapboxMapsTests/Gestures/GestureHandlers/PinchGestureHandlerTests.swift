import XCTest
@testable import MapboxMaps

final class PinchGestureHandlerTests: XCTestCase {
    var view: UIView!
    var gestureRecognizer: MockPinchGestureRecognizer!
    var mapboxMap: MockMapboxMap!
    var pinchGestureHandler: PinchGestureHandler!
    // swiftlint:disable:next weak_delegate
    var delegate: MockGestureHandlerDelegate!

    override func setUp() {
        super.setUp()
        view = UIView()
        gestureRecognizer = MockPinchGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        mapboxMap = MockMapboxMap()
        pinchGestureHandler = PinchGestureHandler(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap)
        delegate = MockGestureHandlerDelegate()
        pinchGestureHandler.delegate = delegate
    }

    override func tearDown() {
        pinchGestureHandler = nil
        delegate = nil
        mapboxMap = nil
        gestureRecognizer = nil
        view = nil
        super.tearDown()
    }

    func testInitialization() {
        XCTAssertTrue(gestureRecognizer === pinchGestureHandler.gestureRecognizer)
    }

    func testPinchBegan() {
        gestureRecognizer.getStateStub.defaultReturnValue = .began

        gestureRecognizer.sendActions()

        XCTAssertEqual(delegate.gestureBeganStub.parameters, [.pinch])
    }

    func testPinchChanged() throws {
        pinchGestureHandler.rotateEnabled = true

        let initialCameraState = CameraState.random()
        let initialPinchMidpoint = CGPoint(x: 0.0, y: 0.0)
        let changedPinchMidpoint = CGPoint(x: 1.0, y: 1.0)
        mapboxMap.cameraState = initialCameraState
        mapboxMap.dragCameraOptionsStub.defaultReturnValue = CameraOptions(
            center: .random(),
            zoom: .random(in: 0...20))

        // set up internal state by calling handlePinch in the .began state
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        gestureRecognizer.locationStub.defaultReturnValue = initialPinchMidpoint
        // these touches are consistent with the initial pinch midpoint
        // and yield an angle of 45° for the initial state
        gestureRecognizer.locationOfTouchStub.returnValueQueue = [
            CGPoint(x: -1, y: -1),
            CGPoint(x: 1, y: 1)]
        gestureRecognizer.getNumberOfTouchesStub.defaultReturnValue = 2
        gestureRecognizer.sendActions()
        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.locationStub.defaultReturnValue = changedPinchMidpoint
        // the new touch angle is 90° - that's 45° increase from the initial.
        // this should come through as -45° change in bearing since the
        // coordinate systems are flipped.
        gestureRecognizer.locationOfTouchStub.returnValueQueue = [
            CGPoint(x: 1, y: 0),
            CGPoint(x: 1, y: 2)]
        gestureRecognizer.getScaleStub.defaultReturnValue = 2.0

        gestureRecognizer.sendActions()

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 3)
        guard mapboxMap.setCameraStub.invocations.count == 3 else {
            return
        }
        XCTAssertEqual(mapboxMap.dragStartStub.invocations.count, 1)
        XCTAssertEqual(mapboxMap.dragCameraOptionsStub.invocations.count, 1)
        XCTAssertEqual(mapboxMap.dragEndStub.invocations.count, 1)

        XCTAssertEqual(
            mapboxMap.setCameraStub.parameters[0],
            CameraOptions(
                center: initialCameraState.center,
                zoom: initialCameraState.zoom,
                bearing: initialCameraState.bearing))

        XCTAssertEqual(
            mapboxMap.dragStartStub.parameters.first,
            initialPinchMidpoint)

        XCTAssertEqual(
            mapboxMap.dragCameraOptionsStub.parameters.first,
            .init(from: initialPinchMidpoint, to: changedPinchMidpoint))

        XCTAssertEqual(
            mapboxMap.setCameraStub.parameters[1],
            mapboxMap.dragCameraOptionsStub.returnedValues.first)

        let returnedScale = try XCTUnwrap(gestureRecognizer.getScaleStub.returnedValues.last)
        XCTAssertEqual(
            mapboxMap.setCameraStub.parameters[2],
            CameraOptions(
                anchor: changedPinchMidpoint,
                zoom: initialCameraState.zoom + log2(returnedScale),
                bearing: initialCameraState.bearing - 45))
    }

    func testPinchChangedWithRotateEnabledFalse() {
        pinchGestureHandler.rotateEnabled = false

        mapboxMap.cameraState = .random()

        // these touches are consistent with the initial pinch midpoint
        // and yield an angle of 45° for the initial state
        gestureRecognizer.getNumberOfTouchesStub.defaultReturnValue = 2
        gestureRecognizer.locationOfTouchStub.returnValueQueue = [
            CGPoint(x: -1, y: -1),
            CGPoint(x: 1, y: 1)]
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        gestureRecognizer.sendActions()

        // the new touch angle is 90° - that's 45° increase from the initial.
        // this should come through as -45° change in bearing since the
        // coordinate systems are flipped.
        gestureRecognizer.locationOfTouchStub.returnValueQueue = [
            CGPoint(x: 1, y: 0),
            CGPoint(x: 1, y: 2)]
        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.sendActions()

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 3)
        guard mapboxMap.setCameraStub.invocations.count == 3 else {
            return
        }
        XCTAssertNil(mapboxMap.setCameraStub.parameters[0].bearing)
        XCTAssertNil(mapboxMap.setCameraStub.parameters[2].bearing)
    }

    func testSettingRotateEnabledToTrueDuringGestureHasNoImpactOnCurrentGesture() {
        pinchGestureHandler.rotateEnabled = false

        mapboxMap.cameraState = .random()

        // set up internal state by calling handlePinch in the .began state
        gestureRecognizer.getNumberOfTouchesStub.defaultReturnValue = 2
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        gestureRecognizer.sendActions()

        // set rotateEnabled to true after the gesture has started.
        // the gesture should continue based on rotateEnabled = false
        // since that was the value when the gesture started
        pinchGestureHandler.rotateEnabled = true
        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.sendActions()

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 3)
        guard mapboxMap.setCameraStub.invocations.count == 3 else {
            return
        }
        XCTAssertNil(mapboxMap.setCameraStub.parameters[0].bearing)
        XCTAssertNil(mapboxMap.setCameraStub.parameters[2].bearing)
    }

    func testSettingRotateEnabledToFalseDuringGestureHasNoImpactOnCurrentGesture() throws {
        pinchGestureHandler.rotateEnabled = true

        let initialCameraState = CameraState.random()
        mapboxMap.cameraState = initialCameraState

        // these touches are consistent with the initial pinch midpoint
        // and yield an angle of 45° for the initial state
        gestureRecognizer.getNumberOfTouchesStub.defaultReturnValue = 2
        gestureRecognizer.locationOfTouchStub.returnValueQueue = [
            CGPoint(x: -1, y: -1),
            CGPoint(x: 1, y: 1)]
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        gestureRecognizer.sendActions()

        // set rotateEnabled to false after the gesture has started.
        // the gesture should continue based on rotateEnabled = true
        // since that was the value when the gesture started
        pinchGestureHandler.rotateEnabled = false
        // the new touch angle is 90° - that's 45° increase from the initial.
        // this should come through as -45° change in bearing since the
        // coordinate systems are flipped.
        gestureRecognizer.locationOfTouchStub.returnValueQueue = [
            CGPoint(x: 1, y: 0),
            CGPoint(x: 1, y: 2)]
        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.sendActions()

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 3)
        guard mapboxMap.setCameraStub.invocations.count == 3 else {
            return
        }
        XCTAssertEqual(mapboxMap.setCameraStub.parameters[0].bearing, initialCameraState.bearing)
        XCTAssertEqual(mapboxMap.setCameraStub.parameters[2].bearing, initialCameraState.bearing - 45)
    }

    func testPinchChangedWhenNumberOfTouchesDecreasesToOneThenGoesBackToTwo() {
        gestureRecognizer.getStateStub.returnValueQueue = [
            .began, .changed, .changed, .changed, .changed]
        gestureRecognizer.getNumberOfTouchesStub.returnValueQueue = [
            2, 2, 1, 2, 2]
        let initialCameraState = CameraState.random()
        mapboxMap.cameraState = initialCameraState
        gestureRecognizer.sendActions() // began (2 touches)
        gestureRecognizer.sendActions() // changed (2 touches)
        gestureRecognizer.sendActions() // changed (1 touch)
        let resumedCameraState = CameraState.random()
        mapboxMap.cameraState = resumedCameraState
        gestureRecognizer.sendActions() // changed (2 touches)
        mapboxMap.setCameraStub.reset()

        gestureRecognizer.sendActions() // changed (2 touches)

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 3)
        XCTAssertEqual(
            mapboxMap.setCameraStub.parameters.first,
            CameraOptions(
                center: resumedCameraState.center,
                zoom: initialCameraState.zoom,
                bearing: resumedCameraState.bearing))
    }

    func testPinchEnded() throws {
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        gestureRecognizer.sendActions()
        gestureRecognizer.getStateStub.defaultReturnValue = .ended

        gestureRecognizer.sendActions()

        XCTAssertEqual(delegate.gestureEndedStub.invocations.count, 1)
        XCTAssertEqual(delegate.gestureEndedStub.parameters.first?.gestureType, .pinch)
        XCTAssertEqual(delegate.gestureEndedStub.parameters.first?.willAnimate, false)
    }

    // This doesn't seem like a scenario that would actually happen; however, we received
    // crash reports that suggest that it does in some situations, so we added some
    // defensive mechanisms to make sure it does not result in a crash. We confirmed that
    // these changes cleared up the crashes for the developers who were seeing them.
    func testGestureBeganWithOnlyOneTouch() {
        gestureRecognizer.getNumberOfTouchesStub.defaultReturnValue = 1
        gestureRecognizer.getStateStub.defaultReturnValue = .began

        gestureRecognizer.sendActions()

        XCTAssertTrue(gestureRecognizer.locationOfTouchStub.invocations.isEmpty)
        XCTAssertTrue(mapboxMap.dragStartStub.invocations.isEmpty)
        XCTAssertTrue(delegate.gestureBeganStub.invocations.isEmpty)

        // if the gesture didn't have 2 touches when it began, we don't support
        // resuming the gesture. we could conceivably change this if we confirm
        // that pinch gestures are indeed beginning with only 1 touch.
        gestureRecognizer.getNumberOfTouchesStub.defaultReturnValue = 2
        gestureRecognizer.getStateStub.defaultReturnValue = .changed

        gestureRecognizer.sendActions()

        XCTAssertTrue(gestureRecognizer.locationOfTouchStub.invocations.isEmpty)
        XCTAssertTrue(mapboxMap.dragStartStub.invocations.isEmpty)
        XCTAssertTrue(delegate.gestureBeganStub.invocations.isEmpty)
        XCTAssertTrue(mapboxMap.setCameraStub.invocations.isEmpty)
        XCTAssertTrue(mapboxMap.dragCameraOptionsStub.invocations.isEmpty)

        // when such a gesture ends, we should just ignore it
        gestureRecognizer.getStateStub.defaultReturnValue = .ended

        gestureRecognizer.sendActions()

        XCTAssertTrue(mapboxMap.dragEndStub.invocations.isEmpty)
        XCTAssertTrue(delegate.gestureEndedStub.invocations.isEmpty)
    }
}
