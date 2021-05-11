import XCTest
@testable import MapboxMaps

class MockObservable: ObservableProtocol {
    func subscribe(_ observer: Observer, events: [String]) {}
    func unsubscribe(_ observer: Observer, events: [String]) {}
}

final class MapEventHandlerTests: XCTestCase {

    func testDoesNotHandleMismatchedEvent() {
        weak var cancelable: MapEventHandler?

        do {
            let observable = MockObservable()
            let handler = MapEventHandler(for: ["event"],
                                          observable: observable) { _ in
                XCTFail("Should not be called")
                return true
            }
            cancelable = handler

            handler.notify(for: Event(type: "different-event", data: "ignore-me"))
        }

        XCTAssertNotNil(cancelable)
        cancelable?.cancel()
        XCTAssertNil(cancelable)
    }

    func testHandlesMatchingEvent() {
        weak var cancelable: Cancelable?

        do {
            let observable = MockObservable()
            var called = 0
            let handler = MapEventHandler(for: ["event"],
                                          observable: observable) { _ in
                called += 1
                return true
            }
            cancelable = handler

            handler.notify(for: Event(type: "event", data: "ignore-me"))
            handler.notify(for: Event(type: "event", data: "ignore-me"))

            // Handler should only be called for first event
            XCTAssert(called == 1)
        }
        XCTAssertNil(cancelable)
    }

    func testHandlesMultipleEvents() {
        weak var cancelable: Cancelable?

        do {
            let observable = MockObservable()
            var called = 0
            let handler = MapEventHandler(for: ["event"],
                                          observable: observable) { _ in
                called += 1

                // Return false to indicate that this will handle multiple
                // events. If you never return `true` here, then it's your
                // responsibility to call `cancel()` on the handler.
                return false
            }
            cancelable = handler

            handler.notify(for: Event(type: "event", data: "ignore-me"))
            handler.notify(for: Event(type: "event", data: "ignore-me"))

            XCTAssert(called == 2)
        }
        XCTAssertNotNil(cancelable)
        cancelable?.cancel()
        XCTAssertNil(cancelable)
    }
}
