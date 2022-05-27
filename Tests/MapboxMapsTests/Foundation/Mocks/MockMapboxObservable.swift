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
    func onTypedNext<Payload>(_ eventType: MapEvents.Event<Payload>, handler: @escaping (TypedEvent<Payload>) -> Void) -> Cancelable where Payload : Decodable {
        onTypedNextStub.call(with: OnTypedNextParams(eventName: eventType.name, handler: { handler($0 as! TypedEvent<Payload>)} ))
    }

    struct OnTypedEveryParams {
        var eventName: String
        var handler: (Any) -> Void
    }
    let onTypedEveryStub = Stub<OnTypedEveryParams, Cancelable>(defaultReturnValue: MockCancelable())
    func onTypedEvery<Payload: Decodable>(_ eventType: MapEvents.Event<Payload>, handler: @escaping (TypedEvent<Payload>) -> Void) -> Cancelable {
        onTypedEveryStub.call(with: OnTypedEveryParams(eventName: eventType.name, handler: { handler($0 as! TypedEvent<Payload>)}))
    }

    // not using Stub here since the block is not escaping
    var performWithoutNotifyingInvocationCount = 0
    func performWithoutNotifying(_ block: () -> Void) {
        performWithoutNotifyingInvocationCount += 1
        block()
    }
}
