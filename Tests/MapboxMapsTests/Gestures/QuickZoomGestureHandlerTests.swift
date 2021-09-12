import XCTest
@testable import MapboxMaps

final class QuickZoomGestureHandlerTest: XCTestCase {
    var view: UIView!
    var mapboxMap: MockMapboxMap!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var quickZoomHandler: QuickZoomGestureHandler!
    // swiftlint:disable weak_delegate
    var delegate: MockGestureManagerDelegate!

    override func setUp() {
        super.setUp()
        view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        mapboxMap = MockMapboxMap()
        cameraAnimationsManager = MockCameraAnimationsManager()
        quickZoomHandler = QuickZoomGestureHandler(for: view, mapboxMap: mapboxMap, cameraAnimationsManager: cameraAnimationsManager)
        delegate = MockGestureManagerDelegate()
        quickZoomHandler.delegate = delegate
    }

    override func tearDown() {
        delegate = nil
        quickZoomHandler = nil
        cameraAnimationsManager = nil
        mapboxMap = nil
        view = nil
        super.tearDown()
    }

    func testQuickZoomSetUp() {
        XCTAssert(quickZoomHandler.gestureRecognizer is UILongPressGestureRecognizer)
        guard let gestureRecognizer = quickZoomHandler.gestureRecognizer as? UILongPressGestureRecognizer else {
            return
        }
        XCTAssertEqual(gestureRecognizer.numberOfTapsRequired, 1)
        XCTAssertEqual(gestureRecognizer.minimumPressDuration, 0)
        XCTAssertTrue(view.gestureRecognizers?.contains(gestureRecognizer) == true)
    }

    func testWhenGestureBegins_InformsDelegateThatAQuickZoomGestureBegan() {
        let mockGestureRecognizer = MockLongPressGestureRecognizer()
        mockGestureRecognizer.mockState = .began

        quickZoomHandler.handleQuickZoom(mockGestureRecognizer)

        XCTAssertEqual(delegate.gestureBeganStub.parameters, [.quickZoom])
    }

    func testWhenGestureValueChanges_ProvidesTheNewZoomScaleAndAnchorToTheDelegate() {
        let initialZoom = CGFloat.random(in: 0...15)
        let mockGestureRecognizer = MockLongPressGestureRecognizer()

        // Send the began event
        mockGestureRecognizer.mockState = .began
        mockGestureRecognizer.locationStub.defaultReturnValue.y = 100
        mapboxMap.cameraState.zoom = initialZoom
        quickZoomHandler.handleQuickZoom(mockGestureRecognizer)

        // Send a changed event that should correspond to zooming in by 1 level
        mockGestureRecognizer.mockState = .changed
        mockGestureRecognizer.locationStub.defaultReturnValue.y = 175
        quickZoomHandler.handleQuickZoom(mockGestureRecognizer)

        XCTAssertEqual(
            mapboxMap.setCameraStub.parameters,
            [CameraOptions(
                anchor: CGPoint(x: view.bounds.midX, y: view.bounds.midY),
                zoom: initialZoom + 1)])
    }
}

private class MockLongPressGestureRecognizer: UILongPressGestureRecognizer {
    var mockState = UIGestureRecognizer.State.began
    override var state: UIGestureRecognizer.State {
        get {
            mockState
        }
        set {
            mockState = newValue
        }
    }

    var locationStub = Stub<UIView?, CGPoint>(defaultReturnValue: .zero)
    override func location(in view: UIView?) -> CGPoint {
        locationStub.call(with: view)
    }
}
