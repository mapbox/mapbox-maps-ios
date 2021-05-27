import Foundation

extension CacheManager {

    /// Construct a new cache manager.
    ///
    /// - Parameter options: Resource fetching options to be used by the cache manager.
    public convenience init(options: ResourceOptions) {
        self.init(options: MapboxCoreMaps.ResourceOptions(options))
    }

    /// Forces a revalidation of the tiles in the ambient cache and downloads
    /// a fresh version of the tiles from the tile server.
    ///
    /// This is more efficient than clearing the cache using `clearAmbientCache()`
    /// because tiles in the ambient cache are re-downloaded to remove outdated
    /// data from a device. It does not erase resources from the ambient cache
    /// or delete the database, which can be computationally expensive operations
    /// that may carry unintended side effects.
    ///
    /// - Parameter completion: Called once the request is complete or an error occurred.
    public func invalidateAmbientCache(_ completion: @escaping (Result<Void, Error>) -> Void) {
        invalidateAmbientCache(forCallback: coreAPIClosureAdapter(for: completion,
                                                                  concreteErrorType: MapError.self))
    }

    /// Sets the maximum size of the ambient cache in bytes.
    ///
    /// This call is potentially expensive because it will try to trim the data
    /// in case the database is larger than the size defined.
    /// Setting the size to 0 will effectively disable the cache.
    /// Preferably, this method should be called before using the database,
    /// otherwise the default maximum size will be used.
    ///
    /// - Parameters:
    ///   - size: The maximum size of the ambient cache in bytes.
    ///   - completion: Called once the request is complete or an error occurred.
    public func setMaximumAmbientCacheSize(_ size: UInt64, completion: @escaping (Result<Void, Error>) -> Void) {
        setMaximumAmbientCacheSizeForSize(size,
                                          callback: coreAPIClosureAdapter(for: completion,
                                                                          concreteErrorType: MapError.self))
    }

    /// Erase resources from the ambient cache, freeing storage space.
    ///
    /// This operation can be potentially slow Compared to \c invalidateAmbientCache()
    /// because it will trigger a VACUUM on SQLite, forcing the database to move
    /// pages on the filesystem.
    ///
    /// - Parameter completion: Called once the request is complete or an error occurred.
    public func clearAmbientCache(_ completion: @escaping (Result<Void, Error>) -> Void) {
        clearAmbientCache(forCallback: coreAPIClosureAdapter(for: completion,
                                                                  concreteErrorType: MapError.self))
    }

    /// Sets path of a database to be used by the ambient cache and invokes provided
    /// callback when a database path is set.
    ///
    /// - Parameters:
    ///   - path: The new database path
    ///   - completion: Callback to call once the request is completed or an error occurred.
    public func setDatabasePath(_ path: String, completion: @escaping (Result<Void, Error>) -> Void) {
        setDatabasePathForDbPath(path,
                                 callback: coreAPIClosureAdapter(for: completion,
                                                                 concreteErrorType: MapError.self))
    }

    /// Prefetches the resources for the from network and populates the ambient cache.
    ///
    /// - Parameters:
    ///   - cacheArea: Map area to pre-fetch and put into ambient cache
    ///   - completion: Callback to call once the request is completed or an error occurred.
    ///
    /// - Returns: Returns a Cancelable object to cancel the load request
    public func prefetchAmbientCache(for cacheArea: CacheAreaDefinition,
                                     completion: @escaping (Result<Void, Error>) -> Void) -> Cancelable {
        prefetchAmbientCache(forCacheArea: cacheArea,
                             callback: coreAPIClosureAdapter(for: completion,
                                                             concreteErrorType: MapError.self))
    }
}
