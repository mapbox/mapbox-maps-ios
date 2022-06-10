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

    func notify(with event: Event) {
        let observers = observable.subscribeStub.invocations.map(\.parameters.observer)
        for observer in observers {
            observer.notify(for: event)
        }
    }

    func testSubscribe() throws {
        mapboxObservable.subscribe(observer, events: events)

        // Initial subscribe invokes subscribe only with expected events
        XCTAssertEqual(observable.unsubscribeStub.invocations.count, 0)
        XCTAssertEqual(observable.subscribeStub.invocations.count, 1)
        let subscribeInvocation = try XCTUnwrap(observable.subscribeStub.invocations.first)
        XCTAssertEqual(Set(subscribeInvocation.parameters.events), Set(events))

        // notifying the observer passed to the observable should notify the observer passed to mapboxObservable
        let event = Event(type: "", data: 0)
        notify(with: event)
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

    @available(*, deprecated)
    func testOnNext() throws {
        _ = mapboxObservable.onNext(eventTypes, handler: handlerStub.call(with:))

        // Initial subscribe invokes subscribe only with expected events
        XCTAssertEqual(observable.unsubscribeStub.invocations.count, 0)
        XCTAssertEqual(observable.subscribeStub.invocations.count, 1)
        let subscribeInvocation = try XCTUnwrap(observable.subscribeStub.invocations.first)
        XCTAssertEqual(Set(subscribeInvocation.parameters.events), Set(eventTypes.map(\.rawValue)))

        // notifying the observer passed to the observable should notify the handler passed to mapboxObservable
        let event = Event(type: "", data: 0)
        notify(with: event)
        XCTAssertEqual(handlerStub.invocations.count, 1)
        XCTAssertIdentical(handlerStub.invocations.first?.parameters, event)

        // event delivery ends the subscription
        let subscribedObserver = subscribeInvocation.parameters.observer
        XCTAssertEqual(observable.unsubscribeStub.invocations.count, 1)
        XCTAssertIdentical(observable.unsubscribeStub.invocations.first?.parameters, subscribedObserver)
    }

    func testOnTypedNext() throws {
        func verifyInvocation<Payload>(
            eventType: MapEvents.Event<Payload>,
            handlerStub: Stub<MapEvent<Payload>, Void> = .init()
        ) throws {
            _ = mapboxObservable.onNext(event: eventType, handler: handlerStub.call(with:))

            // Initial subscribe invokes subscribe only with expected events
            XCTAssertEqual(observable.unsubscribeStub.invocations.count, 0)
            XCTAssertEqual(observable.subscribeStub.invocations.count, 1)
            let subscribeInvocation = try XCTUnwrap(observable.subscribeStub.invocations.first)
            XCTAssertEqual(subscribeInvocation.parameters.events, [eventType.name])

            // notifying the observer passed to the observable should notify the handler passed to mapboxObservable
            let event = Event(type: "", data: 0)
            notify(with: event)
            XCTAssertEqual(handlerStub.invocations.count, 1)
            XCTAssertIdentical(handlerStub.invocations.first?.parameters.event, event)

            // event delivery ends the subscription
            let subscribedObserver = subscribeInvocation.parameters.observer
            XCTAssertEqual(observable.unsubscribeStub.invocations.count, 1)
            XCTAssertIdentical(observable.unsubscribeStub.invocations.first?.parameters, subscribedObserver)
        }

        // swiftlint:disable opening_brace
        let eventInvocations = [
            { try verifyInvocation(eventType: .mapLoaded) },
            { try verifyInvocation(eventType: .mapLoadingError) },
            { try verifyInvocation(eventType: .mapIdle) },
            { try verifyInvocation(eventType: .styleDataLoaded) },
            { try verifyInvocation(eventType: .styleLoaded) },
            { try verifyInvocation(eventType: .styleImageMissing) },
            { try verifyInvocation(eventType: .styleImageRemoveUnused) },
            { try verifyInvocation(eventType: .sourceDataLoaded) },
            { try verifyInvocation(eventType: .sourceAdded) },
            { try verifyInvocation(eventType: .sourceRemoved) },
            { try verifyInvocation(eventType: .renderFrameStarted) },
            { try verifyInvocation(eventType: .renderFrameFinished) },
            { try verifyInvocation(eventType: .cameraChanged) },
            { try verifyInvocation(eventType: .resourceRequest) }
        ]
        // swiftlint:enable opening_brace

        try eventInvocations.randomElement()!()
    }

    @available(*, deprecated)
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

    func testOnTypedNextCancellation() throws {
        func verifyInvocation<Payload>(
            eventType: MapEvents.Event<Payload>,
            handlerStub: Stub<MapEvent<Payload>, Void> = .init()
        ) throws {
            let cancelable = mapboxObservable.onNext(event: eventType, handler: handlerStub.call(with:))
            let subscribedObserver = try XCTUnwrap(observable.subscribeStub.invocations.first?.parameters.observer)

            cancelable.cancel()

            XCTAssertEqual(observable.unsubscribeStub.invocations.count, 1)
            XCTAssertIdentical(observable.unsubscribeStub.invocations.first?.parameters, subscribedObserver)

            // invoking the cancelable again does nothing
            observable.unsubscribeStub.reset()

            cancelable.cancel()

            XCTAssertEqual(observable.unsubscribeStub.invocations.count, 0)
        }

        // swiftlint:disable opening_brace
        let eventInvocations = [
            { try verifyInvocation(eventType: .mapLoaded) },
            { try verifyInvocation(eventType: .mapLoadingError) },
            { try verifyInvocation(eventType: .mapIdle) },
            { try verifyInvocation(eventType: .styleDataLoaded) },
            { try verifyInvocation(eventType: .styleLoaded) },
            { try verifyInvocation(eventType: .styleImageMissing) },
            { try verifyInvocation(eventType: .styleImageRemoveUnused) },
            { try verifyInvocation(eventType: .sourceDataLoaded) },
            { try verifyInvocation(eventType: .sourceAdded) },
            { try verifyInvocation(eventType: .sourceRemoved) },
            { try verifyInvocation(eventType: .renderFrameStarted) },
            { try verifyInvocation(eventType: .renderFrameFinished) },
            { try verifyInvocation(eventType: .cameraChanged) },
            { try verifyInvocation(eventType: .resourceRequest) }
        ]
        // swiftlint:enable opening_brace

        try eventInvocations.randomElement()!()
    }

    @available(*, deprecated)
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

    func testOnTypedNextWithSynchronousInvocation() throws {
        func verifyInvocation<Payload>(
            eventType: MapEvents.Event<Payload>,
            handlerStub: Stub<MapEvent<Payload>, Void> = .init()
        ) throws {
            observable.subscribeStub.defaultSideEffect = { invocation in
                invocation.parameters.observer.notify(for: Event(type: "", data: 0))
            }

            let cancelable = mapboxObservable.onNext(event: eventType, handler: handlerStub.call(with:))

            let subscribedObserver = try XCTUnwrap(observable.subscribeStub.invocations.first?.parameters.observer)
            XCTAssertEqual(observable.unsubscribeStub.invocations.count, 1)
            XCTAssertIdentical(observable.unsubscribeStub.invocations.first?.parameters, subscribedObserver)

            // invoking the cancelable does not attempt to unsubscribe a second time
            observable.unsubscribeStub.reset()

            cancelable.cancel()

            XCTAssertEqual(observable.unsubscribeStub.invocations.count, 0)
        }

        // swiftlint:disable opening_brace
        let eventInvocations = [
            { try verifyInvocation(eventType: .mapLoaded) },
            { try verifyInvocation(eventType: .mapLoadingError) },
            { try verifyInvocation(eventType: .mapIdle) },
            { try verifyInvocation(eventType: .styleDataLoaded) },
            { try verifyInvocation(eventType: .styleLoaded) },
            { try verifyInvocation(eventType: .styleImageMissing) },
            { try verifyInvocation(eventType: .styleImageRemoveUnused) },
            { try verifyInvocation(eventType: .sourceDataLoaded) },
            { try verifyInvocation(eventType: .sourceAdded) },
            { try verifyInvocation(eventType: .sourceRemoved) },
            { try verifyInvocation(eventType: .renderFrameStarted) },
            { try verifyInvocation(eventType: .renderFrameFinished) },
            { try verifyInvocation(eventType: .cameraChanged) },
            { try verifyInvocation(eventType: .resourceRequest) }
        ]
        // swiftlint:enable opening_brace

        try eventInvocations.randomElement()!()
    }

    @available(*, deprecated)
    func testOnEvery() throws {
        let cancelable = mapboxObservable.onEvery(eventTypes, handler: handlerStub.call(with:))

        // Initial subscribe invokes subscribe only with expected events
        XCTAssertEqual(observable.unsubscribeStub.invocations.count, 0)
        XCTAssertEqual(observable.subscribeStub.invocations.count, 1)
        let subscribeInvocation = try XCTUnwrap(observable.subscribeStub.invocations.first)
        XCTAssertEqual(Set(subscribeInvocation.parameters.events), Set(eventTypes.map(\.rawValue)))

        // notifying the observer passed to the observable should notify the handler passed to mapboxObservable
        let event = Event(type: "", data: 0)
        notify(with: event)
        XCTAssertEqual(handlerStub.invocations.count, 1)
        XCTAssertIdentical(handlerStub.invocations.first?.parameters, event)

        // event delivery does not end the subscription
        XCTAssertEqual(observable.unsubscribeStub.invocations.count, 0)

        // invoking the cancelable ends the subscription
        cancelable.cancel()

        let subscribedObserver = subscribeInvocation.parameters.observer
        XCTAssertEqual(observable.unsubscribeStub.invocations.count, 1)
        XCTAssertIdentical(observable.unsubscribeStub.invocations.first?.parameters, subscribedObserver)

        // invoking the cancelable again does nothing
        observable.unsubscribeStub.reset()

        cancelable.cancel()

        XCTAssertEqual(observable.unsubscribeStub.invocations.count, 0)
    }

    func testOnTypedEvery() throws {
        func verifyInvocation<Payload>(
            eventType: MapEvents.Event<Payload>,
            handlerStub: Stub<MapEvent<Payload>, Void> = .init()
        ) throws {
            let cancelable = mapboxObservable.onEvery(event: eventType, handler: handlerStub.call(with:))

            // Initial subscribe invokes subscribe only with expected events
            XCTAssertEqual(observable.unsubscribeStub.invocations.count, 0)
            XCTAssertEqual(observable.subscribeStub.invocations.count, 1)
            let subscribeInvocation = try XCTUnwrap(observable.subscribeStub.invocations.first)
            XCTAssertEqual(subscribeInvocation.parameters.events, [eventType.name])

            // notifying the observer passed to the observable should notify the handler passed to mapboxObservable
            let event = Event(type: "", data: 0)
            notify(with: event)
            XCTAssertEqual(handlerStub.invocations.count, 1)
            XCTAssertIdentical(handlerStub.invocations.first?.parameters.event, event)

            // event delivery does not end the subscription
            XCTAssertEqual(observable.unsubscribeStub.invocations.count, 0)

            // invoking the cancelable ends the subscription
            cancelable.cancel()

            let subscribedObserver = subscribeInvocation.parameters.observer
            XCTAssertEqual(observable.unsubscribeStub.invocations.count, 1)
            XCTAssertIdentical(observable.unsubscribeStub.invocations.first?.parameters, subscribedObserver)

            // invoking the cancelable again does nothing
            observable.unsubscribeStub.reset()

            cancelable.cancel()

            XCTAssertEqual(observable.unsubscribeStub.invocations.count, 0)
        }

        // swiftlint:disable opening_brace
        let eventInvocations = [
            { try verifyInvocation(eventType: .mapLoaded) },
            { try verifyInvocation(eventType: .mapLoadingError) },
            { try verifyInvocation(eventType: .mapIdle) },
            { try verifyInvocation(eventType: .styleDataLoaded) },
            { try verifyInvocation(eventType: .styleLoaded) },
            { try verifyInvocation(eventType: .styleImageMissing) },
            { try verifyInvocation(eventType: .styleImageRemoveUnused) },
            { try verifyInvocation(eventType: .sourceDataLoaded) },
            { try verifyInvocation(eventType: .sourceAdded) },
            { try verifyInvocation(eventType: .sourceRemoved) },
            { try verifyInvocation(eventType: .renderFrameStarted) },
            { try verifyInvocation(eventType: .renderFrameFinished) },
            { try verifyInvocation(eventType: .cameraChanged) },
            { try verifyInvocation(eventType: .resourceRequest) }
        ]
        // swiftlint:enable opening_brace

        try eventInvocations.randomElement()!()
    }

    @available(*, deprecated)
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

    func testTypedUnsubscribesOnDeinit() throws {
        func verifyInvocation<Payload>(
            eventType: MapEvents.Event<Payload>,
            handlerStub: Stub<MapEvent<Payload>, Void> = .init()
        ) throws {
            let otherObserver = MockObserver()
            let subscribedObservers: [Observer]

            do {
                let mapboxObservable = MapboxObservable(observable: observable)
                mapboxObservable.subscribe(observer, events: events)
                mapboxObservable.subscribe(otherObserver, events: events)
                _ = mapboxObservable.onNext(event: eventType, handler: handlerStub.call(with:))
                _ = mapboxObservable.onEvery(event: eventType, handler: handlerStub.call(with:))

                XCTAssertEqual(observable.subscribeStub.invocations.count, 4)
                subscribedObservers = observable.subscribeStub.invocations.map(\.parameters.observer)
            }

            XCTAssertEqual(observable.unsubscribeStub.invocations.count, 4)
            let unsubscribedObservers = observable.unsubscribeStub.invocations.map(\.parameters)

            XCTAssertEqual(
                Set(subscribedObservers.map(ObjectIdentifier.init)),
                Set(unsubscribedObservers.map(ObjectIdentifier.init)))
        }

        // swiftlint:disable opening_brace
        let eventInvocations = [
            { try verifyInvocation(eventType: .mapLoaded) },
            { try verifyInvocation(eventType: .mapLoadingError) },
            { try verifyInvocation(eventType: .mapIdle) },
            { try verifyInvocation(eventType: .styleDataLoaded) },
            { try verifyInvocation(eventType: .styleLoaded) },
            { try verifyInvocation(eventType: .styleImageMissing) },
            { try verifyInvocation(eventType: .styleImageRemoveUnused) },
            { try verifyInvocation(eventType: .sourceDataLoaded) },
            { try verifyInvocation(eventType: .sourceAdded) },
            { try verifyInvocation(eventType: .sourceRemoved) },
            { try verifyInvocation(eventType: .renderFrameStarted) },
            { try verifyInvocation(eventType: .renderFrameFinished) },
            { try verifyInvocation(eventType: .cameraChanged) },
            { try verifyInvocation(eventType: .resourceRequest) }
        ]
        // swiftlint:enable opening_brace

        try eventInvocations.randomElement()!()
    }

    @available(*, deprecated)
    func testPerformWithoutNotifying() {
        let otherObserver = MockObserver()
        let otherHandlerStub = Stub<Event, Void>()
        mapboxObservable.subscribe(observer, events: events)
        mapboxObservable.subscribe(otherObserver, events: events)
        _ = mapboxObservable.onNext(eventTypes, handler: handlerStub.call(with:))
        _ = mapboxObservable.onEvery(eventTypes, handler: otherHandlerStub.call(with:))

        mapboxObservable.performWithoutNotifying {
            // do actions that trigger notifications
            notify(with: Event(type: "", data: 0))
        }

        XCTAssertEqual(observer.notifyStub.invocations.count, 0)
        XCTAssertEqual(otherObserver.notifyStub.invocations.count, 0)
        XCTAssertEqual(handlerStub.invocations.count, 0)
        XCTAssertEqual(otherHandlerStub.invocations.count, 0)

        // do actions that trigger notifications again
        let event = Event(type: "", data: 0)
        notify(with: event)

        XCTAssertEqual(observer.notifyStub.invocations.count, 1)
        XCTAssertIdentical(observer.notifyStub.invocations.first?.parameters, event)
        XCTAssertEqual(otherObserver.notifyStub.invocations.count, 1)
        XCTAssertIdentical(otherObserver.notifyStub.invocations.first?.parameters, event)
        XCTAssertEqual(handlerStub.invocations.count, 1)
        XCTAssertIdentical(handlerStub.invocations.first?.parameters, event)
        XCTAssertEqual(otherHandlerStub.invocations.count, 1)
        XCTAssertIdentical(otherHandlerStub.invocations.first?.parameters, event)
    }

    func testTypedPerformWithoutNotifying() throws {
        func verifyInvocation<Payload>(
            eventType: MapEvents.Event<Payload>,
            handlerStub: Stub<MapEvent<Payload>, Void> = .init(),
            otherHandlerStub: Stub<MapEvent<Payload>, Void> = .init()
        ) throws {
            let otherObserver = MockObserver()
            mapboxObservable.subscribe(observer, events: events)
            mapboxObservable.subscribe(otherObserver, events: events)
            _ = mapboxObservable.onNext(event: eventType, handler: handlerStub.call(with:))
            _ = mapboxObservable.onEvery(event: eventType, handler: otherHandlerStub.call(with:))

            mapboxObservable.performWithoutNotifying {
                // do actions that trigger notifications
                notify(with: Event(type: "", data: 0))
            }

            XCTAssertEqual(observer.notifyStub.invocations.count, 0)
            XCTAssertEqual(otherObserver.notifyStub.invocations.count, 0)
            XCTAssertEqual(handlerStub.invocations.count, 0)
            XCTAssertEqual(otherHandlerStub.invocations.count, 0)

            // do actions that trigger notifications again
            let event = Event(type: "", data: 0)
            notify(with: event)

            XCTAssertEqual(observer.notifyStub.invocations.count, 1)
            XCTAssertIdentical(observer.notifyStub.invocations.first?.parameters, event)
            XCTAssertEqual(otherObserver.notifyStub.invocations.count, 1)
            XCTAssertIdentical(otherObserver.notifyStub.invocations.first?.parameters, event)
            XCTAssertEqual(handlerStub.invocations.count, 1)
            XCTAssertIdentical(handlerStub.invocations.first?.parameters.event, event)
            XCTAssertEqual(otherHandlerStub.invocations.count, 1)
            XCTAssertIdentical(otherHandlerStub.invocations.first?.parameters.event, event)
        }

        // swiftlint:disable opening_brace
        let eventInvocations = [
            { try verifyInvocation(eventType: .mapLoaded) },
            { try verifyInvocation(eventType: .mapLoadingError) },
            { try verifyInvocation(eventType: .mapIdle) },
            { try verifyInvocation(eventType: .styleDataLoaded) },
            { try verifyInvocation(eventType: .styleLoaded) },
            { try verifyInvocation(eventType: .styleImageMissing) },
            { try verifyInvocation(eventType: .styleImageRemoveUnused) },
            { try verifyInvocation(eventType: .sourceDataLoaded) },
            { try verifyInvocation(eventType: .sourceAdded) },
            { try verifyInvocation(eventType: .sourceRemoved) },
            { try verifyInvocation(eventType: .renderFrameStarted) },
            { try verifyInvocation(eventType: .renderFrameFinished) },
            { try verifyInvocation(eventType: .cameraChanged) },
            { try verifyInvocation(eventType: .resourceRequest) }
        ]
        // swiftlint:enable opening_brace

        try eventInvocations.randomElement()!()
    }

    @available(*, deprecated)
    func testReentrantPerformWithoutNotifying() {
        let otherObserver = MockObserver()
        let otherHandlerStub = Stub<Event, Void>()
        mapboxObservable.subscribe(observer, events: events)
        mapboxObservable.subscribe(otherObserver, events: events)
        _ = mapboxObservable.onNext(eventTypes, handler: handlerStub.call(with:))
        _ = mapboxObservable.onEvery(eventTypes, handler: otherHandlerStub.call(with:))

        mapboxObservable.performWithoutNotifying {
            mapboxObservable.performWithoutNotifying {
                notify(with: Event(type: "", data: 0))
            }

            notify(with: Event(type: "", data: 0))
        }

        XCTAssertEqual(observer.notifyStub.invocations.count, 0)
        XCTAssertEqual(otherObserver.notifyStub.invocations.count, 0)
        XCTAssertEqual(handlerStub.invocations.count, 0)
        XCTAssertEqual(otherHandlerStub.invocations.count, 0)
    }

    func testTypedReentrantPerformWithoutNotifying() throws {
        func verifyInvocation<Payload>(
            eventType: MapEvents.Event<Payload>,
            handlerStub: Stub<MapEvent<Payload>, Void> = .init(),
            otherHandlerStub: Stub<MapEvent<Payload>, Void> = .init()
        ) throws {
            let otherObserver = MockObserver()
            mapboxObservable.subscribe(observer, events: events)
            mapboxObservable.subscribe(otherObserver, events: events)
            _ = mapboxObservable.onNext(event: eventType, handler: handlerStub.call(with:))
            _ = mapboxObservable.onEvery(event: eventType, handler: otherHandlerStub.call(with:))

            mapboxObservable.performWithoutNotifying {
                mapboxObservable.performWithoutNotifying {
                    notify(with: Event(type: "", data: 0))
                }

                notify(with: Event(type: "", data: 0))
            }

            XCTAssertEqual(observer.notifyStub.invocations.count, 0)
            XCTAssertEqual(otherObserver.notifyStub.invocations.count, 0)
            XCTAssertEqual(handlerStub.invocations.count, 0)
            XCTAssertEqual(otherHandlerStub.invocations.count, 0)
        }

        // swiftlint:disable opening_brace
        let eventInvocations = [
            { try verifyInvocation(eventType: .mapLoaded) },
            { try verifyInvocation(eventType: .mapLoadingError) },
            { try verifyInvocation(eventType: .mapIdle) },
            { try verifyInvocation(eventType: .styleDataLoaded) },
            { try verifyInvocation(eventType: .styleLoaded) },
            { try verifyInvocation(eventType: .styleImageMissing) },
            { try verifyInvocation(eventType: .styleImageRemoveUnused) },
            { try verifyInvocation(eventType: .sourceDataLoaded) },
            { try verifyInvocation(eventType: .sourceAdded) },
            { try verifyInvocation(eventType: .sourceRemoved) },
            { try verifyInvocation(eventType: .renderFrameStarted) },
            { try verifyInvocation(eventType: .renderFrameFinished) },
            { try verifyInvocation(eventType: .cameraChanged) },
            { try verifyInvocation(eventType: .resourceRequest) }
        ]
        // swiftlint:enable opening_brace

        try eventInvocations.randomElement()!()
    }
}
