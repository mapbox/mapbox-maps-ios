@testable import MapboxMaps
internal import MapboxCommon_Private

final class MockTileStore: TileStoreProtocol {
    let __removeObserverStub = Stub<MapboxCommon_Private.TileStoreObserver, Void>()
    func __removeObserver(for observer: MapboxCommon_Private.TileStoreObserver) {
        __removeObserverStub.call(with: observer)
    }

    struct SubscribeForEventParams {
        var eventName: String
        var callback: (__TileStoreGenericEvent) -> Void
    }
    let __subscribeForEventStub = Stub<SubscribeForEventParams, Cancelable>(defaultReturnValue: MockCancelable())
    func __subscribeForEvent(forEventName eventName: String,
                             callback: @escaping (__TileStoreGenericEvent) -> Void) -> Cancelable {
        __subscribeForEventStub.call(with: SubscribeForEventParams(eventName: eventName, callback: callback))
    }
}
