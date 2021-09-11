import XCTest
@testable import MapboxMaps

final class RotateGestureHandlerTests: XCTestCase {

    var view: UIView!
    // swiftlint:disable weak_delegate
    var delegate: GestureHandlerDelegateMock!

    fileprivate var gestureManagerMock: GestureManagerMock!

    var mapboxMap: MockMapboxMap!

    override func setUp() {
        super.setUp()
        view = UIView()
        delegate = GestureHandlerDelegateMock()
        gestureManagerMock = GestureManagerMock()
        mapboxMap = MockMapboxMap()
    }

    override func tearDown() {
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
                                          mapboxMap: mapboxMap)
        XCTAssert(rotate.gestureRecognizer is UIRotationGestureRecognizer)
    }

    func testRotationBegan() {

        let rotateGestureHandler = RotateGestureHandler(for: view,
                                                        withDelegate: delegate,
                                                        andContextProvider: gestureManagerMock,
                                                        mapboxMap: mapboxMap)

        let rotationGestureRecognizerMock = UIRotationGestureRecognizerMock()
        rotateGestureHandler.handleRotate(rotationGestureRecognizerMock)

        XCTAssert(delegate.cancelTransitionsCalled)
        XCTAssert(delegate.gestureBeganMethod.wasCalled)
    }

    func testRotationChanged() {

        let rotateGestureHandler = RotateGestureHandler(for: view,
                                                        withDelegate: delegate,
                                                        andContextProvider: gestureManagerMock,
                                                        mapboxMap: mapboxMap)

        let rotationGestureRecognizerMock = UIRotationGestureRecognizerMock()
        rotationGestureRecognizerMock.mockAngle = 10.0
        rotationGestureRecognizerMock.mockState = .changed
        rotateGestureHandler.handleRotate(rotationGestureRecognizerMock)

        XCTAssert(delegate.cancelTransitionsCalled)
        XCTAssert(delegate.rotationChangedMethod.wasCalled)
        XCTAssert(delegate.rotationChangedMethod.newAngle! == 10.0)
    }

    func testRotationEnded() {

        let rotateGestureHandler = RotateGestureHandler(for: view,
                                                        withDelegate: delegate,
                                                        andContextProvider: gestureManagerMock,
                                                        mapboxMap: mapboxMap)

        let rotationGestureRecognizerMock = UIRotationGestureRecognizerMock()
        rotationGestureRecognizerMock.mockState = .ended
        rotateGestureHandler.handleRotate(rotationGestureRecognizerMock)

        XCTAssert(delegate.cancelTransitionsCalled)
        XCTAssert(delegate.rotationEndedMethod.wasCalled)
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
