import Foundation
import XCTest
@testable import MapboxMaps

final class ThrottleTests: XCTestCase {

    var observableValue: ObservableValue<Int>!
    var dispatchQueue: MockDispatchQueue!
    var throttle: Throttle<Int>!

    override func setUp() {
        super.setUp()
        observableValue = ObservableValue()
        dispatchQueue = MockDispatchQueue()
        throttle = Throttle(value: observableValue, windowDuration: 1, dispatchQueue: dispatchQueue)
    }

    override func tearDown() {
        observableValue = nil
        dispatchQueue = nil
        throttle = nil
        super.tearDown()
    }

    func testSubscribestoValueChangesDuringInit() {
        // given
        let observableValue = ObservableValue<Int>()
        var observableSubscribed = false
        observableValue.onFirstSubscribe = {
            observableSubscribed = true
        }

        // when
        _ = Throttle(value: observableValue, windowDuration: 1, dispatchQueue: dispatchQueue)

        // then
        XCTAssertTrue(observableSubscribed)
    }

    func testNoThrottlingForTheFirstValueUpdate() {
        // given
        let value = Int.random(in: 0...100)

        // when
        observableValue.notify(with: value)

        // then
        XCTAssertEqual(throttle.value, value)
    }

    func testThrottlingForSecondValueUpdate() throws {
        // given
        let originalValue = Int.random(in: 0...100)
        observableValue.notify(with: originalValue)
        let updatedValue = Int.random(in: 101...1000)

        // when
        observableValue.notify(with: updatedValue)
        XCTAssertEqual(throttle.value, originalValue)

        // then
        XCTAssertEqual(dispatchQueue.asyncAfterItemStub.invocations.count, 1)
        let invocation = try XCTUnwrap(dispatchQueue.asyncAfterItemStub.invocations.first)
        let timeToleranceInNanoseconds = 1_000_000
        XCTAssertTrue(((DispatchTime.now() + 1).rawValue - invocation.parameters.deadline.rawValue) < timeToleranceInNanoseconds)

        invocation.parameters.item.perform()

        XCTAssertEqual(throttle.value, updatedValue)
    }

    func testSubsequentValueUpdatesOverrideScheduledUpdates() throws {
        // given
        observableValue.notify(with: 8) // initial update
        observableValue.notify(with: 9) // scheduled update

        // when
        observableValue.notify(with: 10) // subsequent update

        // then
        XCTAssertEqual(dispatchQueue.asyncAfterItemStub.invocations.count, 1)
        let invocation = try XCTUnwrap(dispatchQueue.asyncAfterItemStub.invocations.first)

        XCTAssertFalse(invocation.parameters.item.isCancelled)

        invocation.parameters.item.perform()

        XCTAssertEqual(throttle.value, 10)
    }

    func testNotifyImmediatelyCancelsUpcomingUpdates() throws {
        // given
        observableValue.notify(with: 8) // initial update
        observableValue.notify(with: 9) // scheduled update

        // when
        throttle.notifyImmediately(with: 10)

        // then
        XCTAssertEqual(dispatchQueue.asyncAfterItemStub.invocations.count, 1)
        let invocation = try XCTUnwrap(dispatchQueue.asyncAfterItemStub.invocations.first)

        XCTAssertTrue(invocation.parameters.item.isCancelled)
        XCTAssertEqual(throttle.value, 10)
    }

    func testFlushNotifiesImmediatelyAboutUpcomingUpdate() throws {
        // given
        observableValue.notify(with: 8) // initial update
        observableValue.notify(with: 9) // scheduled update
        observableValue.notify(with: 10) // scheduled update

        // when
        throttle.flush()

        // then
        XCTAssertEqual(dispatchQueue.asyncAfterItemStub.invocations.count, 1)
        let invocation = try XCTUnwrap(dispatchQueue.asyncAfterItemStub.invocations.first)

        XCTAssertTrue(invocation.parameters.item.isCancelled)
        XCTAssertEqual(throttle.value, 10)
    }

    func testFlushDoesNothingWhenNoUpcomingUpdate() {
        // given
        observableValue.notify(with: 8) // initial update

        // when
        throttle.flush()

        // then
        XCTAssertEqual(dispatchQueue.asyncAfterItemStub.invocations.count, 0)
        XCTAssertEqual(throttle.value, 8)

    }

    func testObserving() throws {
        // given
        var receivedValue: Int?
        _ = throttle.observe { value in
            receivedValue = value
        }

        // when
        throttle.notify(with: 8)

        // then
        XCTAssertEqual(receivedValue, 8)

        // when
        throttle.notify(with: 10)

        // then
        XCTAssertEqual(dispatchQueue.asyncAfterItemStub.invocations.count, 1)
        let invocation = try XCTUnwrap(dispatchQueue.asyncAfterItemStub.invocations.first)

        XCTAssertFalse(invocation.parameters.item.isCancelled)

        invocation.parameters.item.perform()

        XCTAssertEqual(receivedValue, 10)
    }

    func testCancelTokenCancelsObserving() {
        // given
        var receivedValue: Int?
        let cancelToken = throttle.observe { value in
            receivedValue = value
        }
        cancelToken.cancel()

        // when
        throttle.notify(with: 8)

        // then
        XCTAssertEqual(throttle.value, 8)
        XCTAssertNil(receivedValue)
    }

    func testCancelTokenCancelsObservingForScheduledUpdate() throws {
        // given
        throttle.notify(with: 8)
        var receivedValue: Int?
        let cancelToken = throttle.observe { value in
            receivedValue = value
        }
        cancelToken.cancel()

        // when
        throttle.notify(with: 9)

        XCTAssertEqual(dispatchQueue.asyncAfterItemStub.invocations.count, 1)
        let invocation = try XCTUnwrap(dispatchQueue.asyncAfterItemStub.invocations.first)

        XCTAssertFalse(invocation.parameters.item.isCancelled)

        invocation.parameters.item.perform()

        // then
        XCTAssertEqual(throttle.value, 9)
        XCTAssertNil(receivedValue)
    }
}
