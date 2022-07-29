import Foundation
@_implementationOnly import MapboxCommon_Private

extension TileStore {

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
                                    onFinished: tileStoreClosureAdapter(for: completion, type: TileRegion.self)).asCancelable()
        }
        // Use overloaded version
        else {
            return __loadTileRegion(forId: id,
                                    loadOptions: loadOptions,
                                    onFinished: tileStoreClosureAdapter(for: completion, type: TileRegion.self)).asCancelable()
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
}

private func tileStoreClosureAdapter<T, ObjCType>(
    for closure: @escaping (Result<T, Error>) -> Void,
    type: ObjCType.Type) -> ((Expected<ObjCType, TileRegionError.CoreErrorType>?) -> Void) where ObjCType: AnyObject {
    return coreAPIClosureAdapter(for: closure, type: type, concreteErrorType: TileRegionError.self)
}
