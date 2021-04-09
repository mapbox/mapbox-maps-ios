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
    ///         resource bundle.
    ///   - tileStorePath: Path to the `TileStore`; if `nil` the Tile Store will
    ///         not be used.
    ///   - loadTilePacksFromNetwork: Enables or disables tile store packs loading
    ///         from network; default is `true`. This value will be ignored if
    ///         the `tileStorePath` is `nil`.
    ///   - cacheSize: Size of the cache.
    public convenience init(accessToken: String,
                            baseUrl: String? = nil,
                            cachePath: String? = nil,
                            assetPath: String? = nil,
                            tileStorePath: String? = nil,
                            loadTilePacksFromNetwork: Bool = true,
                            cacheSize: UInt64 = (1024*1024*10)) {
        // TODO: Validate token
//      precondition(accessToken.count > 0)

        let cacheURL = ResourceOptions.cacheURLIncludingSubdirectory(useSubdirectory: true)
        let resolvedCachePath = cachePath == nil ? cacheURL?.path : cachePath
        self.init(__accessToken: accessToken,
                  baseURL: baseUrl,
                  cachePath: resolvedCachePath,
                  assetPath: assetPath ?? Bundle.main.resourceURL?.path,
                  tileStorePath: tileStorePath,
                  loadTilePacksFromNetwork: loadTilePacksFromNetwork.NSNumber,
                  cacheSize: NSNumber(value: cacheSize))
    }

    /// The size of the cache in bytes
    public var cacheSize: UInt64? {
        __cacheSize?.uint64Value
    }

// TODO:
//    public var loadTilePacksFromNetwork: Bool {
//        __loadTilePacksFromNetwork?.boolValue
//    }

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

    // :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? ResourceOptions else {
            return false
        }

        return
            (accessToken == other.accessToken) &&
            (baseURL == other.baseURL) &&
            (cachePath == other.cachePath) &&
            (assetPath == other.assetPath) &&
            (tileStorePath == other.tileStorePath) &&
            (loadTilePacksFromNetwork == other.loadTilePacksFromNetwork) &&
            (cacheSize == other.cacheSize)
    }
}
