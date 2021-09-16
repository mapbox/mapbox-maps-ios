import XCTest
@testable import MapboxMaps

final class DoubleTapToZoomGestureHandlerTests: XCTestCase {

    var gestureRecognizer: MockTapGestureRecognizer!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var mapboxMap: MockMapboxMap!
    // swiftlint:disable:next weak_delegate
    var delegate: MockGestureHandlerDelegate!

    override func setUp() {
        super.setUp()
        gestureRecognizer = MockTapGestureRecognizer()
        cameraAnimationsManager = MockCameraAnimationsManager()
        mapboxMap = MockMapboxMap()
        delegate = MockGestureHandlerDelegate()
    }

    override func tearDown() {
        delegate = nil
        mapboxMap = nil
        cameraAnimationsManager = nil
        gestureRecognizer = nil
        super.tearDown()
    }

    func testInitializationWithPositiveZoomDelta() {
        let numberOfTouchesRequired = Int.random(in: 1...100)
        let zoomDelta = CGFloat.random(in: .leastNonzeroMagnitude...100)

        let doubleTapGestureHandler = DoubleTapToZoomGestureHandler(
            numberOfTouchesRequired: numberOfTouchesRequired,
            zoomDelta: zoomDelta,
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)

        XCTAssertTrue(gestureRecognizer === doubleTapGestureHandler.gestureRecognizer)
        XCTAssertEqual(gestureRecognizer.numberOfTapsRequired, 2)
        XCTAssertEqual(gestureRecognizer.numberOfTouchesRequired, numberOfTouchesRequired)
    }

    func testHandlerDoubleTapToZoomIn() {
        let zoomDelta = CGFloat.random(in: .leastNonzeroMagnitude...1)
        let doubleTapGestureHandler = DoubleTapToZoomGestureHandler(
            numberOfTouchesRequired: 1,
            zoomDelta: zoomDelta,
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        doubleTapGestureHandler.delegate = delegate
        gestureRecognizer.getStateStub.defaultReturnValue = .ended

        gestureRecognizer.sendActions()

        XCTAssertEqual(delegate.gestureBeganStub.parameters, [.doubleTapToZoomIn])
        XCTAssertEqual(cameraAnimationsManager.easeToStub.invocations.count, 1)
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.camera, CameraOptions(zoom: mapboxMap.cameraState.zoom + zoomDelta))
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.duration, 0.3)
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.curve, .easeOut)
        XCTAssertNil(cameraAnimationsManager.easeToStub.parameters.first?.completion)
    }

    func testHandlerDoubleTapToZoomOut() {
        let zoomDelta = -CGFloat.random(in: .leastNonzeroMagnitude...1)
        let doubleTapGestureHandler = DoubleTapToZoomGestureHandler(
            numberOfTouchesRequired: 2,
            zoomDelta: zoomDelta,
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        doubleTapGestureHandler.delegate = delegate
        gestureRecognizer.getStateStub.defaultReturnValue = .ended

        gestureRecognizer.sendActions()

        XCTAssertEqual(delegate.gestureBeganStub.parameters, [.doubleTapToZoomOut])
        XCTAssertEqual(cameraAnimationsManager.easeToStub.invocations.count, 1)
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.camera, CameraOptions(zoom: mapboxMap.cameraState.zoom + zoomDelta))
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.duration, 0.3)
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.curve, .easeOut)
        XCTAssertNil(cameraAnimationsManager.easeToStub.parameters.first?.completion)
    }
}
