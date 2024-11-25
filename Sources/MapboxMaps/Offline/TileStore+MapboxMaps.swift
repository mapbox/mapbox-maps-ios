import Foundation
@_implementationOnly import MapboxCommon_Private

internal protocol TileStoreProtocol: AnyObject {
    func __removeObserver(for observer: MapboxCommon_Private.TileStoreObserver)
}

extension TileStore: TileStoreProtocol {

    /// Returns a shared `TileStore` instance at the default location. Creates a
    /// new one if one doesn't yet exist.
    ///
    /// - See Also:
    ///     `shared(for:)`
    public static var `default`: TileStore {
        return TileStore.__create()
    }

    /// Gets a `TileStore` instance for the given storage path. Creates a new one
    /// if one doesn't exist.
    ///
    /// If the given path is empty, the tile store at the default location is
    /// returned.
    ///
    /// On iOS, this storage path is excluded from automatic cloud backup.
    ///
    /// - Parameter filePathURL: The path on disk where tiles and metadata will be stored
    /// - Returns: TileStore instance.
    public static func shared(for filePathURL: URL) -> TileStore {
        guard filePathURL.isFileURL else {
            fatalError("You must provide a file URL")
        }
        return TileStore.__create(forPath: filePathURL.path)
    }

    /// Loads a new tile region or updates the existing one.
    ///
    /// - Parameters:
    ///   - id: The tile region identifier.
    ///   - loadOptions: The tile region load options.
    ///   - progress: Invoked multiple times to report progress of the loading
    ///         operation. Optional, default is nil.
    ///   - completion: Invoked only once upon success, failure, or cancelation
    ///         of the loading operation. Any `Result` error could be of type
    ///         `TileRegionError`.
    ///
    /// - Returns: A `Cancelable` object to cancel the load request
    ///
    /// Creating of a new region requires providing both geometry and tileset
    /// descriptors to the given load options, otherwise the load request fails
    /// with `RegionNotFound` error.
    ///
    /// If a tile region with the given id already exists, it gets updated with
    /// the values provided to the given load options. The missing resources get
    /// loaded and the expired resources get updated.
    ///
    /// If there are no values provided to the given load options, the existing tile
    /// region gets refreshed: the missing resources get loaded and the expired
    /// resources get updated.
    ///
    /// A failed load request can be reattempted with another `loadTileRegion()` call.
    ///
    /// If there is already a pending loading operation for the tile region with
    /// the given id, the pending loading operation will fail with an error of
    /// `Canceled` type.
    ///
    /// - Note:
    ///     The user-provided callbacks will be executed on a
    ///     TileStore-controlled worker thread; it is the responsibility of the
    ///     user to dispatch to a user-controlled thread.
    ///
    /// - Important:
    ///     By default, users may download up to 750 tile packs for offline
    ///     use across all regions. If the limit is hit, any loadRegion call
    ///     will fail until excess regions are deleted. This limit is subject
    ///     to change. Please contact Mapbox if you require a higher limit.
    ///     Additional charges may apply.
    @discardableResult
    public func loadTileRegion(forId id: String,
                               loadOptions: TileRegionLoadOptions,
                               progress: TileRegionLoadProgressCallback? = nil,
                               completion: @escaping (Result<TileRegion, Error>) -> Void) -> Cancelable {
        if let progress = progress {
            return __loadTileRegion(forId: id,
                                    loadOptions: loadOptions,
                                    onProgress: progress,
                                    onFinished: tileStoreClosureAdapter(for: completion, type: TileRegion.self))
        }
        // Use overloaded version
        else {
            return __loadTileRegion(forId: id,
                                    loadOptions: loadOptions,
                                    onFinished: tileStoreClosureAdapter(for: completion, type: TileRegion.self))
        }
    }

