import XCTest
@testable import MapboxMaps

final class MapboxObservableTests: XCTestCase {

    var observable: MockObservable!
    var mapboxObservable: MapboxObservable!
    var observer: MockObserver!
    var events: [String]!
    var handlerStub: Stub<Event, Void>!
    var eventTypes: [MapEvents.EventKind]!

    override func setUp() {
        super.setUp()
        observable = MockObservable()
        mapboxObservable = MapboxObservable(observable: observable)
        observer = MockObserver()
        // prefix generated events with their offset to ensure each one is unique
        events = .random(withMinLength: 1)
            .enumerated()
            .map { $0.offset.description + $0.element }
        handlerStub = Stub()
        eventTypes = .random(withLength: .random(in: 1..<10), generator: { .allCases.randomElement()! })
        eventTypes = Array(Set(eventTypes))
    }

    override func tearDown() {
        eventTypes = nil
        handlerStub = nil
        events = nil
        observer = nil
        mapboxObservable = nil
        observable = nil
        super.tearDown()
    }

    func testSubscribe() throws {
        mapboxObservable.subscribe(observer, events: events)

        // Initial subscribe invokes subscribe only with expected events
        XCTAssertEqual(observable.unsubscribeStub.invocations.count, 0)
        XCTAssertEqual(observable.subscribeStub.invocations.count, 1)
        let subscribeInvocation = try XCTUnwrap(observable.subscribeStub.invocations.first)
        XCTAssertEqual(Set(subscribeInvocation.parameters.events), Set(events))

        // notifying the observer passed to the observable should notify the observer passed to mapboxObservable
        let subscribedObserver = subscribeInvocation.parameters.observer
        let event = Event(type: "", data: 0)
        subscribedObserver.notify(for: event)
        XCTAssertEqual(observer.notifyStub.invocations.count, 1)
        XCTAssertIdentical(observer.notifyStub.invocations.first?.parameters, event)
    }

    func testDuplicateSubscribeIsIgnored() {
        mapboxObservable.subscribe(observer, events: events)
        observable.subscribeStub.reset()

        mapboxObservable.subscribe(observer, events: events)

        XCTAssertEqual(observable.unsubscribeStub.invocations.count, 0)
        XCTAssertEqual(observable.subscribeStub.invocations.count, 0)
    }

    func testSubscribingToAdditionalEvents() throws {
        mapboxObservable.subscribe(observer, events: events)
        let subscribedObserver = try XCTUnwrap(observable.subscribeStub.invocations.first?.parameters.observer)
        observable.subscribeStub.reset()

        // Subsequent subscribe with different parameters results in a new subscription that merges the events
        let newEvents = events!.map { $0 + $0 }
        mapboxObservable.subscribe(observer, events: newEvents)

        XCTAssertEqual(observable.unsubscribeStub.invocations.count, 1)
        XCTAssertIdentical(observable.unsubscribeStub.invocations.first?.parameters, subscribedObserver)
        XCTAssertEqual(observable.subscribeStub.invocations.count, 1)
        let subscribeInvocation2 = try XCTUnwrap(observable.subscribeStub.invocations.first)
        XCTAssertEqual(Set(subscribeInvocation2.parameters.events), Set(events + newEvents))
    }

    func testUnsubscribeFromAllEventsByPassingEmptyArray() throws {
        mapboxObservable.subscribe(observer, events: events)
        let subscribedObserver = try XCTUnwrap(observable.subscribeStub.invocations.first?.parameters.observer)
        observable.subscribeStub.reset()

        mapboxObservable.unsubscribe(observer, events: [])
        XCTAssertEqual(observable.unsubscribeStub.invocations.count, 1)
        XCTAssertIdentical(observable.unsubscribeStub.invocations.first?.parameters, subscribedObserver)
        XCTAssertEqual(observable.subscribeStub.invocations.count, 0)
    }

    func testUnsubscribeFromAllEventsByPassingSameEvents() throws {
        mapboxObservable.subscribe(observer, events: events)
        let subscribedObserver = try XCTUnwrap(observable.subscribeStub.invocations.first?.parameters.observer)
        observable.subscribeStub.reset()

        mapboxObservable.unsubscribe(observer, events: events)
        XCTAssertEqual(observable.unsubscribeStub.invocations.count, 1)
        XCTAssertIdentical(observable.unsubscribeStub.invocations.first?.parameters, subscribedObserver)
        XCTAssertEqual(observable.subscribeStub.invocations.count, 0)
    }

