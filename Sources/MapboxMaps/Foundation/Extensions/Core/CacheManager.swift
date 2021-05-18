import Foundation
//@_exported import MapboxCoreMaps
//@_implementationOnly import MapboxCoreMaps_Private


extension CacheManager {
    public func invalidateAmbientCache(_ completion: @escaping (Result<Void, Error>) -> Void) {
        invalidateAmbientCache(forCallback: coreAPIClosureAdapter(for: completion,
                                                                  concreteErrorType: MapError.self))
    }

    public func setMaximumAmbientCacheSize(_ size: UInt64, completion: @escaping (Result<Void, Error>) -> Void) {
        setMaximumAmbientCacheSizeForSize(size,
                                          callback: coreAPIClosureAdapter(for: completion,
                                                                          concreteErrorType: MapError.self))
    }

    public func clearAmbientCache(_ completion: @escaping (Result<Void, Error>) -> Void) {
        clearAmbientCache(forCallback: coreAPIClosureAdapter(for: completion,
                                                                  concreteErrorType: MapError.self))
    }

    public func setDatabasePath(_ path: String, completion: @escaping (Result<Void, Error>) -> Void) {
        setDatabasePathForDbPath(path,
                                 callback: coreAPIClosureAdapter(for: completion,
                                                                 concreteErrorType: MapError.self))
    }

    public func prefetchAmbientCache(for cacheArea: CacheAreaDefinition,
                                     completion: @escaping (Result<Void, Error>) -> Void) -> Cancelable {
        prefetchAmbientCache(forCacheArea: cacheArea,
                             callback: coreAPIClosureAdapter(for: completion,
                                                             concreteErrorType: MapError.self))
    }
}
