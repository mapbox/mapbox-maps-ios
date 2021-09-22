import XCTest
@testable import MapboxMaps

final class PinchGestureHandlerTests: XCTestCase {
    var view: UIView!
    var gestureRecognizer: MockPinchGestureRecognizer!
    var mapboxMap: MockMapboxMap!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var pinchGestureHandler: PinchGestureHandler!
    // swiftlint:disable:next weak_delegate
    var delegate: MockGestureHandlerDelegate!

    override func setUp() {
        super.setUp()
        view = UIView()
        gestureRecognizer = MockPinchGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        mapboxMap = MockMapboxMap()
        cameraAnimationsManager = MockCameraAnimationsManager()
        pinchGestureHandler = PinchGestureHandler(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        delegate = MockGestureHandlerDelegate()
        pinchGestureHandler.delegate = delegate
    }

    override func tearDown() {
        pinchGestureHandler = nil
        delegate = nil
        cameraAnimationsManager = nil
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

        XCTAssertEqual(cameraAnimationsManager.cancelAnimationsStub.invocations.count, 1)
        XCTAssertEqual(delegate.gestureBeganStub.parameters, [.pinch])
    }

    func testPinchChanged() throws {
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
        // reset cancelAnimationsStub so we can verify
        // that it's called when state is .changed
        cameraAnimationsManager.cancelAnimationsStub.reset()
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

        XCTAssertEqual(cameraAnimationsManager.cancelAnimationsStub.invocations.count, 1,
                      "Cancel animations was not called before commencing gesture processing")
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

    func testPinchChangedWhenNumberOfTouchesDecreasesToOneThenGoesBackToTwo() {
        gestureRecognizer.getStateStub.returnValueQueue = [
            .began, .changed, .changed, .changed, .changed]
        gestureRecognizer.getNumberOfTouchesStub.returnValueQueue = [
            2, 1, 2, 2] // this is only called on .changed
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
}
