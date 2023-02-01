import XCTest
@testable import MapboxMaps

final class AnyTouchGestureHandlerTests: XCTestCase {

    var gestureRecognizer: MockGestureRecognizer!
    var cameraAnimatorsRunnerEnablable: MockMutableEnablable!
    var gestureHandler: AnyTouchGestureHandler!

    override func setUp() {
        super.setUp()
        gestureRecognizer = MockGestureRecognizer()
        cameraAnimatorsRunnerEnablable = MockMutableEnablable()
        gestureHandler = AnyTouchGestureHandler(
            gestureRecognizer: gestureRecognizer,
            cameraAnimatorsRunnerEnablable: cameraAnimatorsRunnerEnablable)
    }

    override func tearDown() {
        gestureHandler = nil
        cameraAnimatorsRunnerEnablable = nil
        gestureRecognizer = nil
        super.tearDown()
    }

    func testGestureBegan() {
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        gestureRecognizer.sendActions()

        XCTAssertEqual(cameraAnimatorsRunnerEnablable.$isEnabled.setStub.invocations.map(\.parameters), [false])
    }

    func testGestureEnded() {
        gestureRecognizer.getStateStub.defaultReturnValue = .ended
        gestureRecognizer.sendActions()

        XCTAssertEqual(cameraAnimatorsRunnerEnablable.$isEnabled.setStub.invocations.map(\.parameters), [true])
    }

    func testGestureCancelled() {
        gestureRecognizer.getStateStub.defaultReturnValue = .cancelled
        gestureRecognizer.sendActions()

        XCTAssertEqual(cameraAnimatorsRunnerEnablable.$isEnabled.setStub.invocations.map(\.parameters), [true])
    }
}
