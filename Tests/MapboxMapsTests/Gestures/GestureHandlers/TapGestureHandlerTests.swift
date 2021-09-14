import XCTest
@testable import MapboxMaps

final class TapGestureHandlerTests: XCTestCase {

    var view: UIView!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var mapboxMap: MockMapboxMap!
    var delegate: MockGestureHandlerDelegate!

    override func setUp() {
        super.setUp()
        view = UIView()
        cameraAnimationsManager = MockCameraAnimationsManager()
        mapboxMap = MockMapboxMap()
        delegate = MockGestureHandlerDelegate()
    }

    override func tearDown() {
        delegate = nil
        mapboxMap = nil
        cameraAnimationsManager = nil
        view = nil
        super.tearDown()
    }

    func testSetupOfDoubleTapSingleTouchGestureHandler() {
        let numberOfTouchesRequired = Int.random(in: 1...2)

        let tapGestureHandler = TapGestureHandler(
            numberOfTouchesRequired: numberOfTouchesRequired,
            view: view,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)

        XCTAssertTrue(view.gestureRecognizers?.last === tapGestureHandler.gestureRecognizer)
        XCTAssertEqual(tapGestureHandler.gestureRecognizer.numberOfTapsRequired, 2)
        XCTAssertEqual(tapGestureHandler.gestureRecognizer.numberOfTouchesRequired, numberOfTouchesRequired)
    }

    func testHandlerDoubleTapToZoomIn() {
        let tapGestureHandler = TapGestureHandler(
            numberOfTouchesRequired: 1,
            view: view,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        tapGestureHandler.delegate = delegate
        let gestureRecognizer = MockTapGestureRecognizer()
        gestureRecognizer.getStateStub.defaultReturnValue = .ended
        gestureRecognizer.numberOfTouchesRequired = 1
        gestureRecognizer.numberOfTapsRequired = 2

        tapGestureHandler.handleTap(gestureRecognizer)

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
            view: view,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        tapGestureHandler.delegate = delegate
        let gestureRecognizer = MockTapGestureRecognizer()
        gestureRecognizer.getStateStub.defaultReturnValue = .ended
        gestureRecognizer.numberOfTouchesRequired = 2
        gestureRecognizer.numberOfTapsRequired = 2

        tapGestureHandler.handleTap(gestureRecognizer)

        XCTAssertEqual(delegate.gestureBeganStub.parameters, [.doubleTapToZoomOut])
        XCTAssertEqual(cameraAnimationsManager.easeToStub.invocations.count, 1)
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.camera, CameraOptions(zoom: mapboxMap.cameraState.zoom - 1))
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.duration, 0.3)
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.curve, .easeOut)
        XCTAssertNil(cameraAnimationsManager.easeToStub.parameters.first?.completion)
    }
}
