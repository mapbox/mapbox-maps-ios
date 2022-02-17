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

    struct OnNextParams {
        var eventTypes: [MapEvents.EventKind]
        var handler: (Event) -> Void
    }
    let onNextStub = Stub<OnNextParams, Cancelable>(defaultReturnValue: MockCancelable())
    func onNext(_ eventTypes: [MapEvents.EventKind], handler: @escaping (Event) -> Void) -> Cancelable {
        onNextStub.call(with: .init(eventTypes: eventTypes, handler: handler))
    }

    struct OnEveryParams {
        var eventTypes: [MapEvents.EventKind]
        var handler: (Event) -> Void
    }
    let onEveryStub = Stub<OnEveryParams, Cancelable>(defaultReturnValue: MockCancelable())
    func onEvery(_ eventTypes: [MapEvents.EventKind], handler: @escaping (Event) -> Void) -> Cancelable {
        onEveryStub.call(with: .init(eventTypes: eventTypes, handler: handler))
    }
}
