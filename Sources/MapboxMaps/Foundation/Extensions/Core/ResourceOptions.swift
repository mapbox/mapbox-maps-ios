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
    ///   - tileStoreEnabled: Enables or disables tile store usage.
    ///   - loadTilePacksFromNetwork: Enables or disables tile store packs loading
    ///         from network; default is `false`. This setting is ignored if
    ///         `tileStoreEnabled` is `false`
    ///
    /// - Note:
    ///     If `loadTilePacksFromNetwork` is enabled, all tile requests are
    ///     instead converted to tile pack requests, i.e. the tile pack that
    ///     includes the request tile will be loaded, and the tile extracted
    ///     from it. With this option set, no individual tile requests will be
    ///     made.
    ///
    ///     If disabled, the implementation first checks if a tile pack is
    ///     already loaded. If that’s the case, the tile will be extracted and
    ///     returned. Otherwise, the implementation falls back to requesting the
    ///     individual tile and storing it in the ambient cache.
    ///
    ///     Whether or not `loadTilePacksFromNetwork` should be enabled depends
    ///     on a few factors:
    ///
    ///     If Predictive Caching is enabled, there’s a good chance that there
    ///     are already loaded tile packs in the vicinity of the user, so the
    ///     cost of `loadTilePacksFromNetwork` matters less.
    ///     And if users can’t pan freely, and the app is a navigation app,
    ///     `loadTilePacksFromNetwork` should be enabled to avoid downloading
    ///     duplicate content.
    ///
    ///     If users can pan freely, `loadTilePacksFromNetwork` should be disabled.
    ///     Otherwise, panning will download tile packs instead of using individual
    ///     tiles. Note that this means that we could first download an individual
    ///     tile, and then a tile pack that also includes this tile. The individual
    ///     tile in the ambient cache won’t be used as long as the up-to-date tile
    ///     pack exists in the cache.
    ///
    ///     Tile packs loading from network is disabled by default.
    public convenience init(accessToken: String,
                            baseUrl: String? = nil,
                            cachePath: String? = nil,
                            assetPath: String? = Bundle.main.resourceURL?.path,
                            cacheSize: UInt64 = (1024*1024*50),
                            tileStore: TileStore? = nil,
                            tileStoreEnabled: Bool = true,
                            loadTilePacksFromNetwork: Bool = false) {
//      precondition(accessToken.count > 0)

        // Update the TileStore with the access token from the ResourceOptions
        if tileStoreEnabled {
            let tileStore = tileStore ?? TileStore.getInstance()
            tileStore.setOptionForKey(TileStoreOptions.mapboxAccessToken, value: accessToken)
        }

        let cacheURL = ResourceOptions.cacheURLIncludingSubdirectory()
        let resolvedCachePath = cachePath == nil ? cacheURL?.path : cachePath
        self.init(__accessToken: accessToken,
                  baseURL: baseUrl,
                  cachePath: resolvedCachePath,
                  assetPath: assetPath,
                  cacheSize: NSNumber(value: cacheSize),
                  tileStore: tileStore,
                  tileStoreEnabled: tileStoreEnabled,
                  loadTilePacksFromNetwork: loadTilePacksFromNetwork
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
            && (isTileStoreEnabled == other.isTileStoreEnabled)
            && (isLoadTilePacksFromNetwork == other.isLoadTilePacksFromNetwork)
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
        hasher.combine(isTileStoreEnabled)
        hasher.combine(isLoadTilePacksFromNetwork)
        return hasher.finalize()
    }
}
