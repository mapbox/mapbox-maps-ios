import Foundation

extension TileStore {
    /// Loads a new tile region or updates the existing one.
    ///
    /// - Parameters:
    ///   - id: The tile region identifier.
    ///   - loadOptions: The tile region load options.
    ///   - progress: Invoked multiple times to report progress of the loading
    ///         operation. Optional, default is nil.
    ///   - completion: Invoked only once upon success, failure, or cancelation
    ///         of the loading operation.
    ///
    /// - Returns: A `Cancelable` object to cancel the load request
    ///
    /// Creating of a new region requires providing both geometry and tileset
    /// descriptors to the given load options, otherwise the load request fails
    /// with RegionNotFound error.
    ///
    /// If a tile region with the given id already exists, it gets updated with
    /// the values provided to the given load options. The missing resources get
    /// loaded and the expired resources get updated.
    ///
    /// If there no values provided to the given load options, the existing tile
    /// region gets refreshed: the missing resources get loaded and the expired
    /// resources get updated.
    ///
    /// A failed load request can be reattempted with another loadTileRegion() call.
    ///
    /// If there is already a pending loading operation for the tile region with
    /// the given id, the pending loading operation will fail with an error of
    /// Canceled type.
    ///
    /// - Important:
    ///     The user-provided callbacks will be executed on a
    ///     TileStore-controlled worker thread; it is the responsibility of the
    ///     user to dispatch to a user-controlled thread.
    @discardableResult
    public func loadTileRegion(forId id: String,
                               loadOptions: TileRegionLoadOptions,
                               progress: TileRegionLoadProgressCallback? = nil,
                               completion: @escaping (Result<TileRegion, TileRegionError>) -> Void)
    -> Cancelable {
        if let progress = progress {
            return __loadTileRegion(forId: id,
                                    loadOptions: loadOptions,
                                    onProgress: progress,
                                    onFinished: coreAPIClosureAdapter(for: completion, type: TileRegion.self))
        }
        // Use overloaded version
        else {
            return __loadTileRegion(forId: id,
                                    loadOptions: loadOptions,
                                    onFinished: coreAPIClosureAdapter(for: completion, type: TileRegion.self))
        }
    }

    /// Checks if a tile region with the given id contains all tilesets from all
    /// of the given tileset descriptors.
    ///
    /// - Parameters:
    ///   - id: The tile region identifier.
    ///   - descriptors: The array of tileset descriptors.
    ///   - completion: The result callback.
    ///
    /// - Note:
    ///     The user-provided callbacks will be executed on a TileStore-controlled
    ///     worker thread; it is the responsibility of the user to dispatch to a
    ///     user-controlled thread.
    public func tileRegionContainsDescriptors(forId id: String,
                                              descriptors: [TilesetDescriptor],
                                              completion: @escaping (Result<Bool, TileRegionError>) -> Void) {
        __tileRegionContainsDescriptors(forId: id,
                                        descriptors: descriptors) { (expected: MBXExpected?) in
            let result: Result<Bool, TileRegionError>

            defer {
                completion(result)
            }

            guard let expected = expected as? MBXExpected<NSNumber, MapboxCommon.TileRegionError>  else {
                result = .failure(.other("No or invalid result returned"))
                return
            }

            if expected.isValue(), let value = expected.value?.boolValue {
                result = .success(value)
            } else if expected.isError(), let error = expected.error {
                result = .failure(TileRegionError(coreError: error))
            } else {
                result = .failure(.other("Unexpected value or error."))
            }
        }
    }

    /// Fetch the array of the existing tile regions.
    ///
    /// - Parameter completion: The result callback.
    ///
    /// - Note:
    ///     The user-provided callbacks will be executed on a TileStore-controlled
    ///     worker thread; it is the responsibility of the user to dispatch to a
    ///     user-controlled thread.
    public func allTileRegions(completion: @escaping (Result<[TileRegion], TileRegionError>) -> Void) {
        __getAllTileRegions(forCallback: coreAPIClosureAdapter(for: completion, type: NSArray.self))
    }

    /// Returns a tile region given its id.
    ///
    /// - Parameters:
    ///   - id: The tile region id.
    ///   - completion: The Result callback.
    ///
    /// - Note:
    ///     The user-provided callbacks will be executed on a TileStore-controlled
    ///     worker thread; it is the responsibility of the user to dispatch to a
    ///     user-controlled thread.
    public func tileRegion(forId id: String,
                           completion: @escaping (Result<TileRegion, TileRegionError>) -> Void) {
        __getTileRegion(forId: id,
                        callback: coreAPIClosureAdapter(for: completion, type: TileRegion.self))
    }

    /// Fetch a tile region's associated geometry
    ///
    /// The region associated geometry is provided by the client and it represents
    /// the area, which the tile region must cover. The actual regional geometry
    /// depends on the tiling scheme and might exceed the associated geometry.
    ///
    /// - Parameters:
    ///   - id: The tile region id.
    ///   - completion: The Result closure.
    ///
    /// - Note:
    ///     The user-provided callbacks will be executed on a TileStore-controlled
    ///     worker thread; it is the responsibility of the user to dispatch to a
    ///     user-controlled thread.
    public func tileRegionGeometry(forId id: String,
                                   completion: @escaping (Result<MBXGeometry, TileRegionError>) -> Void) {
        __getTileRegion(forId: id,
                        callback: coreAPIClosureAdapter(for: completion, type: MBXGeometry.self))
    }

    /// Fetch a tile region's associated metadata
    ///
    /// The region's associated metadata that a user previously set for this region.
    ///
    /// - Parameters:
    ///   - id: The tile region id.
    ///   - completion: The Result closure.
    public func tileRegionMetadata(forId id: String,
                                   completion: @escaping (Result<Any, TileRegionError>) -> Void) {
        __getTileRegionMetadata(forId: id,
                                callback: coreAPIClosureAdapter(for: completion, type: AnyObject.self))
    }
}
