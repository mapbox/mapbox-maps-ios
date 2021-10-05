@testable import MapboxMaps
import MapboxCommon_Private

final class MockTileStore: TileStoreProtocol {
    let __removeObserverStub = Stub<MapboxCommon_Private.TileStoreObserver, Void>()
    func __removeObserver(for observer: MapboxCommon_Private.TileStoreObserver) {
        __removeObserverStub.call(with: observer)
    }
}
