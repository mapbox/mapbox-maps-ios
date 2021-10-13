import XCTest
@testable import MapboxMaps

final class QuickZoomGestureHandlerTest: XCTestCase {
    var view: UIView!
    var gestureRecognizer: MockLongPressGestureRecognizer!
    var mapboxMap: MockMapboxMap!
    var quickZoomHandler: QuickZoomGestureHandler!
    // swiftlint:disable weak_delegate
    var delegate: MockGestureHandlerDelegate!

    override func setUp() {
        super.setUp()
        view = UIView()
        gestureRecognizer = MockLongPressGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        mapboxMap = MockMapboxMap()
        quickZoomHandler = QuickZoomGestureHandler(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap)
        delegate = MockGestureHandlerDelegate()
        quickZoomHandler.delegate = delegate
    }

    override func tearDown() {
        delegate = nil
        quickZoomHandler = nil
        mapboxMap = nil
        gestureRecognizer = nil
        view = nil
        super.tearDown()
    }

    func testInitialization() {
        XCTAssertTrue(gestureRecognizer === quickZoomHandler.gestureRecognizer)
        XCTAssertEqual(gestureRecognizer.numberOfTapsRequired, 1)
        XCTAssertEqual(gestureRecognizer.minimumPressDuration, 0)
    }

    func testGestureBegan() {
        gestureRecognizer.getStateStub.defaultReturnValue = .began

        gestureRecognizer.sendActions()

        XCTAssertEqual(delegate.gestureBeganStub.parameters, [.quickZoom])
    }

    func testGestureChanged() throws {
        let initialZoom = CGFloat.random(in: 0...15)

        // Send the began event
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        gestureRecognizer.locationStub.defaultReturnValue.y = 100
        mapboxMap.cameraState.zoom = initialZoom
        gestureRecognizer.sendActions()

        // Send a changed event that should correspond to zooming in by 1 level
        gestureRecognizer.getStateStub.defaultReturnValue = .changed
        gestureRecognizer.locationStub.defaultReturnValue.y = 175
        gestureRecognizer.sendActions()

        let initialLocation = try XCTUnwrap(gestureRecognizer.locationStub.returnedValues.first)

        XCTAssertEqual(
            mapboxMap.setCameraStub.parameters,
            [CameraOptions(
                anchor: initialLocation,
                zoom: initialZoom + 1)])
    }

    func testQuickZoomEnded() throws {
        gestureRecognizer.getStateStub.defaultReturnValue = .ended

        gestureRecognizer.sendActions()

        XCTAssertEqual(delegate.gestureEndedStub.invocations.count, 1)
        XCTAssertEqual(delegate.gestureEndedStub.parameters.first?.gestureType, .quickZoom)

        let willAnimate = try XCTUnwrap(delegate.gestureEndedStub.parameters.first?.willAnimate)
        XCTAssertFalse(willAnimate)
    }

}
