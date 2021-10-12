import XCTest
@testable import MapboxMaps

final class DoubleTapToZoomInGestureHandlerTests: XCTestCase {
    var view: UIView!
    var gestureRecognizer: MockTapGestureRecognizer!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var mapboxMap: MockMapboxMap!
    var gestureHandler: DoubleTapToZoomInGestureHandler!
    // swiftlint:disable:next weak_delegate
    var delegate: MockGestureHandlerDelegate!

    override func setUp() {
        super.setUp()
        view = UIView()
        gestureRecognizer = MockTapGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        cameraAnimationsManager = MockCameraAnimationsManager()
        mapboxMap = MockMapboxMap()
        gestureHandler = DoubleTapToZoomInGestureHandler(
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
        XCTAssertEqual(gestureRecognizer.numberOfTapsRequired, 2)
        XCTAssertEqual(gestureRecognizer.numberOfTouchesRequired, 1)
    }

    func testHandler() throws {
        gestureRecognizer.getStateStub.defaultReturnValue = .recognized
        mapboxMap.cameraState = .random()

        gestureRecognizer.sendActions()

        let tapLocation = try XCTUnwrap(gestureRecognizer.locationStub.returnedValues.first)
        XCTAssertEqual(delegate.gestureBeganStub.parameters, [.doubleTapToZoomIn])
        XCTAssertEqual(cameraAnimationsManager.easeToStub.invocations.count, 1)
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.camera, CameraOptions(anchor: tapLocation, zoom: mapboxMap.cameraState.zoom + 1))
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.duration, 0.3)
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.curve, .easeOut)
        XCTAssertEqual(delegate.gestureEndedStub.parameters.first?.gestureType, .doubleTapToZoomIn)
        let willAnimate = try XCTUnwrap(delegate.gestureEndedStub.parameters.first?.willAnimate)
        XCTAssertTrue(willAnimate)

        let easeToCompletion = try XCTUnwrap(cameraAnimationsManager.easeToStub.parameters.first?.completion)
        easeToCompletion(.end)
        XCTAssertEqual(delegate.animationEndedStub.parameters, [.doubleTapToZoomIn])
    }
}
