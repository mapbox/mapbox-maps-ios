import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class PinchGestureHandlerImpl2Tests: XCTestCase {
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
        pinchGestureHandler.behavior = .doesNotResetCameraAtEachFrame
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

        XCTAssertEqual(mapboxMap.dragStartStub.invocations.count, 1)
        XCTAssertEqual(delegate.gestureBeganStub.parameters, [.pinch])
    }

    func testPinchChanged() throws {
        pinchGestureHandler.rotateEnabled = true

        // Set up and send the gesture began event
        let initialCameraState = CameraState.random()
        let pinchMidpoints = [
            CGPoint(x: 0.0, y: 0.0),
            CGPoint(x: 1.0, y: 1.0),
            CGPoint(x: 10.0, y: 10.0)]
        mapboxMap.cameraState = initialCameraState
        mapboxMap.dragCameraOptionsStub.defaultReturnValue = CameraOptions(
            center: .random(),
            zoom: .random(in: 0...20))

        // set up internal state by calling handlePinch in the .began state
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        gestureRecognizer.locationStub.defaultReturnValue = pinchMidpoints[0]
        // these touches are consistent with the initial pinch midpoint
        // and yield an angle of 45° for the initial state
        gestureRecognizer.locationOfTouchStub.returnValueQueue = [
            CGPoint(x: -1, y: -1),
            CGPoint(x: 1, y: 1)]
        gestureRecognizer.getNumberOfTouchesStub.defaultReturnValue = 2
        gestureRecognizer.sendActions()

        // Set up and send the gesture changed event
        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.locationStub.defaultReturnValue = pinchMidpoints[1]
        // the new touch angle is 90° - that's 45° increase from the initial.
        // this should come through as -45° change in bearing since the
        // coordinate systems are flipped.
        gestureRecognizer.locationOfTouchStub.returnValueQueue = [
            CGPoint(x: 1, y: 0),
            CGPoint(x: 1, y: 2)]
        gestureRecognizer.getScaleStub.defaultReturnValue = 2.0
        gestureRecognizer.sendActions()

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 2)
        guard mapboxMap.setCameraStub.invocations.count == 2 else {
            return
        }
        XCTAssertEqual(mapboxMap.dragCameraOptionsStub.invocations.count, 1)
        XCTAssertEqual(
            mapboxMap.dragCameraOptionsStub.parameters.first,
            .init(from: pinchMidpoints[0], to: pinchMidpoints[1]))
        XCTAssertEqual(
            mapboxMap.setCameraStub.parameters[0],
            mapboxMap.dragCameraOptionsStub.returnedValues.first)
        let returnedScale = try XCTUnwrap(gestureRecognizer.getScaleStub.returnedValues.last)
        XCTAssertEqual(
            mapboxMap.setCameraStub.parameters[1],
            CameraOptions(
                anchor: pinchMidpoints[1],
                zoom: initialCameraState.zoom + log2(returnedScale),
                bearing: initialCameraState.bearing - 45))

        // Set up and send a second gesture changed event to make sure we use drag API incrementally
        gestureRecognizer.locationStub.defaultReturnValue = pinchMidpoints[2]
        mapboxMap.dragCameraOptionsStub.reset()
        gestureRecognizer.sendActions()

        XCTAssertEqual(mapboxMap.dragCameraOptionsStub.invocations.count, 1)
        XCTAssertEqual(
            mapboxMap.dragCameraOptionsStub.parameters.first,
            .init(from: pinchMidpoints[1], to: pinchMidpoints[2]))
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

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 2)
        guard mapboxMap.setCameraStub.invocations.count == 2 else {
            return
        }
        XCTAssertNil(mapboxMap.setCameraStub.parameters[1].bearing)
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

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 2)
        guard mapboxMap.setCameraStub.invocations.count == 2 else {
            return
        }
        XCTAssertNil(mapboxMap.setCameraStub.parameters[1].bearing)
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

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 2)
        guard mapboxMap.setCameraStub.invocations.count == 2 else {
            return
        }
        XCTAssertEqual(mapboxMap.setCameraStub.parameters[1].bearing, initialCameraState.bearing - 45)
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

        // Gesture pauses when number of touches decreases to 1
        mapboxMap.dragEndStub.reset()

        gestureRecognizer.sendActions() // changed (1 touch)

        XCTAssertEqual(mapboxMap.dragEndStub.invocations.count, 1)

        // Gesture re-captures initial state when number of touches increases back to 2
        let resumedCameraState = CameraState.random()
        mapboxMap.cameraState = resumedCameraState
        // 45 degree touch angle
        gestureRecognizer.locationOfTouchStub.returnValueQueue = [
            CGPoint(x: -1, y: -1),
            CGPoint(x: 1, y: 1)]
        let resumedPinchMidpoint = CGPoint.random()
        gestureRecognizer.locationStub.defaultReturnValue = resumedPinchMidpoint
        mapboxMap.dragStartStub.reset()

        gestureRecognizer.sendActions() // changed (2 touches)

        XCTAssertEqual(mapboxMap.dragStartStub.parameters, [resumedPinchMidpoint])

        // On second changed event after resume, we can start updating the camera again
        // 90 degree touch angle
        gestureRecognizer.locationOfTouchStub.returnValueQueue = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 0, y: 1)]
        let updatedPinchMidpoint = CGPoint.random()
        gestureRecognizer.locationStub.defaultReturnValue = updatedPinchMidpoint
        gestureRecognizer.getScaleStub.defaultReturnValue = 8
        mapboxMap.setCameraStub.reset()
        mapboxMap.dragCameraOptionsStub.reset()

        gestureRecognizer.sendActions() // changed (2 touches)

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 2)
        XCTAssertEqual(mapboxMap.dragCameraOptionsStub.parameters,
                       [.init(from: resumedPinchMidpoint, to: updatedPinchMidpoint)])
        XCTAssertEqual(
            mapboxMap.setCameraStub.parameters.last,
            CameraOptions(
                anchor: updatedPinchMidpoint,
                zoom: initialCameraState.zoom + 3,
                bearing: resumedCameraState.bearing - 45))
    }

    func testPinchEnded() throws {
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        gestureRecognizer.sendActions()
        gestureRecognizer.getStateStub.defaultReturnValue = .ended
        mapboxMap.dragEndStub.reset()

        gestureRecognizer.sendActions()

        XCTAssertEqual(mapboxMap.dragEndStub.invocations.count, 1)
        XCTAssertEqual(delegate.gestureEndedStub.invocations.count, 1)
        XCTAssertEqual(delegate.gestureEndedStub.parameters.first?.gestureType, .pinch)
        XCTAssertEqual(delegate.gestureEndedStub.parameters.first?.willAnimate, false)
    }

    // This should not be a scenario that actually happens; however, we've received
    // some crash reports that suggest that this might actually be happening in some
    // situations, so we're adding some defensive mechanisms to make sure it does
    // not result in a crash
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
