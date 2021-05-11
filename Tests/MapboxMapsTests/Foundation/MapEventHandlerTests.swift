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

    func testRetainCycle() {

        class StrongHandlerContainer {
            var handler: MapEventHandler?
        }

        weak var cancelable: Cancelable?
        weak var weakContainer: StrongHandlerContainer?

        do {
            let observable = MockObservable()
            var called = 0

            let container = StrongHandlerContainer()


            container.handler = MapEventHandler(for: ["event"],
                                                observable: observable) { _ in
                called += 1
                // Force a retain cycle
                dump(container)
                return false
            }

            weakContainer = container
            cancelable = container.handler

            container.handler?.notify(for: Event(type: "event", data: "ignore-me"))
            container.handler?.notify(for: Event(type: "event", data: "ignore-me"))

            // Handler should only be called for first event
            XCTAssert(called == 2)
        }
        XCTAssertNotNil(cancelable)
        XCTAssertNotNil(weakContainer)

        // Cancel breaks the retain cycle
        cancelable?.cancel()

        XCTAssertNil(cancelable)
        XCTAssertNil(weakContainer)
    }

    func testWeakContainer() {

        class WeakHandlerContainer {
            weak var handler: MapEventHandler?

            deinit {
                handler?.cancel()
            }
        }

        weak var cancelable: Cancelable?
        weak var weakContainer: WeakHandlerContainer?

        do {
            let observable = MockObservable()
            var called = 0

            let container = WeakHandlerContainer()

            let handler = MapEventHandler(for: ["event"],
                                                observable: observable) { _ in
                called += 1
                return false
            }

            container.handler = handler
            cancelable = handler

            weakContainer = container

            container.handler?.notify(for: Event(type: "event", data: "ignore-me"))
            container.handler?.notify(for: Event(type: "event", data: "ignore-me"))

            // Handler should only be called for first event
            XCTAssert(called == 2)
        }
        XCTAssertNil(weakContainer)
        XCTAssertNil(cancelable)
    }
}
