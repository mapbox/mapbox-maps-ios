import XCTest
@testable import MapboxMaps

final class DoubleTouchToZoomOutGestureHandlerTests: XCTestCase {

    var gestureRecognizer: MockTapGestureRecognizer!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var mapboxMap: MockMapboxMap!
    var gestureHandler: DoubleTouchToZoomOutGestureHandler!
    // swiftlint:disable:next weak_delegate
    var delegate: MockGestureHandlerDelegate!

    override func setUp() {
        super.setUp()
        gestureRecognizer = MockTapGestureRecognizer()
        cameraAnimationsManager = MockCameraAnimationsManager()
        mapboxMap = MockMapboxMap()
        gestureHandler = DoubleTouchToZoomOutGestureHandler(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        delegate = MockGestureHandlerDelegate()
        gestureHandler.delegate = delegate
    }

    override func tearDown() {
        delegate = nil
        gestureHandler = nil
        mapboxMap = nil
        cameraAnimationsManager = nil
        gestureRecognizer = nil
        super.tearDown()
    }

    func testInitialization() {
        XCTAssertTrue(gestureRecognizer === gestureHandler.gestureRecognizer)
        XCTAssertEqual(gestureRecognizer.numberOfTapsRequired, 1)
        XCTAssertEqual(gestureRecognizer.numberOfTouchesRequired, 2)
    }

    func testHandler() {
        gestureRecognizer.getStateStub.defaultReturnValue = .recognized
        mapboxMap.cameraState = .random()

        gestureRecognizer.sendActions()

        XCTAssertEqual(delegate.gestureBeganStub.parameters, [.doubleTouchToZoomOut])
        XCTAssertEqual(cameraAnimationsManager.easeToStub.invocations.count, 1)
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.camera, CameraOptions(zoom: mapboxMap.cameraState.zoom - 1))
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.duration, 0.3)
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.curve, .easeOut)
        XCTAssertNotNil(cameraAnimationsManager.easeToStub.parameters.first?.completion)
        XCTAssertEqual(delegate.gestureEndedStub.parameters.first?.gestureType, .doubleTouchToZoomOut)
        do {
            let willDecelerate = try XCTUnwrap(delegate.gestureEndedStub.parameters.first?.willDecelerate)
            XCTAssertTrue(willDecelerate)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
