import XCTest
@testable import MapboxMaps

final class TapGestureHandlerTests: XCTestCase {

    var view: UIView!
    // swiftlint:disable weak_delegate
    var delegate: GestureHandlerDelegateMock!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var mapboxMap: MockMapboxMap!

    override func setUp() {
        super.setUp()
        view = UIView()
        delegate = GestureHandlerDelegateMock()
        cameraAnimationsManager = MockCameraAnimationsManager()
        mapboxMap = MockMapboxMap()
    }

    override func tearDown() {
        mapboxMap = nil
        cameraAnimationsManager = nil
        delegate = nil
        view = nil
        super.tearDown()
    }

    func testSetupOfSingleTapSingleTouchGestureHandler() {
        let tapGestureHandler = TapGestureHandler(for: view,
                                                  numberOfTapsRequired: 1,
                                                  numberOfTouchesRequired: 1,
                                                  withDelegate: delegate,
                                                  cameraAnimationsManager: cameraAnimationsManager,
                                                  mapboxMap: mapboxMap)

        guard let validTapGestureRecognizer = tapGestureHandler.view?.gestureRecognizers?.first
                                              as? UITapGestureRecognizer else {
            XCTFail("No valid tap gesture recognizer found")
            return
        }

        XCTAssert(validTapGestureRecognizer.numberOfTapsRequired == 1)
        XCTAssert(validTapGestureRecognizer.numberOfTouchesRequired == 1)
    }

    func testSetupOfDoubleTapSingleTouchGestureHandler() {
        let tapGestureHandler = TapGestureHandler(for: view,
                                                  numberOfTapsRequired: 2,
                                                  numberOfTouchesRequired: 1,
                                                  withDelegate: delegate,
                                                  cameraAnimationsManager: cameraAnimationsManager,
                                                  mapboxMap: mapboxMap)

        guard let validTapGestureRecognizer = tapGestureHandler.view?.gestureRecognizers?.first
                                              as? UITapGestureRecognizer else {
            XCTFail("No valid tap gesture recognizer found")
            return
        }

        XCTAssert(validTapGestureRecognizer.numberOfTapsRequired == 2)
        XCTAssert(validTapGestureRecognizer.numberOfTouchesRequired == 1)
    }

    func testSetupOfDoubleTapDoubleTouchGestureHandler() {
        let tapGestureHandler = TapGestureHandler(for: view,
                                                  numberOfTapsRequired: 2,
                                                  numberOfTouchesRequired: 2,
                                                  withDelegate: delegate,
                                                  cameraAnimationsManager: cameraAnimationsManager,
                                                  mapboxMap: mapboxMap)

        guard let validTapGestureRecognizer = tapGestureHandler.view?.gestureRecognizers?.first
                                              as? UITapGestureRecognizer else {
            XCTFail("No valid tap gesture recognizer found")
            return
        }

        XCTAssert(validTapGestureRecognizer.numberOfTapsRequired == 2)
        XCTAssert(validTapGestureRecognizer.numberOfTouchesRequired == 2)
    }

    func testHandlerDoubleTapSingleTouch() {
        let tapGestureHandler = TapGestureHandler(for: view,
                                                  numberOfTapsRequired: 2,
                                                  numberOfTouchesRequired: 1,
                                                  withDelegate: delegate,
                                                  cameraAnimationsManager: cameraAnimationsManager,
                                                  mapboxMap: mapboxMap)

        guard let tapGestureRecognizer = tapGestureHandler.view?.gestureRecognizers?.first
                                         as? UITapGestureRecognizer else {
            XCTFail("No valid tap gesture recognizer found")
            return
        }

        tapGestureHandler.handleTap(tapGestureRecognizer)
        XCTAssertEqual(cameraAnimationsManager.easeToStub.invocations.count, 1)
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.camera, CameraOptions(zoom: mapboxMap.cameraState.zoom + 1))
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.duration, 0.3)
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.curve, .easeOut)
        XCTAssertNil(cameraAnimationsManager.easeToStub.parameters.first?.completion)
    }

    func testHandlerDoubleTapDoubleTouch() {
        let tapGestureHandler = TapGestureHandler(for: view,
                                                  numberOfTapsRequired: 2,
                                                  numberOfTouchesRequired: 2,
                                                  withDelegate: delegate,
                                                  cameraAnimationsManager: cameraAnimationsManager,
                                                  mapboxMap: mapboxMap)

        guard let tapGestureRecognizer = tapGestureHandler.view?.gestureRecognizers?.first
                                         as? UITapGestureRecognizer else {
            XCTFail("No valid tap gesture recognizer found")
            return
        }

        tapGestureHandler.handleTap(tapGestureRecognizer)
        XCTAssertEqual(cameraAnimationsManager.easeToStub.invocations.count, 1)
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.camera, CameraOptions(zoom: mapboxMap.cameraState.zoom - 1))
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.duration, 0.3)
        XCTAssertEqual(cameraAnimationsManager.easeToStub.parameters.first?.curve, .easeOut)
        XCTAssertNil(cameraAnimationsManager.easeToStub.parameters.first?.completion)
    }
}