    func testUnsubscribeFromSomeEvents() throws {
        events = .random(withMinLength: 2)
            .enumerated()
            .map { $0.offset.description + $0.element }
        mapboxObservable.subscribe(observer, events: events)
        let subscribedObserver = try XCTUnwrap(observable.subscribeStub.invocations.first?.parameters.observer)
        observable.subscribeStub.reset()

        mapboxObservable.unsubscribe(observer, events: [events.first!])
        XCTAssertEqual(observable.unsubscribeStub.invocations.count, 1)
        XCTAssertIdentical(observable.unsubscribeStub.invocations.first?.parameters, subscribedObserver)
        XCTAssertEqual(observable.subscribeStub.invocations.count, 1)
        let subscribeInvocation = try XCTUnwrap(observable.subscribeStub.invocations.first)
        XCTAssertEqual(Set(subscribeInvocation.parameters.events), Set(events[1..<events.count]))
    }

    func testUnsubscribeWithoutSubscribingIsIgnored() {
        mapboxObservable.unsubscribe(observer, events: .random(withMinLength: 0))

        XCTAssertEqual(observable.unsubscribeStub.invocations.count, 0)
        XCTAssertEqual(observable.subscribeStub.invocations.count, 0)
    }

    func testUnsubscribeFromEventsThatWereNotSubscribedIsIgnored() {
        mapboxObservable.subscribe(observer, events: events)
        observable.subscribeStub.reset()
        let newEvents = events!.map { $0 + $0 }

        mapboxObservable.unsubscribe(observer, events: newEvents)

        XCTAssertEqual(observable.unsubscribeStub.invocations.count, 0)
        XCTAssertEqual(observable.subscribeStub.invocations.count, 0)
    }

    func testUnsubscribeFromSomeEventsThatWereSubscribedAndOthersThatWereNotSubscribed() throws {
        events = .random(withMinLength: 2)
            .enumerated()
            .map { $0.offset.description + $0.element }
        mapboxObservable.subscribe(observer, events: events)
        let subscribedObserver = try XCTUnwrap(observable.subscribeStub.invocations.first?.parameters.observer)
        observable.subscribeStub.reset()
        let newEvents = events!.map { $0 + $0 } + [events.first!]

        mapboxObservable.unsubscribe(observer, events: newEvents)

        XCTAssertEqual(observable.unsubscribeStub.invocations.count, 1)
        XCTAssertIdentical(observable.unsubscribeStub.invocations.first?.parameters, subscribedObserver)
        XCTAssertEqual(observable.subscribeStub.invocations.count, 1)
        let subscribeInvocation = try XCTUnwrap(observable.subscribeStub.invocations.first)
        XCTAssertEqual(Set(subscribeInvocation.parameters.events), Set(events[1..<events.count]))
    }

    func testOnNext() throws {
        _ = mapboxObservable.onNext(eventTypes, handler: handlerStub.call(with:))

        // Initial subscribe invokes subscribe only with expected events
        XCTAssertEqual(observable.unsubscribeStub.invocations.count, 0)
        XCTAssertEqual(observable.subscribeStub.invocations.count, 1)
        let subscribeInvocation = try XCTUnwrap(observable.subscribeStub.invocations.first)
        XCTAssertEqual(Set(subscribeInvocation.parameters.events), Set(eventTypes.map(\.rawValue)))

        // notifying the observer passed to the observable should notify the handler passed to mapboxObservable
        let subscribedObserver = subscribeInvocation.parameters.observer
        let event = Event(type: "", data: 0)
        subscribedObserver.notify(for: event)
        XCTAssertEqual(handlerStub.invocations.count, 1)
        XCTAssertIdentical(handlerStub.invocations.first?.parameters, event)

        // event delivery ends the subscription
        XCTAssertEqual(observable.unsubscribeStub.invocations.count, 1)
        XCTAssertIdentical(observable.unsubscribeStub.invocations.first?.parameters, subscribedObserver)
    }

