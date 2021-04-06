import Foundation

// MARK: - ResourceOptions

extension ResourceOptions {
    /// Intializer for `ResourceOptions`
    /// - Parameters:
    ///   - accessToken: Your mapbox access API token.
    ///   - baseUrl: The base URL.
    ///   - cachePath: The path to the cache.
    ///   - assetPath: The path to the assets.
    ///   - tileStorePath: The path to the tile store.
    ///   - loadTilePacksFromNetwork: Detemines if tiles pack should or should not be avoided from the network.
    ///   - cacheSize: The size of the cahce.
    public convenience init(accessToken: String,
                            baseUrl: String? = nil,
                            cachePath: String? = nil,
                            assetPath: String? = nil,
                            tileStorePath: String? = nil,
                            loadTilePacksFromNetwork: NSNumber? = nil,
                            cacheSize: UInt64 = (1024*1024*10)) {

        let cacheURL = ResourceOptions.cacheURLIncludingSubdirectory()
        let resolvedCachePath = cachePath == nil ? cacheURL?.path : cachePath
        self.init(__accessToken: accessToken,
                  baseURL: baseUrl,
                  cachePath: resolvedCachePath,
                  assetPath: assetPath ?? Bundle.main.resourceURL?.path,
                  tileStorePath: tileStorePath,
                  loadTilePacksFromNetwork: loadTilePacksFromNetwork,
                  cacheSize: NSNumber(value: cacheSize))
    }

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
}
