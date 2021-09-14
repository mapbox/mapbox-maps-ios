import XCTest
@testable import MapboxMaps

final class PinchGestureHandlerTests: XCTestCase {

    var view: UIView!
    var mapboxMap: MockMapboxMap!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var pinchGestureHandler: PinchGestureHandler!
    // swiftlint:disable:next weak_delegate
    var delegate: MockGestureHandlerDelegate!
    var gestureRecognizer: MockPinchGestureRecognizer!

    override func setUp() {
        super.setUp()
        view = UIView()
        mapboxMap = MockMapboxMap()
        cameraAnimationsManager = MockCameraAnimationsManager()
        pinchGestureHandler = PinchGestureHandler(
            view: view,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        delegate = MockGestureHandlerDelegate()
        pinchGestureHandler.delegate = delegate
        gestureRecognizer = MockPinchGestureRecognizer()
        gestureRecognizer.getViewStub.defaultReturnValue = view
    }

    override func tearDown() {
        gestureRecognizer = nil
        pinchGestureHandler = nil
        delegate = nil
        cameraAnimationsManager = nil
        mapboxMap = nil
        view = nil
        super.tearDown()
    }

    func testInitialization() {
        XCTAssertTrue(view.gestureRecognizers?.last === pinchGestureHandler.gestureRecognizer)
    }

    func testPinchBegan() {
        gestureRecognizer.getStateStub.defaultReturnValue = .began

        pinchGestureHandler.handlePinch(gestureRecognizer)

        XCTAssertEqual(cameraAnimationsManager.cancelAnimationsStub.invocations.count, 1)
        XCTAssertEqual(delegate.gestureBeganStub.parameters, [.pinch])
    }

    func testPinchChanged() throws {
        let initialCameraState = CameraState.random()
        let initialPinchCenterPoint = CGPoint(x: 0.0, y: 0.0)
        let changedPinchCenterPoint = CGPoint(x: 1.0, y: 1.0)
        mapboxMap.cameraState = initialCameraState
        mapboxMap.dragCameraOptionsStub.defaultReturnValue = CameraOptions(
            center: .random(),
            zoom: .random(in: 0...20))

        // set up internal state by calling handlePinch in the .began state
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        gestureRecognizer.getScaleStub.defaultReturnValue = 2.0
        gestureRecognizer.locationStub.defaultReturnValue = initialPinchCenterPoint
        gestureRecognizer.getNumberOfTouchesStub.defaultReturnValue = 2
        pinchGestureHandler.handlePinch(gestureRecognizer)
        // reset cancelAnimationsStub so we can verify
        // that it's called when state is .changed
        cameraAnimationsManager.cancelAnimationsStub.reset()
        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.locationStub.defaultReturnValue = changedPinchCenterPoint

        pinchGestureHandler.handlePinch(gestureRecognizer)

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
                padding: initialCameraState.padding,
                zoom: initialCameraState.zoom))

        XCTAssertEqual(
            mapboxMap.dragStartStub.parameters.first,
            initialPinchCenterPoint)

        XCTAssertEqual(
            mapboxMap.dragCameraOptionsStub.parameters.first,
            .init(from: initialPinchCenterPoint, to: changedPinchCenterPoint))

        XCTAssertEqual(
            mapboxMap.setCameraStub.parameters[1],
            mapboxMap.dragCameraOptionsStub.returnedValues.first)

        let returnedScale = try XCTUnwrap(gestureRecognizer.getScaleStub.returnedValues.last)
        XCTAssertEqual(
            mapboxMap.setCameraStub.parameters[2],
            CameraOptions(
                anchor: changedPinchCenterPoint,
                zoom: mapboxMap.cameraState.zoom + log2(returnedScale)))
    }
}
