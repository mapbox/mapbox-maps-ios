import XCTest
@testable import MapboxMaps

final class QuickZoomGestureHandlerTest: XCTestCase {
    var view: UIView!
    var mapboxMap: MockMapboxMap!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var quickZoomHandler: QuickZoomGestureHandler!
    // swiftlint:disable weak_delegate
    var delegate: MockGestureHandlerDelegate!
    var gestureRecognizer: MockLongPressGestureRecognizer!

    override func setUp() {
        super.setUp()
        view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        mapboxMap = MockMapboxMap()
        cameraAnimationsManager = MockCameraAnimationsManager()
        quickZoomHandler = QuickZoomGestureHandler(view: view, mapboxMap: mapboxMap, cameraAnimationsManager: cameraAnimationsManager)
        delegate = MockGestureHandlerDelegate()
        quickZoomHandler.delegate = delegate
        gestureRecognizer = MockLongPressGestureRecognizer()
        gestureRecognizer.getViewStub.defaultReturnValue = view
    }

    override func tearDown() {
        gestureRecognizer = nil
        delegate = nil
        quickZoomHandler = nil
        cameraAnimationsManager = nil
        mapboxMap = nil
        view = nil
        super.tearDown()
    }

    func testInitialization() {
        XCTAssertEqual(quickZoomHandler.gestureRecognizer.numberOfTapsRequired, 1)
        XCTAssertEqual(quickZoomHandler.gestureRecognizer.minimumPressDuration, 0)
        XCTAssertTrue(view.gestureRecognizers?.last === quickZoomHandler.gestureRecognizer)
    }

    func testGestureBegan() {
        gestureRecognizer.getStateStub.defaultReturnValue = .began

        quickZoomHandler.handleQuickZoom(gestureRecognizer)

        XCTAssertEqual(delegate.gestureBeganStub.parameters, [.quickZoom])
        XCTAssertEqual(cameraAnimationsManager.cancelAnimationsStub.invocations.count, 1)
    }

    func testGestureChanged() {
        let initialZoom = CGFloat.random(in: 0...15)

        // Send the began event
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        gestureRecognizer.locationStub.defaultReturnValue.y = 100
        mapboxMap.cameraState.zoom = initialZoom
        quickZoomHandler.handleQuickZoom(gestureRecognizer)

        // Send a changed event that should correspond to zooming in by 1 level
        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.locationStub.defaultReturnValue.y = 175
        quickZoomHandler.handleQuickZoom(gestureRecognizer)

        XCTAssertEqual(
            mapboxMap.setCameraStub.parameters,
            [CameraOptions(
                anchor: CGPoint(x: view.bounds.midX, y: view.bounds.midY),
                zoom: initialZoom + 1)])
    }
}
