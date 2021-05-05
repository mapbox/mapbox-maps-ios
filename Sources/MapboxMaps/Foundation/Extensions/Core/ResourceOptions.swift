import Foundation

// MARK: - ResourceOptions

extension ResourceOptions {
    /// Initialize a `ResourceOptions`, used by both `MapView`s and `Snapshotter`s
    /// - Parameters:
    ///   - accessToken: Mapbox access token. You must provide a valid token.
    ///   - baseUrl: Base url for resource requests; default is `nil`
    ///   - cachePath: Path to database cache; default is `nil`, which will create
    ///         a path in the application's "support directory"
    ///   - assetPath: Path to assets; default is `nil`, which will use the application's
    ///         resource bundle. `assetPath` is expected to be path to a bundle.
    ///   - cacheSize: Size of the cache.
    ///   - tileStore: A tile store is only used if `tileStoreEnabled` is `true`,
    ///         otherwise this argument is ignored. If `nil` (and `tileStoreEnabled`
    ///         is `true`, the a default tile store will be created and used.
    ///   - tileStoreUsageMode: Enables or disables tile store usage.
    ///
    /// - Attention:
    ///     If `tileStoreUsageMode` is `.readonly` (the default): Tile loading
    ///     first checks the tile store when requesting a tile: If a tile pack is
    ///     already loaded, the tile will be extracted and returned. Otherwise,
    ///     the implementation falls back to requesting the individual tile and
    ///     storing it in the ambient cache.
    ///
    ///     If `tileStoreUsageMode` is `.readAndUpdate`: *All* tile requests are
    ///     converted to tile pack requests, i.e. the tile pack that includes the
    ///     requested tile will be loaded, and the tile extracted from it. In
    ///     this mode, no individual tile requests will be made.
    ///
    ///     This mode can be useful if the map trajectory is predefined and the
    ///     user cannot pan freely (e.g. navigation use cases), so that there is
    ///     a good chance tile packs are already loaded in the vicinity of the
    ///     user.
    ///
    ///     If users can pan freely, this mode is not recommended. Otherwise,
    ///     panning will download tile packs instead of using individual tiles.
    ///     Note that this means that we could first download an individual tile,
    ///     and then a tile pack that also includes this tile. The individual tile
    ///     in the ambient cache won’t be used as long as the up-to-date tile pack
    ///     exists in the cache.
    public convenience init(accessToken: String,
                            baseUrl: String? = nil,
                            cachePath: String? = nil,
                            assetPath: String? = Bundle.main.resourceURL?.path,
                            cacheSize: UInt64 = (1024*1024*50),
                            tileStore: TileStore? = nil,
                            tileStoreUsageMode: TileStoreUsageMode = .readOnly) {

        // Update the TileStore with the access token from the ResourceOptions
        if tileStoreUsageMode != .disabled {
            let tileStore = tileStore ?? TileStore.getInstance()
            tileStore.setOptionForKey(TileStoreOptions.mapboxAccessToken, value: accessToken)
        }

        let cacheURL = ResourceOptions.cacheURLIncludingSubdirectory()
        let resolvedCachePath = cachePath == nil ? cacheURL?.path : cachePath
        self.init(
            __accessToken: accessToken,
            baseURL: baseUrl,
            cachePath: resolvedCachePath,
            assetPath: assetPath,
            cacheSize: NSNumber(value: cacheSize),
            tileStore: tileStore,
            tileStoreUsageMode: tileStoreUsageMode
        )
    }

    /// The size of the cache in bytes
    public var cacheSize: UInt64? {
        __cacheSize?.uint64Value
    }

    private static func cacheURLIncludingSubdirectory() -> URL? {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else { return nil }

        var cacheDirectoryURL: URL
        do {
            cacheDirectoryURL = try FileManager.default.url(for: .applicationSupportDirectory,
                                                            in: .userDomainMask,
                                                            appropriateFor: nil,
                                                            create: true)
        } catch {
            return nil
        }

        cacheDirectoryURL = cacheDirectoryURL.appendingPathComponent(bundleIdentifier)
        cacheDirectoryURL.appendPathComponent(".mapbox")

        do {
            try FileManager.default.createDirectory(at: cacheDirectoryURL,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
        } catch {
            return nil
        }

        cacheDirectoryURL.setTemporaryResourceValue(true, forKey: .isExcludedFromBackupKey)

        return cacheDirectoryURL.appendingPathComponent("cache.db")
    }

    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {

        guard let other = object as? ResourceOptions else {
            return false
        }

        guard type(of: self) == type(of: other) else {
            return false
        }

        return (accessToken == other.accessToken)
            && ((baseURL == other.baseURL)
                    || (baseURL == nil)
                    || (other.baseURL == nil))
            && (cachePath == other.cachePath)
            && (assetPath == other.assetPath)
            && (cacheSize == other.cacheSize)
            && ((tileStore == other.tileStore)
                    || (tileStore == nil)
                    || (other.tileStore == nil))
            && (tileStoreUsageMode == other.tileStoreUsageMode)
    }

    /// :nodoc:
    open override var hash: Int {
        var hasher = Hasher()
        hasher.combine(accessToken)
        hasher.combine(baseURL)
        hasher.combine(cachePath)
        hasher.combine(assetPath)
        hasher.combine(cacheSize)
        hasher.combine(tileStore)
        hasher.combine(tileStoreUsageMode)
        return hasher.finalize()
    }
}