    func testOnNextCancellation() throws {
        let cancelable = mapboxObservable.onNext(eventTypes, handler: handlerStub.call(with:))
        let subscribedObserver = try XCTUnwrap(observable.subscribeStub.invocations.first?.parameters.observer)

        cancelable.cancel()

        XCTAssertEqual(observable.unsubscribeStub.invocations.count, 1)
        XCTAssertIdentical(observable.unsubscribeStub.invocations.first?.parameters, subscribedObserver)

        // invoking the cancelable again does nothing
        observable.unsubscribeStub.reset()

        cancelable.cancel()

        XCTAssertEqual(observable.unsubscribeStub.invocations.count, 0)
    }

    func testOnNextWithSynchronousInvocation() throws {
        observable.subscribeStub.defaultSideEffect = { invocation in
            invocation.parameters.observer.notify(for: Event(type: "", data: 0))
        }

        let cancelable = mapboxObservable.onNext(eventTypes, handler: handlerStub.call(with:))

        let subscribedObserver = try XCTUnwrap(observable.subscribeStub.invocations.first?.parameters.observer)
        XCTAssertEqual(observable.unsubscribeStub.invocations.count, 1)
        XCTAssertIdentical(observable.unsubscribeStub.invocations.first?.parameters, subscribedObserver)

        // invoking the cancelable does not attempt to unsubscribe a second time
        observable.unsubscribeStub.reset()

        cancelable.cancel()

        XCTAssertEqual(observable.unsubscribeStub.invocations.count, 0)
    }

    func testOnEvery() throws {
        let cancelable = mapboxObservable.onEvery(eventTypes, handler: handlerStub.call(with:))

        // Initial subscribe invokes subscribe only with expected events
        XCTAssertEqual(observable.unsubscribeStub.invocations.count, 0)
        XCTAssertEqual(observable.subscribeStub.invocations.count, 1)
        let subscribeInvocation = try XCTUnwrap(observable.subscribeStub.invocations.first)
        XCTAssertEqual(Set(subscribeInvocation.parameters.events), Set(eventTypes.map(\.rawValue)))

        // notifying the observer passed to the observable should notify the handler passed to mapboxObservable
        let subscribedObserver = subscribeInvocation.parameters.observer
        let event = Event(type: "", data: 0)
        subscribedObserver.notify(for: event)
        XCTAssertEqual(handlerStub.invocations.count, 1)
        XCTAssertIdentical(handlerStub.invocations.first?.parameters, event)

        // event delivery does not end the subscription
        XCTAssertEqual(observable.unsubscribeStub.invocations.count, 0)

        // invoking the cancelable ends the subscription
        cancelable.cancel()

        XCTAssertEqual(observable.unsubscribeStub.invocations.count, 1)
        XCTAssertIdentical(observable.unsubscribeStub.invocations.first?.parameters, subscribedObserver)

        // invoking the cancelable again does nothing
        observable.unsubscribeStub.reset()

        cancelable.cancel()

        XCTAssertEqual(observable.unsubscribeStub.invocations.count, 0)
    }

    func testUnsubscribesOnDeinit() {
        let otherObserver = MockObserver()
        let subscribedObservers: [Observer]

        do {
            let mapboxObservable = MapboxObservable(observable: observable)
            mapboxObservable.subscribe(observer, events: events)
            mapboxObservable.subscribe(otherObserver, events: events)
            _ = mapboxObservable.onNext(eventTypes, handler: handlerStub.call(with:))
            _ = mapboxObservable.onEvery(eventTypes, handler: handlerStub.call(with:))

            XCTAssertEqual(observable.subscribeStub.invocations.count, 4)
            subscribedObservers = observable.subscribeStub.invocations.map(\.parameters.observer)
        }

        XCTAssertEqual(observable.unsubscribeStub.invocations.count, 4)
        let unsubscribedObservers = observable.unsubscribeStub.invocations.map(\.parameters)

        XCTAssertEqual(
            Set(subscribedObservers.map(ObjectIdentifier.init)),
            Set(unsubscribedObservers.map(ObjectIdentifier.init)))
    }
}
