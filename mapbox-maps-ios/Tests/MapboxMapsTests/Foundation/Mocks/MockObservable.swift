@testable import MapboxMaps

final class MockObservable: ObservableProtocol {
    struct SubscribeParams {
        var observer: Observer
        var events: [String]
    }
    let subscribeStub = Stub<SubscribeParams, Void>()
    func subscribe(for observer: Observer, events: [String]) {
        subscribeStub.call(with: .init(observer: observer, events: events))
    }

    let unsubscribeStub = Stub<Observer, Void>()
    func unsubscribe(for observer: Observer) {
        unsubscribeStub.call(with: observer)
    }
}
