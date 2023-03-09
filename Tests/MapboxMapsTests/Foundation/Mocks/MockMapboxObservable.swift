@_spi(Package) @testable import MapboxMaps

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
    func performWithoutNotifying(_ block: () throws -> Void) rethrows {
        performWithoutNotifyingInvocationCount += 1
        try block()
    }
}
