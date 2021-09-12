import XCTest
@testable import MapboxMaps

final class RotateGestureHandlerTests: XCTestCase {

    var view: UIView!

    var mapboxMap: MockMapboxMap!

    var cameraAnimationsManager: MockCameraAnimationsManager!

    var delegate: MockGestureManagerDelegate!

    override func setUp() {
        super.setUp()
        view = UIView()
        mapboxMap = MockMapboxMap()
        cameraAnimationsManager = MockCameraAnimationsManager()
        delegate = MockGestureManagerDelegate()
    }

    override func tearDown() {
        delegate = nil
        cameraAnimationsManager = nil
        mapboxMap = nil
        view = nil
        super.setUp()
    }

    func testSetup() {
        let rotate = RotateGestureHandler(for: view,
                                          mapboxMap: mapboxMap,
                                          cameraAnimationsManager: cameraAnimationsManager)
        XCTAssert(rotate.gestureRecognizer is UIRotationGestureRecognizer)
    }

    func testRotationBegan() {
        let rotateGestureHandler = RotateGestureHandler(for: view,
                                                        mapboxMap: mapboxMap,
                                                        cameraAnimationsManager: cameraAnimationsManager)
        rotateGestureHandler.delegate = delegate

        let rotationGestureRecognizerMock = UIRotationGestureRecognizerMock()
        rotateGestureHandler.handleRotate(rotationGestureRecognizerMock)

        XCTAssertEqual(cameraAnimationsManager.cancelAnimationsStub.invocations.count, 1)
        XCTAssertEqual(delegate.gestureBeganStub.parameters, [.rotate])
    }

    func testRotationChanged() throws {
        let rotateGestureHandler = RotateGestureHandler(for: view,
                                                        mapboxMap: mapboxMap,
                                                        cameraAnimationsManager: cameraAnimationsManager)

        // Capture the initial rotation
        mapboxMap.cameraState.bearing = .random(in: 0..<360)
        let rotationGestureRecognizer = UIRotationGestureRecognizerMock()
        rotationGestureRecognizer.mockState = .began
        rotateGestureHandler.handleRotate(rotationGestureRecognizer)
        cameraAnimationsManager.cancelAnimationsStub.reset()

        // Execute the change
        rotationGestureRecognizer.mockState = .changed
        rotationGestureRecognizer.mockRotation = -.pi / 2
        rotateGestureHandler.handleRotate(rotationGestureRecognizer)

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

private class UIRotationGestureRecognizerMock: UIRotationGestureRecognizer {

    var mockState: UIGestureRecognizer.State = .began
    var mockRotation: CGFloat = 2.0

    override var state: UIGestureRecognizer.State {
        get {
            return mockState
        }
        set {
            fatalError("unimplemented")
        }
    }

    override var rotation: CGFloat {
        get {
            return mockRotation
        }
        set {
            fatalError("unimplemented")
        }
    }

}
