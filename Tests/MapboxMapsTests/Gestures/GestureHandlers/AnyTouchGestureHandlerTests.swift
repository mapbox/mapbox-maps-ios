import XCTest
@testable import MapboxMaps

final class AnyTouchGestureHandlerTests: XCTestCase {

    var gestureRecognizer: MockGestureRecognizer!
    var cameraAnimatorsRunner: MockCameraAnimatorsRunner!
    var gestureHandler: AnyTouchGestureHandler!

    override func setUp() {
        super.setUp()
        gestureRecognizer = MockGestureRecognizer()
        cameraAnimatorsRunner = MockCameraAnimatorsRunner()
        gestureHandler = AnyTouchGestureHandler(
            gestureRecognizer: gestureRecognizer,
            cameraAnimatorsRunner: cameraAnimatorsRunner)
    }

    override func tearDown() {
        gestureHandler = nil
        cameraAnimatorsRunner = nil
        gestureRecognizer = nil
        super.tearDown()
    }

    func testGestureBegan() {
        gestureRecognizer.getStateStub.defaultReturnValue = .began
        gestureRecognizer.sendActions()

        XCTAssertEqual(cameraAnimatorsRunner.$animationsEnabled.setStub.invocations.map(\.parameters), [false])
    }

    func testGestureEnded() {
        gestureRecognizer.getStateStub.defaultReturnValue = .ended
        gestureRecognizer.sendActions()

        XCTAssertEqual(cameraAnimatorsRunner.$animationsEnabled.setStub.invocations.map(\.parameters), [true])
    }

    func testGestureCancelled() {
        gestureRecognizer.getStateStub.defaultReturnValue = .cancelled
        gestureRecognizer.sendActions()

        XCTAssertEqual(cameraAnimatorsRunner.$animationsEnabled.setStub.invocations.map(\.parameters), [true])
    }
}
