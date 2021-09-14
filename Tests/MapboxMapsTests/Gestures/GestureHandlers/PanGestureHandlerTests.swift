import XCTest
@testable import MapboxMaps

final class PanGestureHandlerTests: XCTestCase {
    var decelerationRate: CGFloat!
    var panScrollingMode: PanScrollingMode!
    var view: UIView!
    var mapboxMap: MockMapboxMap!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var panGestureHandler: PanGestureHandler!
    var delegate: MockGestureHandlerDelegate!
    var gestureRecognizer: MockPanGestureRecognizer!

    override func setUp() {
        super.setUp()
        decelerationRate = .random(in: 0.99...0.999)
        panScrollingMode = PanScrollingMode.allCases.randomElement()
        view = UIView()
        mapboxMap = MockMapboxMap()
        cameraAnimationsManager = MockCameraAnimationsManager()
        panGestureHandler = PanGestureHandler(
            decelerationRate: decelerationRate,
            panScrollingMode: panScrollingMode,
            view: view,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        delegate = MockGestureHandlerDelegate()
        panGestureHandler.delegate = delegate
        gestureRecognizer = MockPanGestureRecognizer()
        gestureRecognizer.getViewStub.defaultReturnValue = view
    }

    override func tearDown() {
        gestureRecognizer = nil
        delegate = nil
        panGestureHandler = nil
        cameraAnimationsManager = nil
        mapboxMap = nil
        view = nil
        panScrollingMode = nil
        decelerationRate = nil
        super.tearDown()
    }

    func testInitialization() {
        XCTAssertEqual(panGestureHandler.decelerationRate, decelerationRate)
        XCTAssertEqual(panGestureHandler.panScrollingMode, panScrollingMode)
        XCTAssertTrue(view.gestureRecognizers?.last === panGestureHandler.gestureRecognizer)
        XCTAssertEqual(panGestureHandler.gestureRecognizer.maximumNumberOfTouches, 1)
    }

    func testHandlePanBegan() {
        gestureRecognizer.getStateStub.defaultReturnValue = .began

        panGestureHandler.handlePan(gestureRecognizer)

        XCTAssertEqual(cameraAnimationsManager.cancelAnimationsStub.invocations.count, 1)
        XCTAssertEqual(delegate.gestureBeganStub.parameters, [.pan])
    }

    func verifyHandlePanChanged(panScrollingMode: PanScrollingMode,
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
        panGestureHandler.panScrollingMode = panScrollingMode
        panGestureHandler.handlePan(gestureRecognizer)
        cameraAnimationsManager.cancelAnimationsStub.reset()
        gestureRecognizer.getStateStub.defaultReturnValue = .changed

        panGestureHandler.handlePan(gestureRecognizer)

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
            panScrollingMode: .horizontalAndVertical,
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
            panScrollingMode: .horizontal,
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
            panScrollingMode: .vertical,
            initialTouchLocation: initialTouchLocation,
            changedTouchLocation: changedTouchLocation,
            clampedTouchLocation: clampedTouchLocation)
    }
}
