import XCTest
@testable import MapboxMaps

//swiftlint:disable explicit_acl explicit_top_level_acl
final class QuickZoomGestureHandlerTest: XCTestCase {
    var view: UIView!
    // swiftlint:disable weak_delegate
    var delegate: GestureHandlerDelegateMock!
    var quickZoomHandler: QuickZoomGestureHandler!

    override func setUp() {
        view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        delegate = GestureHandlerDelegateMock()
        quickZoomHandler = QuickZoomGestureHandler(for: view, withDelegate: delegate)
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

        XCTAssertTrue(delegate.gestureBeganMethod.wasCalled)
        XCTAssertEqual(delegate.gestureBeganMethod.type, GestureType.quickZoom)
    }

    func testWhenGestureValueChanges_ProvidesTheNewZoomScaleAndAnchorToTheDelegate() {
        let initialZoom = CGFloat.random(in: 0...24.5)
        let mockGestureRecognizer = MockLongPressGestureRecognizer()

        // Send the began event
        mockGestureRecognizer.mockState = .began
        mockGestureRecognizer.locationStub.defaultReturnValue.y = 100
        delegate.scaleForZoomStub.defaultReturnValue = initialZoom
        quickZoomHandler.handleQuickZoom(mockGestureRecognizer)

        // Send a changed event that should correspond to zooming in by 1 level
        mockGestureRecognizer.mockState = .changed
        mockGestureRecognizer.locationStub.defaultReturnValue.y = 175
        quickZoomHandler.handleQuickZoom(mockGestureRecognizer)

        XCTAssertEqual(delegate.quickZoomChangedStub.invocations.count, 1)
        XCTAssertEqual(delegate.quickZoomChangedStub.parameters.first?.newScale, initialZoom + 1)
        XCTAssertEqual(delegate.quickZoomChangedStub.parameters.first?.anchor,
                       CGPoint(x: view.bounds.midX, y: view.bounds.midY))
    }

    func testQuickZoomEnded_InformsTheDelegate() {
        let quickZoom = MockLongPressGestureRecognizer()
        quickZoom.mockState = .ended
        quickZoomHandler.handleQuickZoom(quickZoom)

        XCTAssertEqual(delegate.quickZoomEndedStub.invocations.count, 1)
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
