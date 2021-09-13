import XCTest
@testable import MapboxMaps

final class RotateGestureHandlerTests: XCTestCase {
    var view: UIView!
    var mapboxMap: MockMapboxMap!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var rotateGestureHandler: RotateGestureHandler!
    var delegate: MockGestureManagerDelegate!
    var gestureRecognizer: MockRotationGestureRecognizer!

    override func setUp() {
        super.setUp()
        view = UIView()
        mapboxMap = MockMapboxMap()
        cameraAnimationsManager = MockCameraAnimationsManager()
        rotateGestureHandler = RotateGestureHandler(
            view: view,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        delegate = MockGestureManagerDelegate()
        rotateGestureHandler.delegate = delegate
        gestureRecognizer = MockRotationGestureRecognizer()
    }

    override func tearDown() {
        gestureRecognizer = nil
        delegate = nil
        rotateGestureHandler = nil
        cameraAnimationsManager = nil
        mapboxMap = nil
        view = nil
        super.setUp()
    }

    func testInitialization() throws {
        let gestureRecognizer = try XCTUnwrap(rotateGestureHandler.gestureRecognizer as? UIRotationGestureRecognizer)
        XCTAssertTrue(view.gestureRecognizers?.last === gestureRecognizer)
    }

    func testRotationBegan() {
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        rotateGestureHandler.handleRotate(gestureRecognizer)

        XCTAssertEqual(cameraAnimationsManager.cancelAnimationsStub.invocations.count, 1)
        XCTAssertEqual(delegate.gestureBeganStub.parameters, [.rotate])
    }

    func testRotationChanged() throws {
        // Capture the initial rotation
        mapboxMap.cameraState.bearing = .random(in: 0..<360)
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        rotateGestureHandler.handleRotate(gestureRecognizer)
        cameraAnimationsManager.cancelAnimationsStub.reset()

        // Execute the change
        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.getRotationStub.defaultReturnValue = -.pi / 2
        rotateGestureHandler.handleRotate(gestureRecognizer)

        XCTAssertEqual(cameraAnimationsManager.cancelAnimationsStub.invocations.count, 1)
        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 1)
        let params = try XCTUnwrap(mapboxMap.setCameraStub.parameters.first)
        let bearing = try XCTUnwrap(params.bearing)
        XCTAssertEqual(
            bearing,
            (mapboxMap.cameraState.bearing + 90).truncatingRemainder(dividingBy: 360), accuracy: 1e-13)
        XCTAssertNil(params.center)
        XCTAssertNil(params.zoom)
        XCTAssertNil(params.pitch)
        XCTAssertNil(params.anchor)
        XCTAssertNil(params.padding)
    }
}
