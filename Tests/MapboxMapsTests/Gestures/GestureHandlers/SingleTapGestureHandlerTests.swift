import XCTest
@testable import MapboxMaps

final class SingleTapGestureHandlerTests: XCTestCase {

    var gestureRecognizer: MockTapGestureRecognizer!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var gestureHandler: SingleTapGestureHandler!
    // swiftlint:disable:next weak_delegate
    var delegate: MockGestureHandlerDelegate!

    override func setUp() {
        super.setUp()
        gestureRecognizer = MockTapGestureRecognizer()
        cameraAnimationsManager = MockCameraAnimationsManager()
        gestureHandler = SingleTapGestureHandler(
            gestureRecognizer: gestureRecognizer,
            cameraAnimationsManager: cameraAnimationsManager)
        delegate = MockGestureHandlerDelegate()
        gestureHandler.delegate = delegate
    }

    override func tearDown() {
        delegate = nil
        gestureHandler = nil
        cameraAnimationsManager = nil
        gestureRecognizer = nil
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

    func testSingleTapRecognizesSimultaneouslyWithTapGesture() {
        let shouldRecognizeSimultaneously = gestureHandler.gestureRecognizer(
            gestureRecognizer,
            shouldRecognizeSimultaneouslyWith: UITapGestureRecognizer()
        )

        XCTAssertTrue(shouldRecognizeSimultaneously)
    }

    func testSingleTapShouldNotRecognizeSimultaneouslyWithNonTapGesture() {
        let recognizers = [UIPanGestureRecognizer(), UILongPressGestureRecognizer(), UISwipeGestureRecognizer(), UIScreenEdgePanGestureRecognizer(), UIPinchGestureRecognizer()]

        for recognizer in recognizers {
            let shouldRecognizeSimultaneously = gestureHandler.gestureRecognizer(
                gestureRecognizer,
                shouldRecognizeSimultaneouslyWith: recognizer
            )

            XCTAssertFalse(shouldRecognizeSimultaneously)
        }
    }
}
