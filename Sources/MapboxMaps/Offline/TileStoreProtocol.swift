@_implementationOnly import MapboxCommon_Private

internal protocol TileStoreProtocol: AnyObject {
    func __removeObserver(for observer: MapboxCommon_Private.TileStoreObserver)
}

extension TileStore: TileStoreProtocol {}
