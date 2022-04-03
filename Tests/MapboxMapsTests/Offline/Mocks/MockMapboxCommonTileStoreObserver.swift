import MapboxCommon_Private

final class MockMapboxCommonTileStoreObserver: MapboxCommon_Private.TileStoreObserver {
    func onRegionLoadProgress(forId id: String, progress: TileRegionLoadProgress) {
    }

    func onRegionLoadFinished(forId id: String, region: Expected<TileRegion, TileRegionError>) {
    }

    func onRegionRemoved(forId id: String) {
    }

    func onRegionGeometryChanged(forId id: String, geometry: MapboxCommon.Geometry) {
    }

    func onRegionMetadataChanged(forId id: String, value: Any) {
    }
}
