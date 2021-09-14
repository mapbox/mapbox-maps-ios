import XCTest
@testable import MapboxMaps

final class RotateGestureHandlerTests: XCTestCase {
    var gestureRecognizer: MockRotationGestureRecognizer!
    var mapboxMap: MockMapboxMap!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var rotateGestureHandler: RotateGestureHandler!
    // swiftlint:disable:next weak_delegate
    var delegate: MockGestureHandlerDelegate!

    override func setUp() {
        super.setUp()
        gestureRecognizer = MockRotationGestureRecognizer()
        mapboxMap = MockMapboxMap()
        cameraAnimationsManager = MockCameraAnimationsManager()
        rotateGestureHandler = RotateGestureHandler(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        delegate = MockGestureHandlerDelegate()
        rotateGestureHandler.delegate = delegate
    }

    override func tearDown() {
        delegate = nil
        rotateGestureHandler = nil
        cameraAnimationsManager = nil
        mapboxMap = nil
        gestureRecognizer = nil
        super.setUp()
    }

    func testInitialization() {
        XCTAssertTrue(gestureRecognizer === rotateGestureHandler.gestureRecognizer)
    }

    func testAllowedSimultaneousGestures() {
        XCTAssertTrue(rotateGestureHandler.gestureRecognizer(
                        rotateGestureHandler.gestureRecognizer,
                        shouldRecognizeSimultaneouslyWith: UIPinchGestureRecognizer()))
    }

    func testDisallowedSimultaneousGestures() {
        XCTAssertFalse(rotateGestureHandler.gestureRecognizer(
                        rotateGestureHandler.gestureRecognizer,
                        shouldRecognizeSimultaneouslyWith: UIPanGestureRecognizer()))
        XCTAssertFalse(rotateGestureHandler.gestureRecognizer(
                        rotateGestureHandler.gestureRecognizer,
                        shouldRecognizeSimultaneouslyWith: UITapGestureRecognizer()))
        XCTAssertFalse(rotateGestureHandler.gestureRecognizer(
                        rotateGestureHandler.gestureRecognizer,
                        shouldRecognizeSimultaneouslyWith: UIRotationGestureRecognizer()))
    }

    func testRotationBegan() {
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        gestureRecognizer.sendActions()

        XCTAssertEqual(cameraAnimationsManager.cancelAnimationsStub.invocations.count, 1)
        XCTAssertEqual(delegate.gestureBeganStub.parameters, [.rotate])
    }

    func testRotationChanged() throws {
        // Capture the initial rotation
        mapboxMap.cameraState.bearing = .random(in: 0..<360)
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        gestureRecognizer.sendActions()
        cameraAnimationsManager.cancelAnimationsStub.reset()

        // Execute the change
        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.getRotationStub.defaultReturnValue = -.pi / 2
        gestureRecognizer.sendActions()

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
