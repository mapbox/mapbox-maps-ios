import XCTest
@testable import MapboxMaps

final class AnyTouchGestureRecognizerTests: XCTestCase {

    var minimumPressDuration: TimeInterval!
    var timerProvider: MockTimerProvider!
    var gestureRecognizer: AnyTouchGestureRecognizer!

    override func setUp() {
        super.setUp()
        minimumPressDuration = .random(in: 0...10)
        timerProvider = MockTimerProvider()
        gestureRecognizer = AnyTouchGestureRecognizer(
            minimumPressDuration: minimumPressDuration,
            timerProvider: timerProvider)
    }

    override func tearDown() {
        gestureRecognizer = nil
        timerProvider = nil
        minimumPressDuration = nil
        super.tearDown()
    }

    func testInitialization() {
        XCTAssertFalse(gestureRecognizer.cancelsTouchesInView)
    }

    func testCanBePreventedBy() {
        XCTAssertFalse(gestureRecognizer.canBePrevented(by: MockGestureRecognizer()))
    }

    func testCanPrevent() {
        XCTAssertFalse(gestureRecognizer.canPrevent(MockGestureRecognizer()))
    }

    func testTouchHandlingWithSufficientDelay() throws {
        let touches = [UITouch(), UITouch(), UITouch()]
        let event = UIEvent()

        // touch 0 begins
        gestureRecognizer.touchesBegan([touches[0]], with: event)

        // the timer is created
        XCTAssertEqual(timerProvider.makeScheduledTimerStub.invocations.count, 1)
        let makeTimerInvocation = try XCTUnwrap(timerProvider.makeScheduledTimerStub.invocations.first)
        XCTAssertEqual(makeTimerInvocation.parameters.timeInterval, minimumPressDuration)
        XCTAssertFalse(makeTimerInvocation.parameters.repeats)

        // the state hasn't yet changed
        XCTAssertEqual(gestureRecognizer.state, .possible)

        // the timer fires
        makeTimerInvocation.parameters.block(makeTimerInvocation.returnValue)

        // the state changes
        XCTAssertEqual(gestureRecognizer.state, .began)

        // touch 1 begins
        gestureRecognizer.touchesBegan([touches[1]], with: event)

        // no additional timer is created
        XCTAssertEqual(timerProvider.makeScheduledTimerStub.invocations.count, 1)

        // touch 0 is cancelled
        gestureRecognizer.touchesCancelled([touches[0]], with: event)

        // no additional timer is created
        XCTAssertEqual(timerProvider.makeScheduledTimerStub.invocations.count, 1)

        // touch 1 ends
        gestureRecognizer.touchesEnded([touches[1]], with: event)

        // no additional timer is created
        XCTAssertEqual(timerProvider.makeScheduledTimerStub.invocations.count, 1)
        XCTAssertEqual(gestureRecognizer.state, .ended)

        // touch 2 begins
        gestureRecognizer.touchesBegan([touches[2]], with: event)

        // another timer is created
        XCTAssertEqual(timerProvider.makeScheduledTimerStub.invocations.count, 2)
    }

    func testTouchHandlingWithInsufficientDelay() throws {
        let touch = UITouch()
        let event = UIEvent()

        // touch begins
        gestureRecognizer.touchesBegan([touch], with: event)

        // the timer is created
        XCTAssertEqual(timerProvider.makeScheduledTimerStub.invocations.count, 1)
        let makeTimerInvocation = try XCTUnwrap(timerProvider.makeScheduledTimerStub.invocations.first)
        XCTAssertEqual(makeTimerInvocation.parameters.timeInterval, minimumPressDuration)
        XCTAssertFalse(makeTimerInvocation.parameters.repeats)

        // the state hasn't yet changed
        XCTAssertEqual(gestureRecognizer.state, .possible)

        // touch ends
        gestureRecognizer.touchesEnded([touch], with: event)

        // the timer is invalidated and the state does not change
        let timer = try XCTUnwrap(makeTimerInvocation.returnValue as? MockTimer)
        XCTAssertEqual(timer.invalidateStub.invocations.count, 1)
        XCTAssertEqual(gestureRecognizer.state, .possible)
    }
}
