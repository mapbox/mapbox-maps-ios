@testable import MapboxMaps

final class MockMapboxObservable: MapboxObservableProtocol {
    struct SubscribeParams {
        var observer: Observer
        var events: [String]
    }
    let subscribeStub = Stub<SubscribeParams, Void>()
    func subscribe(_ observer: Observer, events: [String]) {
        subscribeStub.call(with: .init(observer: observer, events: events))
    }

    struct UnsubscribeParams {
        var observer: Observer
        var events: [String]
    }
    let unsubscribeStub = Stub<UnsubscribeParams, Void>()
    func unsubscribe(_ observer: Observer, events: [String]) {
        unsubscribeStub.call(with: .init(observer: observer, events: events))
    }

    @available(*, deprecated)
    struct OnNextParams {
        var eventTypes: [MapEvents.EventKind]
        var handler: (Event) -> Void
    }
    @available(*, deprecated)
    let onNextStub = Stub<OnNextParams, Cancelable>(defaultReturnValue: MockCancelable())
    @available(*, deprecated)
    func onNext(_ eventTypes: [MapEvents.EventKind], handler: @escaping (Event) -> Void) -> Cancelable {
        onNextStub.call(with: .init(eventTypes: eventTypes, handler: handler))
    }

    @available(*, deprecated)
    struct OnEveryParams {
        var eventTypes: [MapEvents.EventKind]
        var handler: (Event) -> Void
    }
    @available(*, deprecated)
    let onEveryStub = Stub<OnEveryParams, Cancelable>(defaultReturnValue: MockCancelable())
    @available(*, deprecated)
    func onEvery(_ eventTypes: [MapEvents.EventKind], handler: @escaping (Event) -> Void) -> Cancelable {
        onEveryStub.call(with: .init(eventTypes: eventTypes, handler: handler))
    }

    struct OnTypedNextParams {
        var eventName: String
        var handler: (Any) -> Void
    }
    let onTypedNextStub = Stub<OnTypedNextParams, Cancelable>(defaultReturnValue: MockCancelable())
    func onNext<Payload>(event: MapEvents.Event<Payload>, handler: @escaping (MapEvent<Payload>) -> Void) -> Cancelable where Payload: Decodable {
        // swiftlint:disable:next force_cast
        onTypedNextStub.call(with: OnTypedNextParams(eventName: event.name, handler: { handler($0 as! MapEvent<Payload>)}))
    }

    struct OnTypedEveryParams {
        var eventName: String
        var handler: (Any) -> Void
    }
    let onTypedEveryStub = Stub<OnTypedEveryParams, Cancelable>(defaultReturnValue: MockCancelable())
    func onEvery<Payload>(event: MapEvents.Event<Payload>, handler: @escaping (MapEvent<Payload>) -> Void) -> Cancelable {
        // swiftlint:disable:next force_cast
        onTypedEveryStub.call(with: OnTypedEveryParams(eventName: event.name, handler: { handler($0 as! MapEvent<Payload>)}))
    }

    // not using Stub here since the block is not escaping
    var performWithoutNotifyingInvocationCount = 0
    func performWithoutNotifying(_ block: () -> Void) {
        performWithoutNotifyingInvocationCount += 1
        block()
    }
}
