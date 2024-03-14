import XCTest
@testable import MapboxMaps

final class SingleTapGestureHandlerTests: XCTestCase {
    var gestureRecognizer: MockTapGestureRecognizer!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var gestureHandler: SingleTapGestureHandler!
    var delegate: MockGestureHandlerDelegate!
    var view: UIView!
    let interruptingRecognizers = UIGestureRecognizer.interruptingRecognizers([.pan, .longPress, .swipe, .screenEdge, .rotation])

    override func setUp() {
        super.setUp()
        view = UIView()
        gestureRecognizer = MockTapGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        cameraAnimationsManager = MockCameraAnimationsManager()
        gestureHandler = SingleTapGestureHandler(gestureRecognizer: gestureRecognizer, cameraAnimationsManager: cameraAnimationsManager)
        delegate = MockGestureHandlerDelegate()
        gestureHandler.delegate = delegate
    }

    override func tearDown() {
        delegate = nil
        gestureHandler = nil
        cameraAnimationsManager = nil
        gestureRecognizer = nil
        view = nil
        interruptingRecognizers.forEach { $0.view?.removeGestureRecognizer($0) }
        super.tearDown()
    }

    func testInitialization() {
        XCTAssertTrue(gestureRecognizer === gestureHandler.gestureRecognizer)
        XCTAssertEqual(gestureRecognizer.numberOfTapsRequired, 1)
        XCTAssertEqual(gestureRecognizer.numberOfTouchesRequired, 1)
    }

    func testHandler() {
        gestureRecognizer.getStateStub.defaultReturnValue = .recognized
        gestureRecognizer.sendActions()

        XCTAssertEqual(cameraAnimationsManager.cancelAnimationsStub.invocations.count, 1)
        XCTAssertEqual(delegate.gestureBeganStub.invocations.map(\.parameters), [.singleTap])
        XCTAssertEqual(delegate.gestureEndedStub.invocations.count, 1)
        XCTAssertEqual(delegate.gestureEndedStub.invocations.first?.parameters.gestureType, .singleTap)
        XCTAssertEqual(delegate.gestureEndedStub.invocations.first?.parameters.willAnimate, false)
    }

    func testShouldNotRecognizeSimultaneouslyTap() {
        let tapRecognizer = UITapGestureRecognizer()
        view.addGestureRecognizer(tapRecognizer)

        gestureHandler.assertRecognizedSimultaneously(gestureRecognizer, with: [tapRecognizer])
    }

    func testShouldNotRecognizeSimultaneouslyWithRecognizerOtherThanTap() {
        interruptingRecognizers.forEach(view.addGestureRecognizer)

        gestureHandler.assertNotRecognizedSimultaneously(gestureRecognizer, with: interruptingRecognizers)
    }

    func testShouldRecognizeSimultaneouslyWithAnyRecognizerAttachedToDifferentView() {
        gestureHandler.assertRecognizedSimultaneously(gestureRecognizer, with: interruptingRecognizers)
    }

    func testShouldNotReceiveTouchTargetingDifferentView() {
        let touch = MockUITouch(view: UIView())

        let isHandled = gestureHandler.gestureRecognizer(
            gestureRecognizer,
            shouldReceive: touch
        )

        XCTAssertFalse(isHandled)
    }

    func testShouldReceiveTouchTargetingSameView() {
        let touch = MockUITouch(view: gestureRecognizer.view)

        let isHandled = gestureHandler.gestureRecognizer(
            gestureRecognizer,
            shouldReceive: touch
        )

        XCTAssertTrue(isHandled)
    }
}

private final class MockUITouch: UITouch {
    override var view: UIView { _view }
    private let _view: UIView

    init(view: UIView) {
        self._view = view
    }
}
