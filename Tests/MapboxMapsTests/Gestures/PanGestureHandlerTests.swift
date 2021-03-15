import XCTest
#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsGestures
#endif

//swiftlint:disable explicit_acl explicit_top_level_acl
class PanGestureHandlerTests: XCTestCase {

    var view: UIView!
    // swiftlint:disable weak_delegate
    var delegate: GestureHandlerDelegateMock!

    override func setUp() {
        view = UIView()
        delegate = GestureHandlerDelegateMock()
    }

    override func tearDown() {
        view = nil
        delegate = nil
    }

    func testSetup() {
        let panGestureHandler = PanGestureHandler(for: view,
                                                  withDelegate: delegate,
                                                  panScrollMode: .horizontalAndVertical)
        XCTAssertTrue(panGestureHandler.view?.gestureRecognizers?.first is UIPanGestureRecognizer)
    }

    func testHandlePan() {
        let panGestureHandler = PanGestureHandler(for: view,
                                                  withDelegate: delegate,
                                                  panScrollMode: .horizontal)
        let panMock = UIPanGestureRecognizerMock()
        panGestureHandler.handlePan(panMock)

        XCTAssertTrue(delegate.pannedCalled)
    }
}

private class UIPanGestureRecognizerMock: UIPanGestureRecognizer {

    override var state: UIGestureRecognizer.State {
        get {
            return .changed // returning default of changed for test
        } set {
            self.state = newValue
        }
    }
}
