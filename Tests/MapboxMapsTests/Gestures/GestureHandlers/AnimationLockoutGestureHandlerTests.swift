import XCTest
@testable import MapboxMaps

final class AnimationLockoutGestureHandlerTests: XCTestCase {

    var gestureRecognizer: MockGestureRecognizer!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var gestureHandler: AnimationLockoutGestureHandler!

    override func setUp() {
        super.setUp()
        gestureRecognizer = MockGestureRecognizer()
        cameraAnimationsManager = MockCameraAnimationsManager()
        gestureHandler = AnimationLockoutGestureHandler(
            gestureRecognizer: gestureRecognizer,
            cameraAnimationsManager: cameraAnimationsManager)
    }

    override func tearDown() {
        gestureHandler = nil
        cameraAnimationsManager = nil
        gestureRecognizer = nil
        super.tearDown()
    }

    func testInitialization() {
        XCTAssertFalse(gestureRecognizer.cancelsTouchesInView)
    }

    func testGestureBegan() {
        cameraAnimationsManager.animationsEnabled = true

        gestureRecognizer.getStateStub.defaultReturnValue = .began
        gestureRecognizer.sendActions()

        XCTAssertFalse(cameraAnimationsManager.animationsEnabled)
    }

    func testGestureEnded() {
        cameraAnimationsManager.animationsEnabled = false

        gestureRecognizer.getStateStub.defaultReturnValue = .ended
        gestureRecognizer.sendActions()

        XCTAssertTrue(cameraAnimationsManager.animationsEnabled)
    }

    func testGestureCancelled() {
        cameraAnimationsManager.animationsEnabled = false

        gestureRecognizer.getStateStub.defaultReturnValue = .cancelled
        gestureRecognizer.sendActions()

        XCTAssertTrue(cameraAnimationsManager.animationsEnabled)
    }
}
