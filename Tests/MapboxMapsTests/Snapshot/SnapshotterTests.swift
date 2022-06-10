import XCTest
@testable import MapboxMaps

final class SnapshotterTests: XCTestCase {

    var mapboxObservableProviderStub: Stub<ObservableProtocol, MapboxObservableProtocol>!
    var snapshotter: Snapshotter!

    override func setUp() {
        super.setUp()
        let options = MapSnapshotOptions(
            size: CGSize(width: 100, height: 100),
            pixelRatio: .random(in: 1...3))
        mapboxObservableProviderStub = Stub(defaultReturnValue: MockMapboxObservable())
        snapshotter = Snapshotter(
            options: options,
            mapboxObservableProvider: mapboxObservableProviderStub.call(with:))
    }

    override func tearDown() {
        snapshotter = nil
        mapboxObservableProviderStub = nil
        super.tearDown()
    }

    func testInitializationMapboxObservable() {
        XCTAssertEqual(mapboxObservableProviderStub.invocations.count, 1)
        XCTAssertIdentical(mapboxObservableProviderStub.invocations.first?.parameters, snapshotter.mapSnapshotter)
    }

    func testSubscribe() throws {
        let observer = MockObserver()
        let events: [String] = .random()
        let mapboxObservable = try XCTUnwrap(mapboxObservableProviderStub.invocations.first?.returnValue as? MockMapboxObservable)

        snapshotter.subscribe(observer, events: events)

        XCTAssertEqual(mapboxObservable.subscribeStub.invocations.count, 1)
        XCTAssertIdentical(mapboxObservable.subscribeStub.invocations.first?.parameters.observer, observer)
        XCTAssertEqual(mapboxObservable.subscribeStub.invocations.first?.parameters.events, events)
    }

    func testUnsubscribe() throws {
        let observer = MockObserver()
        let events: [String] = .random()
        let mapboxObservable = try XCTUnwrap(mapboxObservableProviderStub.invocations.first?.returnValue as? MockMapboxObservable)

        snapshotter.unsubscribe(observer, events: events)

        XCTAssertEqual(mapboxObservable.unsubscribeStub.invocations.count, 1)
        XCTAssertIdentical(mapboxObservable.unsubscribeStub.invocations.first?.parameters.observer, observer)
        XCTAssertEqual(mapboxObservable.unsubscribeStub.invocations.first?.parameters.events, events)
    }

    @available(*, deprecated)
    func testOnNext() throws {
        let handlerStub = Stub<Event, Void>()
        let eventType = MapEvents.EventKind.allCases.randomElement()!
        let mapboxObservable = try XCTUnwrap(mapboxObservableProviderStub.invocations.first?.returnValue as? MockMapboxObservable)

        snapshotter.onNext(eventType, handler: handlerStub.call(with:))

        XCTAssertEqual(mapboxObservable.onNextStub.invocations.count, 1)
        XCTAssertEqual(mapboxObservable.onNextStub.invocations.first?.parameters.eventTypes, [eventType])
        // To verify that the handler passed to Snapshotter is effectively the same as the one received by MapboxObservable,
        // we exercise the received handler and verify that the passed one is invoked. If blocks were identifiable, maybe
        // we'd just write this as `passedHandler === receivedHandler`.
        let handler = try XCTUnwrap(mapboxObservable.onNextStub.invocations.first?.parameters.handler)
        let event = Event(type: "", data: 0)
        handler(event)
        XCTAssertEqual(handlerStub.invocations.count, 1)
        XCTAssertIdentical(handlerStub.invocations.first?.parameters, event)
    }

    func testOnTypedNext() throws {
        func verifyInvocation<Payload>(
            eventType: MapEvents.Event<Payload>,
            event: MapEvent<Payload> = .init(event: Event(type: "", data: 0)),
            handlerStub: Stub<MapEvent<Payload>, Void> = .init()
        ) throws {
            let mapboxObservable = try XCTUnwrap(mapboxObservableProviderStub.invocations.first?.returnValue as? MockMapboxObservable)

            snapshotter.onNext(event: eventType, handler: handlerStub.call(with:))

            XCTAssertEqual(mapboxObservable.onTypedNextStub.invocations.count, 1)
            XCTAssertEqual(mapboxObservable.onTypedNextStub.invocations.first?.parameters.eventName, eventType.name)
            // To verify that the handler passed to Snapshotter is effectively the same as the one received by MapboxObservable,
            // we exercise the received handler and verify that the passed one is invoked. If blocks were identifiable, maybe
            // we'd just write this as `passedHandler === receivedHandler`.
            let handler = try XCTUnwrap(mapboxObservable.onTypedNextStub.invocations.first?.parameters.handler)
            handler(event)
            XCTAssertEqual(handlerStub.invocations.count, 1)
            XCTAssertIdentical(handlerStub.invocations.first?.parameters, event)
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
        let handlerStub = Stub<Event, Void>()
        let eventType = MapEvents.EventKind.allCases.randomElement()!
        let mapboxObservable = try XCTUnwrap(mapboxObservableProviderStub.invocations.first?.returnValue as? MockMapboxObservable)

        snapshotter.onEvery(eventType, handler: handlerStub.call(with:))

        XCTAssertEqual(mapboxObservable.onEveryStub.invocations.count, 1)
        XCTAssertEqual(mapboxObservable.onEveryStub.invocations.first?.parameters.eventTypes, [eventType])
        // To verify that the handler passed to Snapshotter is effectively the same as the one received by MapboxObservable,
        // we exercise the received handler and verify that the passed one is invoked. If blocks were identifiable, maybe
        // we'd just write this as `passedHandler === receivedHandler`.
        let handler = try XCTUnwrap(mapboxObservable.onEveryStub.invocations.first?.parameters.handler)
        let event = Event(type: "", data: 0)
        handler(event)
        XCTAssertEqual(handlerStub.invocations.count, 1)
        XCTAssertIdentical(handlerStub.invocations.first?.parameters, event)
    }

    func testOnTypedEvery() throws {
        func verifyInvocation<Payload>(
            eventType: MapEvents.Event<Payload>,
            event: MapEvent<Payload> = .init(event: Event(type: "", data: 0)),
            handlerStub: Stub<MapEvent<Payload>, Void> = .init()
        ) throws {
            let mapboxObservable = try XCTUnwrap(mapboxObservableProviderStub.invocations.first?.returnValue as? MockMapboxObservable)

            snapshotter.onEvery(event: eventType, handler: handlerStub.call(with:))

            XCTAssertEqual(mapboxObservable.onTypedEveryStub.invocations.count, 1)
            XCTAssertEqual(mapboxObservable.onTypedEveryStub.invocations.first?.parameters.eventName, eventType.name)
            // To verify that the handler passed to Snapshotter is effectively the same as the one received by MapboxObservable,
            // we exercise the received handler and verify that the passed one is invoked. If blocks were identifiable, maybe
            // we'd just write this as `passedHandler === receivedHandler`.
            let handler = try XCTUnwrap(mapboxObservable.onTypedEveryStub.invocations.first?.parameters.handler)
            handler(event)
            XCTAssertEqual(handlerStub.invocations.count, 1)
            XCTAssertIdentical(handlerStub.invocations.first?.parameters, event)
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
