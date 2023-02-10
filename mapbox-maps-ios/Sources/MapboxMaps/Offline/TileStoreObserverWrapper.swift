@_implementationOnly import MapboxCommon_Private

internal class TileStoreObserverWrapper: MapboxCommon_Private.TileStoreObserver {
    private let observer: TileStoreObserver

    internal init(_ observer: TileStoreObserver) {
        self.observer = observer
    }

    internal func onRegionLoadProgress(forId id: String, progress: TileRegionLoadProgress) {
        observer.onRegionLoadProgress(forId: id, progress: progress)
    }

    internal func onRegionLoadFinished(forId id: String, region: Expected<TileRegion, TileRegionError.CoreErrorType>) {
        observer.onRegionLoadFinished(forId: id, region: Result(expected: region, valueType: TileRegion.self, errorType: TileRegionError.self))
    }

    internal func onRegionRemoved(forId id: String) {
        observer.onRegionRemoved(forId: id)
    }

    internal func onRegionGeometryChanged(forId id: String, geometry: MapboxCommon.Geometry) {
        observer.onRegionGeometryChanged(forId: id, geometry: Geometry(geometry))
    }

    internal func onRegionMetadataChanged(forId id: String, value: Any) {
        observer.onRegionMetadataChanged(forId: id, value: value)
    }
}
