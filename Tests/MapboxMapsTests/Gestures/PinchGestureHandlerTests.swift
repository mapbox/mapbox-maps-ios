import XCTest
@testable import MapboxMaps

final class PinchGestureHandlerTests: XCTestCase {

    var view: UIView!
    // swiftlint:disable weak_delegate
    var delegate: GestureHandlerDelegateMock!
    var mapboxMap: MockMapboxMap!

    override func setUp() {
        super.setUp()
        view = UIView()
        delegate = GestureHandlerDelegateMock()
        mapboxMap = MockMapboxMap()
    }

    override func tearDown() {
        mapboxMap = nil
        delegate = nil
        view = nil
        super.tearDown()
    }

    func testInit() {
        let pinchGestureHandler = PinchGestureHandler(for: view, withDelegate: delegate, mapboxMap: mapboxMap)
        XCTAssertTrue(pinchGestureHandler.gestureRecognizer is UIPinchGestureRecognizer)
    }

    func testPinchBegan() {
        let pinchGestureHandler = PinchGestureHandler(for: view, withDelegate: delegate, mapboxMap: mapboxMap)
        let pinchGestureRecognizerMock = UIPinchGestureRecognizerMock()
        pinchGestureHandler.handlePinch(pinchGestureRecognizerMock)

        XCTAssertTrue(delegate.cancelTransitionsCalled,
                      "Cancel Transitions was not called before commencing gesture processing")
        XCTAssertTrue(delegate.gestureBeganMethod.wasCalled,
                      "Gesture Supportable view should be notified when gesture begins")
    }

    func testPinchChanged() {
        let pinchGestureHandler = PinchGestureHandler(for: view, withDelegate: delegate, mapboxMap: mapboxMap)
        let pinchGestureRecognizer = UIPinchGestureRecognizerMock()
        let initialCameraState = CameraState.random()
        let initialPinchCenterPoint = CGPoint(x: 0.0, y: 0.0)
        let changedPinchCenterPoint = CGPoint(x: 1.0, y: 1.0)
        mapboxMap.cameraState = initialCameraState
        mapboxMap.dragCameraOptionsStub.defaultReturnValue = CameraOptions(
            center: .random(),
            zoom: .random(in: 0...20))

        // set up internal state by calling handlePinch in the .began state
        pinchGestureRecognizer.mockState = .began
        pinchGestureRecognizer.mockScale = 2.0
        pinchGestureRecognizer.mockLocationInView = initialPinchCenterPoint
        pinchGestureRecognizer.mockNumberOfTouches = 2
        pinchGestureHandler.handlePinch(pinchGestureRecognizer)
        // reset the delegate stub so we can verify
        // that it's called when state is .changed
        delegate.cancelTransitionsCalled = false
        pinchGestureRecognizer.mockState = .changed
        pinchGestureRecognizer.mockLocationInView = changedPinchCenterPoint

        pinchGestureHandler.handlePinch(pinchGestureRecognizer)

        XCTAssertTrue(delegate.cancelTransitionsCalled,
                      "Cancel Transitions was not called before commencing gesture processing")
        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 3)
        guard mapboxMap.setCameraStub.invocations.count == 3 else {
            return
        }
        XCTAssertEqual(mapboxMap.dragStartStub.invocations.count, 1)
        XCTAssertEqual(mapboxMap.dragCameraOptionsStub.invocations.count, 1)
        XCTAssertEqual(mapboxMap.dragEndStub.invocations.count, 1)

        XCTAssertEqual(
            mapboxMap.setCameraStub.parameters[0],
            CameraOptions(
                center: initialCameraState.center,
                padding: initialCameraState.padding,
                zoom: initialCameraState.zoom))

        XCTAssertEqual(
            mapboxMap.dragStartStub.parameters.first,
            initialPinchCenterPoint)

        XCTAssertEqual(
            mapboxMap.dragCameraOptionsStub.parameters.first,
            .init(from: initialPinchCenterPoint, to: changedPinchCenterPoint))

        XCTAssertEqual(
            mapboxMap.setCameraStub.parameters[1],
            mapboxMap.dragCameraOptionsStub.returnedValues.first)

        XCTAssertEqual(
            mapboxMap.setCameraStub.parameters[2],
            CameraOptions(
                anchor: changedPinchCenterPoint,
                zoom: mapboxMap.cameraState.zoom + log2(pinchGestureRecognizer.mockScale)))
    }

    func testPinchEnded() {
        let pinchGestureHandler = PinchGestureHandler(for: view, withDelegate: delegate, mapboxMap: mapboxMap)

        let pinchGestureRecognizerMock = UIPinchGestureRecognizerMock()
        pinchGestureRecognizerMock.mockState = .ended

        pinchGestureHandler.handlePinch(pinchGestureRecognizerMock)

        XCTAssertTrue(delegate.cancelTransitionsCalled,
                      "Cancel Transitions was not called before commencing gesture processing")

        XCTAssertEqual(delegate.pinchEndedStub.invocations.count,
                       1,
                      "View was not informed that gesture was ended")
    }
}

private class UIPinchGestureRecognizerMock: UIPinchGestureRecognizer {

    var mockState: UIGestureRecognizer.State = .began
    var mockScale: CGFloat = 2.0
    var mockCenter: CGPoint = .zero
    var mockLocationInView: CGPoint = .zero
    var mockNumberOfTouches: Int = 1

    override var state: UIGestureRecognizer.State {
        get {
            return mockState
        }
        set {
            fatalError("unimplemented")
        }
    }

    override var scale: CGFloat {
        get {
            return mockScale
        }
        set {
            fatalError("unimplemented")
        }
    }

    override var numberOfTouches: Int {
        return mockNumberOfTouches
    }

    override func location(in view: UIView?) -> CGPoint {
        return mockLocationInView
    }
}
