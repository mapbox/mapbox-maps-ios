import XCTest
@testable import MapboxMaps

final class AnyTouchGestureHandlerTests: XCTestCase {

    var gestureRecognizer: MockGestureRecognizer!
    var gestureHandler: AnyTouchGestureHandler!
    var cameraAnimationsManager: MockCameraAnimationsManager!

    override func setUp() {
        super.setUp()
        gestureRecognizer = MockGestureRecognizer()
        cameraAnimationsManager = MockCameraAnimationsManager()
        gestureHandler = AnyTouchGestureHandler(
            gestureRecognizer: gestureRecognizer,
            cameraAnimationsManager: cameraAnimationsManager)
    }

    override func tearDown() {
        gestureHandler = nil
        gestureRecognizer = nil
        super.tearDown()
    }

    func testGestureBegan() {
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        gestureRecognizer.sendActions()

        XCTAssertEqual(cameraAnimationsManager.cancelAnimationsStub.invocations.count, 1)
    }

    func testGestureEnded() {
        gestureRecognizer.getStateStub.defaultReturnValue = .ended
        gestureRecognizer.sendActions()

        XCTAssertEqual(cameraAnimationsManager.cancelAnimationsStub.invocations.count, 0)
    }

    func testGestureCancelled() {
        gestureRecognizer.getStateStub.defaultReturnValue = .cancelled
        gestureRecognizer.sendActions()

        XCTAssertEqual(cameraAnimationsManager.cancelAnimationsStub.invocations.count, 0)
    }

    func testSimultaneousHandling() {
        let result = gestureHandler.gestureRecognizer(
            gestureRecognizer,
            shouldRecognizeSimultaneouslyWith: MockGestureRecognizer())
        XCTAssertEqual(result, true)
    }
}
