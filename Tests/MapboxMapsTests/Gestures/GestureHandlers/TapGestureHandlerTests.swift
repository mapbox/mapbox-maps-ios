import XCTest
@testable import MapboxMaps

final class TapGestureHandlerTests: XCTestCase {

    var view: UIView!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var mapboxMap: MockMapboxMap!

    override func setUp() {
        super.setUp()
        view = UIView()
        cameraAnimationsManager = MockCameraAnimationsManager()
        mapboxMap = MockMapboxMap()
    }

    override func tearDown() {
        mapboxMap = nil
        cameraAnimationsManager = nil
        view = nil
        super.tearDown()
    }

    func testSetupOfDoubleTapSingleTouchGestureHandler() throws {
        let numberOfTouchesRequired = Int.random(in: 1...2)

        let tapGestureHandler = TapGestureHandler(
            numberOfTouchesRequired: numberOfTouchesRequired,
            view: view,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)

        let gestureRecognizer = try XCTUnwrap(tapGestureHandler.gestureRecognizer as? UITapGestureRecognizer)
        XCTAssertTrue(view.gestureRecognizers?.last === gestureRecognizer)
        XCTAssertEqual(gestureRecognizer.numberOfTapsRequired, 2)
        XCTAssertEqual(gestureRecognizer.numberOfTouchesRequired, numberOfTouchesRequired)
    }

    func testHandlerSingleTouch() {
        let tapGestureHandler = TapGestureHandler(
            numberOfTouchesRequired: 1,
            view: view,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        let gestureRecognizer = MockTapGestureRecognizer()
        gestureRecognizer.getStateStub.defaultReturnValue = .ended
        gestureRecognizer.numberOfTouchesRequired = 1
        gestureRecognizer.numberOfTapsRequired = 2

        tapGestureHandler.handleTap(gestureRecognizer)

        XCTAssertEqual(cameraAnimationsManager.easeToStub.invocations.count, 1)
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.camera, CameraOptions(zoom: mapboxMap.cameraState.zoom + 1))
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.duration, 0.3)
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.curve, .easeOut)
        XCTAssertNil(cameraAnimationsManager.easeToStub.parameters.first?.completion)
    }

    func testHandlerDoubleTapDoubleTouch() {
        let tapGestureHandler = TapGestureHandler(
            numberOfTouchesRequired: 2,
            view: view,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        let gestureRecognizer = MockTapGestureRecognizer()
        gestureRecognizer.getStateStub.defaultReturnValue = .ended
        gestureRecognizer.numberOfTouchesRequired = 2
        gestureRecognizer.numberOfTapsRequired = 2

        tapGestureHandler.handleTap(gestureRecognizer)

        XCTAssertEqual(cameraAnimationsManager.easeToStub.invocations.count, 1)
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.camera, CameraOptions(zoom: mapboxMap.cameraState.zoom - 1))
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.duration, 0.3)
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.curve, .easeOut)
        XCTAssertNil(cameraAnimationsManager.easeToStub.parameters.first?.completion)
    }
}
