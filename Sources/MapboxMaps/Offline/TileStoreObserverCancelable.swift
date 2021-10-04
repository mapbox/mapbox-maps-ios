@_implementationOnly import MapboxCommon_Private

internal final class TileStoreObserverCancelable: Cancelable {
    private weak var observer: MapboxCommon_Private.TileStoreObserver?
    private weak var tileStore: TileStoreProtocol?

    internal init(observer: MapboxCommon_Private.TileStoreObserver, tileStore: TileStoreProtocol) {
        self.observer = observer
        self.tileStore = tileStore
    }

    internal func cancel() {
        if let observer = observer {
            tileStore?.__removeObserver(for: observer)
        }
        observer = nil
        tileStore = nil
    }
}