    /// Estimates the storage and transfer size of a tile region.
    ///
    /// - Parameters:
    ///  - id The tile region identifier.
    ///  - loadOptions The tile region load options.
    ///  - estimateOptions The options for the estimate operation. Optional, default values will be aplied if nil.
    ///  - onProgress Invoked multiple times to report progess of the estimate operation.
    ///  - onFinished Invoked only once upon success, failure, or cancelation of the estimate operation.
    /// - Returns: a `Cancelable` object to cancel the estimate request
    ///
    /// This can be used for estimating existing or new tile regions. For new tile
    /// regions, both geometry and tileset descriptors need to be provided to the
    /// given load options.  If a tile region with the given id already exists, its
    /// geometry and tileset descriptors are reused unless a different value is
    /// provided in the region load options.
    ///
    /// Estimating a tile region does not mutate exising tile regions on the tile store.
    ///
    /// - Note:
    ///     The user-provided callbacks will be executed on a TileStore-controlled worker thread;
    ///     it is the responsibility of the user to dispatch to a user-controlled thread.
    @discardableResult
    public func estimateTileRegion(forId id: String,
                                   loadOptions: TileRegionLoadOptions,
                                   estimateOptions: TileRegionEstimateOptions? = nil,
                                   progress: @escaping TileRegionEstimateProgressCallback,
                                   completion: @escaping (Result<TileRegionEstimateResult, Error>) -> Void) -> Cancelable {
        if let estimateOptions = estimateOptions {
            return __estimateTileRegion(forId: id,
                                        loadOptions: loadOptions,
                                        estimateOptions: estimateOptions,
                                        onProgress: progress,
                                        onFinished: tileStoreClosureAdapter(for: completion, type: TileRegionEstimateResult.self))
        }
        // Use overloaded version
        else {
            return __estimateTileRegion(forId: id,
                                        options: loadOptions,
                                        onProgress: progress,
                                        onFinished: tileStoreClosureAdapter(for: completion, type: TileRegionEstimateResult.self))
        }
    }

    /// Checks if a tile region with the given id contains all tilesets from all
    /// of the given tileset descriptors.
    ///
    /// - Parameters:
    ///   - id: The tile region identifier.
    ///   - descriptors: The array of tileset descriptors.
    ///   - completion: The result callback. Any `Result` error could be of type
    ///         `TileRegionError`.
    ///
    /// - Note:
    ///     The user-provided callbacks will be executed on a TileStore-controlled
    ///     worker thread; it is the responsibility of the user to dispatch to a
    ///     user-controlled thread.
    public func tileRegionContainsDescriptors(forId id: String,
                                              descriptors: [TilesetDescriptor],
                                              completion: @escaping (Result<Bool, Error>) -> Void) {
        __tileRegionContainsDescriptors(forId: id,
                                        descriptors: descriptors,
                                        callback: tileStoreClosureAdapter(for: completion, type: NSNumber.self))
    }

    /// Fetch the array of the existing tile regions.
    ///
    /// - Parameter completion: The result callback. Any `Result` error should be
    ///         of type `TileRegionError`.
    ///
    /// - Note:
    ///     The user-provided callbacks will be executed on a TileStore-controlled
    ///     worker thread; it is the responsibility of the user to dispatch to a
    ///     user-controlled thread.
    public func allTileRegions(completion: @escaping (Result<[TileRegion], Error>) -> Void) {
        __getAllTileRegions(forCallback: tileStoreClosureAdapter(for: completion, type: NSArray.self))
    }

    /// Returns a tile region given its id.
    ///
    /// - Parameters:
    ///   - id: The tile region id.
    ///   - completion: The Result callback. Any `Result` error could be of type
    ///         `TileRegionError`.
    ///
    /// - Note:
    ///     The user-provided callbacks will be executed on a TileStore-controlled
    ///     worker thread; it is the responsibility of the user to dispatch to a
    ///     user-controlled thread.
    public func tileRegion(forId id: String,
                           completion: @escaping (Result<TileRegion, Error>) -> Void) {
        __getTileRegion(forId: id,
                        callback: tileStoreClosureAdapter(for: completion, type: TileRegion.self))
    }

