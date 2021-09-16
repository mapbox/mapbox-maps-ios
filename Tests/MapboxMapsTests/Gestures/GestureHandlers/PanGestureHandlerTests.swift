import XCTest
@testable import MapboxMaps

final class PanGestureHandlerTests: XCTestCase {
    var view: UIView!
    var gestureRecognizer: MockPanGestureRecognizer!
    var mapboxMap: MockMapboxMap!
    var cameraAnimationsManager: MockCameraAnimationsManager!
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
        panGestureHandler = PanGestureHandler(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        delegate = MockGestureHandlerDelegate()
        panGestureHandler.delegate = delegate
        delegate.decelerationRate = .random(in: 0.99...0.999)
        delegate.panScrollingMode = PanScrollingMode.allCases.randomElement()!
    }

    override func tearDown() {
        delegate = nil
        panGestureHandler = nil
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
        delegate.panScrollingMode = panScrollingMode
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
