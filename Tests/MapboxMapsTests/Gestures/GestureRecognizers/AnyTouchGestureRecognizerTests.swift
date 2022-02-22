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
        XCTAssertFalse(gestureRecognizer.delaysTouchesBegan)
        XCTAssertFalse(gestureRecognizer.delaysTouchesEnded)
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
        assertMethodCall(timerProvider.makeScheduledTimerStub)
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
        assertMethodCall(timerProvider.makeScheduledTimerStub)

        // touch 0 is cancelled
        gestureRecognizer.touchesCancelled([touches[0]], with: event)

        // no additional timer is created
        assertMethodCall(timerProvider.makeScheduledTimerStub)

        // touch 1 ends
        gestureRecognizer.touchesEnded([touches[1]], with: event)

        // no additional timer is created
        assertMethodCall(timerProvider.makeScheduledTimerStub)
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
        assertMethodCall(timerProvider.makeScheduledTimerStub)
        let makeTimerInvocation = try XCTUnwrap(timerProvider.makeScheduledTimerStub.invocations.first)
        XCTAssertEqual(makeTimerInvocation.parameters.timeInterval, minimumPressDuration)
        XCTAssertFalse(makeTimerInvocation.parameters.repeats)

        // the state hasn't yet changed
        XCTAssertEqual(gestureRecognizer.state, .possible)

        // touch ends
        gestureRecognizer.touchesEnded([touch], with: event)

        // the timer is invalidated and the state does not change
        let timer = try XCTUnwrap(makeTimerInvocation.returnValue as? MockTimer)
        assertMethodCall(timer.invalidateStub)
        XCTAssertEqual(gestureRecognizer.state, .possible)
    }

    func testTouchHandlingWithChangedTouches() throws {
        let touch = UITouch()
        let event = UIEvent()

        // touch 0 begins
        gestureRecognizer.touchesBegan([touch], with: event)

        // the timer fires
        let makeTimerInvocation = try XCTUnwrap(timerProvider.makeScheduledTimerStub.invocations.first)
        makeTimerInvocation.parameters.block(makeTimerInvocation.returnValue)

        // the state changes
        XCTAssertEqual(gestureRecognizer.state, .began)

        // the state is updated to .changed (UIKit does this automatically,
        // but for testing purposes, we'll do it manually
        gestureRecognizer.state = .changed

        // touch 0 ends
        gestureRecognizer.touchesEnded([touch], with: event)

        XCTAssertEqual(gestureRecognizer.state, .ended)
    }
}
