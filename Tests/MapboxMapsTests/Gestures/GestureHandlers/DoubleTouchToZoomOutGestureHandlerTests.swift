import XCTest
@testable import MapboxMaps

final class DoubleTouchToZoomOutGestureHandlerTests: XCTestCase {
    var view: UIView!
    var gestureRecognizer: MockTapGestureRecognizer!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var mapboxMap: MockMapboxMap!
    var gestureHandler: DoubleTouchToZoomOutGestureHandler!
    // swiftlint:disable:next weak_delegate
    var delegate: MockGestureHandlerDelegate!

    override func setUp() {
        super.setUp()
        view = UIView()
        gestureRecognizer = MockTapGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
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
        view = nil
        super.tearDown()
    }

    func testInitialization() {
        XCTAssertTrue(gestureRecognizer === gestureHandler.gestureRecognizer)
        XCTAssertEqual(gestureRecognizer.numberOfTapsRequired, 1)
        XCTAssertEqual(gestureRecognizer.numberOfTouchesRequired, 2)
    }

    func testHandler() throws {
        gestureRecognizer.getStateStub.defaultReturnValue = .recognized
        mapboxMap.cameraState = .random()

        gestureRecognizer.sendActions()

        let tapLocation = try XCTUnwrap(gestureRecognizer.locationStub.returnedValues.first)
        XCTAssertEqual(delegate.gestureBeganStub.parameters, [.doubleTouchToZoomOut])
        assertMethodCall(cameraAnimationsManager.easeToStub)
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.camera, CameraOptions(anchor: tapLocation, zoom: mapboxMap.cameraState.zoom - 1))
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.duration, 0.3)
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.curve, .easeOut)
        XCTAssertEqual(delegate.gestureEndedStub.parameters.first?.gestureType, .doubleTouchToZoomOut)
        let willAnimate = try XCTUnwrap(delegate.gestureEndedStub.parameters.first?.willAnimate)
        XCTAssertTrue(willAnimate)

        let easeToCompletion = try XCTUnwrap(cameraAnimationsManager.easeToStub.parameters.first?.completion)
        easeToCompletion(.end)
        XCTAssertEqual(delegate.animationEndedStub.parameters, [.doubleTouchToZoomOut])
    }
}