    /// Fetch a tile region's associated geometry
    ///
    /// The region associated geometry is provided by the client and it represents
    /// the area, which the tile region must cover. The actual regional geometry
    /// depends on the tiling scheme and might exceed the associated geometry.
    ///
    /// - Parameters:
    ///   - id: The tile region id.
    ///   - completion: The Result closure. Any `Result` error could be of type
    ///         `TileRegionError`.
    ///
    /// - Note:
    ///     The user-provided callbacks will be executed on a TileStore-controlled
    ///     worker thread; it is the responsibility of the user to dispatch to a
    ///     user-controlled thread.
    public func tileRegionGeometry(forId id: String,
                                   completion: @escaping (Result<Geometry, Error>) -> Void) {
        let callback = coreAPIClosureAdapter(for: completion, type: MapboxCommon.Geometry.self, concreteErrorType: TileRegionError.self, converter: Geometry.init(_:))
        __getTileRegionGeometry(forId: id,
                                callback: callback)
    }

    /// Fetch a tile region's associated metadata
    ///
    /// The region's associated metadata that a user previously set for this region.
    ///
    /// - Parameters:
    ///   - id: The tile region id.
    ///   - completion: The Result closure. Any `Result` error could be of type
    ///         `TileRegionError`.
    public func tileRegionMetadata(forId id: String,
                                   completion: @escaping (Result<Any, Error>) -> Void) {
        __getTileRegionMetadata(forId: id,
                                callback: tileStoreClosureAdapter(for: completion, type: AnyObject.self))
    }

    /// Allows observing a tile store's activity
    /// - Parameter observer: The object to be notified when events occur. TileStore holds a strong reference to this object until the subscription is canceled.
    /// - Returns: An object that can be used to cancel the subscription.
    public func subscribe(_ observer: TileStoreObserver) -> Cancelable {
        let wrapper = TileStoreObserverWrapper(observer)
        __addObserver(for: wrapper)
        return TileStoreObserverCancelable(observer: wrapper, tileStore: self)
    }

    /// An overloaded version of `removeTileRegion(forId:)` with a callback for feedback.
    /// On successful tile region removal, the given callback is invoked with the removed tile region.
    /// Otherwise, the given callback is invoked with an error.
    /// - Parameter id: The tile region identifier.
    /// - Parameter completion: A callback to be invoked when a tile region was removed.
    public func removeRegion(forId id: String, completion: @escaping (Result<TileRegion, Error>) -> Void) {
        __removeTileRegion(forId: id, callback: tileStoreClosureAdapter(for: completion, type: TileRegion.self))
    }

    /// Clears the ambient cache data.
    ///
    /// Ambient cache data is anything not associated with an offline region or a stylepack,
    /// including predictively cached data. Use to quickly clear data e.g. for a system update.
    ///
    /// Note: Do not use this method to clear cache data unless strictly
    /// necessary as previously cached data will need to be re-downloaded,
    /// leading to increased network usage.
    /// If you want general control of the size of the Tile Store.
    ///
    /// - Note: This function is blocking the Tile Store until completed.
    /// - Parameter completion: The `UInt32` value represents how many bytes were cleared from the cache.
    public func clearAmbientCache(
        completion: @escaping (Result<UInt32, any Error>) -> Void
    ) {
        clearAmbientCache(
            forCallback: coreAPIClosureAdapter(
                for: completion,
                type: NSNumber.self,
                concreteErrorType: ClearCacheError.self,
                converter: { $0.uint32Value }
            )
        )
    }

}

private func tileStoreClosureAdapter<T, ObjCType>(
    for closure: @escaping (Result<T, Error>) -> Void,
    type: ObjCType.Type) -> ((Expected<ObjCType, TileRegionError.CoreErrorType>?) -> Void) where ObjCType: AnyObject {
    return coreAPIClosureAdapter(for: closure, type: type, concreteErrorType: TileRegionError.self)
}
