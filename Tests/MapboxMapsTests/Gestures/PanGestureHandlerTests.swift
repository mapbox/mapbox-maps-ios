import XCTest
@testable import MapboxMaps

final class PanGestureHandlerTests: XCTestCase {

    var view: UIView!
    // swiftlint:disable weak_delegate
    var delegate: GestureHandlerDelegateMock!
    var mapboxMap: MockMapboxMap!
    var cameraAnimationsManager: MockCameraAnimationsManager!

    override func setUp() {
        super.setUp()
        view = UIView()
        delegate = GestureHandlerDelegateMock()
        mapboxMap = MockMapboxMap()
        cameraAnimationsManager = MockCameraAnimationsManager()
    }

    override func tearDown() {
        cameraAnimationsManager = nil
        mapboxMap = nil
        delegate = nil
        view = nil
        super.tearDown()
    }

    func testSetup() {
        let panGestureHandler = PanGestureHandler(for: view,
                                                  withDelegate: delegate,
                                                  panScrollMode: .horizontalAndVertical,
                                                  mapboxMap: mapboxMap,
                                                  cameraAnimationsManager: cameraAnimationsManager)
        XCTAssertTrue(panGestureHandler.view?.gestureRecognizers?.first is UIPanGestureRecognizer)
    }

    func testHandlePan() {
        let panGestureHandler = PanGestureHandler(for: view,
                                                  withDelegate: delegate,
                                                  panScrollMode: .horizontal,
                                                  mapboxMap: mapboxMap,
                                                  cameraAnimationsManager: cameraAnimationsManager)
        let panMock = UIPanGestureRecognizerMock()
        panGestureHandler.handlePan(panMock)

        XCTAssertEqual(mapboxMap.dragCameraOptionsStub.invocations.count, 1)
    }
}

private class UIPanGestureRecognizerMock: UIPanGestureRecognizer {

    override var state: UIGestureRecognizer.State {
        get {
            return .changed // returning default of changed for test
        }
        set {
            fatalError("unimplemented")
        }
    }
}
