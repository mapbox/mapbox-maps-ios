import XCTest
@testable import MapboxMaps

final class TapGestureHandlerTests: XCTestCase {

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

    func testSetupOfDoubleTapSingleTouchGestureHandler() {
        let numberOfTouchesRequired = Int.random(in: 1...2)

        let tapGestureHandler = TapGestureHandler(
            numberOfTouchesRequired: numberOfTouchesRequired,
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)

        XCTAssertTrue(gestureRecognizer === tapGestureHandler.gestureRecognizer)
        XCTAssertEqual(gestureRecognizer.numberOfTapsRequired, 2)
        XCTAssertEqual(gestureRecognizer.numberOfTouchesRequired, numberOfTouchesRequired)
    }

    func testHandlerDoubleTapToZoomIn() {
        let tapGestureHandler = TapGestureHandler(
            numberOfTouchesRequired: 1,
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        tapGestureHandler.delegate = delegate
        gestureRecognizer.getStateStub.defaultReturnValue = .ended

        gestureRecognizer.sendActions()

        XCTAssertEqual(delegate.gestureBeganStub.parameters, [.doubleTapToZoomIn])
        XCTAssertEqual(cameraAnimationsManager.easeToStub.invocations.count, 1)
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.camera, CameraOptions(zoom: mapboxMap.cameraState.zoom + 1))
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.duration, 0.3)
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.curve, .easeOut)
        XCTAssertNil(cameraAnimationsManager.easeToStub.parameters.first?.completion)
    }

    func testHandlerDoubleTapToZoomOut() {
        let tapGestureHandler = TapGestureHandler(
            numberOfTouchesRequired: 2,
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        tapGestureHandler.delegate = delegate
        gestureRecognizer.getStateStub.defaultReturnValue = .ended

        gestureRecognizer.sendActions()

        XCTAssertEqual(delegate.gestureBeganStub.parameters, [.doubleTapToZoomOut])
        XCTAssertEqual(cameraAnimationsManager.easeToStub.invocations.count, 1)
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.camera, CameraOptions(zoom: mapboxMap.cameraState.zoom - 1))
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.duration, 0.3)
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.curve, .easeOut)
        XCTAssertNil(cameraAnimationsManager.easeToStub.parameters.first?.completion)
    }
}
