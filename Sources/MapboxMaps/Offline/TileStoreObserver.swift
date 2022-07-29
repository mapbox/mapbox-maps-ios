public protocol TileStoreObserver: AnyObject {
    /// Called whenever the load progress of a `TileRegion` changes.
    func onRegionLoadProgress(forId id: String, progress: TileRegionLoadProgress)

    /// Called when a `TileRegion` load finishes.
    func onRegionLoadFinished(forId id: String, region: Result<TileRegion, Error>)

    /// Called when a `TileRegion` was removed.
    func onRegionRemoved(forId id: String)

    /// Called when the geometry of a `TileRegion` was modified.
    func onRegionGeometryChanged(forId id: String, geometry: Geometry?)

    /// Called when the user-provided metadata associated with a `TileRegion` was changed.
    func onRegionMetadataChanged(forId id: String, value: Any)
}
