import MapboxMaps

final class MockTileStoreObserver: TileStoreObserver {
    struct OnRegionLoadProgressParams {
        var id: String
        var progress: TileRegionLoadProgress
    }
    let onRegionLoadProgressStub = Stub<OnRegionLoadProgressParams, Void>()
    func onRegionLoadProgress(forId id: String, progress: TileRegionLoadProgress) {
        onRegionLoadProgressStub.call(with: OnRegionLoadProgressParams(id: id, progress: progress))
    }

    struct OnRegionLoadFinishedParams {
        var id: String
        var region: Result<TileRegion, Error>
    }
    let onRegionLoadFinishedStub = Stub<OnRegionLoadFinishedParams, Void>()
    func onRegionLoadFinished(forId id: String, region: Result<TileRegion, Error>) {
        onRegionLoadFinishedStub.call(with: OnRegionLoadFinishedParams(id: id, region: region))
    }

    let onRegionRemovedStub = Stub<String, Void>()
    func onRegionRemoved(forId id: String) {
        onRegionRemovedStub.call(with: id)
    }

    struct OnRegionGeometryChangedParams {
        var id: String
        var geometry: Geometry?
    }
    let onRegionGeometryChangedStub = Stub<OnRegionGeometryChangedParams, Void>()
    func onRegionGeometryChanged(forId id: String, geometry: Geometry?) {
        onRegionGeometryChangedStub.call(with: OnRegionGeometryChangedParams(id: id, geometry: geometry))
    }

    struct OnRegionMetadataChangedParams {
        var id: String
        var value: Any
    }
    let onRegionMetadataChangedStub = Stub<OnRegionMetadataChangedParams, Void>()
    func onRegionMetadataChanged(forId id: String, value: Any) {
        onRegionMetadataChangedStub.call(with: OnRegionMetadataChangedParams(id: id, value: value))
    }
}
