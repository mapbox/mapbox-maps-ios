import XCTest
@testable import MapboxMaps

final class RotateGestureHandlerTests: XCTestCase {

    var view: UIView!
    // swiftlint:disable weak_delegate
    var delegate: GestureHandlerDelegateMock!

    fileprivate var gestureManagerMock: GestureManagerMock!

    var mapboxMap: MockMapboxMap!

    var cameraAnimationsManager: MockCameraAnimationsManager!

    override func setUp() {
        super.setUp()
        view = UIView()
        delegate = GestureHandlerDelegateMock()
        gestureManagerMock = GestureManagerMock()
        mapboxMap = MockMapboxMap()
        cameraAnimationsManager = MockCameraAnimationsManager()
    }

    override func tearDown() {
        cameraAnimationsManager = nil
        mapboxMap = nil
        gestureManagerMock = nil
        delegate = nil
        view = nil
        super.setUp()
    }

    func testSetup() {
        let rotate = RotateGestureHandler(for: view,
                                          withDelegate: delegate,
                                          andContextProvider: GestureManagerMock(),
                                          mapboxMap: mapboxMap,
                                          cameraAnimationsManager: cameraAnimationsManager)
        XCTAssert(rotate.gestureRecognizer is UIRotationGestureRecognizer)
    }

    func testRotationBegan() {

        let rotateGestureHandler = RotateGestureHandler(for: view,
                                                        withDelegate: delegate,
                                                        andContextProvider: gestureManagerMock,
                                                        mapboxMap: mapboxMap,
                                                        cameraAnimationsManager: cameraAnimationsManager)

        let rotationGestureRecognizerMock = UIRotationGestureRecognizerMock()
        rotateGestureHandler.handleRotate(rotationGestureRecognizerMock)

        XCTAssertEqual(cameraAnimationsManager.cancelAnimationsStub.invocations.count, 1)
        XCTAssertTrue(delegate.gestureBeganMethod.wasCalled)
    }

    func testRotationChanged() {

        let rotateGestureHandler = RotateGestureHandler(for: view,
                                                        withDelegate: delegate,
                                                        andContextProvider: gestureManagerMock,
                                                        mapboxMap: mapboxMap,
                                                        cameraAnimationsManager: cameraAnimationsManager)

        let rotationGestureRecognizerMock = UIRotationGestureRecognizerMock()
        rotationGestureRecognizerMock.mockAngle = 10.0
        rotationGestureRecognizerMock.mockState = .changed
        rotateGestureHandler.handleRotate(rotationGestureRecognizerMock)

        XCTAssertEqual(cameraAnimationsManager.cancelAnimationsStub.invocations.count, 1)
        XCTAssertTrue(delegate.rotationChangedMethod.wasCalled)
        XCTAssertTrue(delegate.rotationChangedMethod.newAngle! == 10.0)
    }
}

private class UIRotationGestureRecognizerMock: UIRotationGestureRecognizer {

    var mockState: UIGestureRecognizer.State = .began
    var mockAngle: CGFloat = 2.0

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
            return mockAngle
        }
        set {
            fatalError("unimplemented")
        }
    }

}

private class GestureManagerMock: GestureContextProvider {
    func requireGestureToFail(allowedGesture: GestureHandler, failableGesture: GestureHandler) {
        guard let failableGesture = failableGesture.gestureRecognizer else { return }
        allowedGesture.gestureRecognizer?.require(toFail: failableGesture)
    }

    func fetchPinchState() -> UIGestureRecognizer.State? {
        return .began
    }

    func fetchPinchScale() -> CGFloat? {
        return 10.0
    }
}
