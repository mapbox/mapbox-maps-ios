import XCTest
@testable import MapboxMaps

//swiftlint:disable explicit_top_level_acl explicit_acl
class RotateGestureHandlerTests: XCTestCase {

    var view: UIView!
    // swiftlint:disable weak_delegate
    var delegate: GestureHandlerDelegateMock!

    fileprivate var gestureManagerMock: GestureManagerMock!

    override func setUp() {
        view = UIView()
        delegate = GestureHandlerDelegateMock()
        gestureManagerMock = GestureManagerMock()
    }

    override func tearDown() {
        view = nil
        delegate = nil
        gestureManagerMock = nil
    }

    func testSetup() {
        let rotate = RotateGestureHandler(for: view,
                                          withDelegate: delegate,
                                          andContextProvider: GestureManagerMock())
        XCTAssert(rotate.gestureRecognizer is UIRotationGestureRecognizer)
    }

    func testRotationBegan() {

        let rotateGestureHandler = RotateGestureHandler(for: view,
                                                        withDelegate: delegate,
                                                        andContextProvider: gestureManagerMock)

        let rotationGestureRecognizerMock = UIRotationGestureRecognizerMock()
        rotateGestureHandler.handleRotate(rotationGestureRecognizerMock)

        XCTAssert(delegate.cancelTransitionsCalled)
        XCTAssert(delegate.gestureBeganMethod.wasCalled)
        XCTAssert(delegate.rotationStartCalled)
    }

    func testRotationChanged() {

        let rotateGestureHandler = RotateGestureHandler(for: view,
                                                        withDelegate: delegate,
                                                        andContextProvider: gestureManagerMock)

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
                                                        andContextProvider: gestureManagerMock)

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
            return self.mockState
        } set {
            self.state = newValue
        }
    }

    override var rotation: CGFloat {
        get {
            return mockAngle
        } set {
            self.rotation = newValue
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
