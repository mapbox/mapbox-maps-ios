import Foundation

// MARK: - ResourceOptions

public extension ResourceOptions {
    convenience init(accessToken: String,
                     baseUrl: String? = nil,
                     cachePath: String? = nil,
                     assetPath: String? = nil,
                     tileStorePath: String? = nil,
                     loadTilePacksFromNetwork: NSNumber? = nil,
                     cacheSize: UInt64 = (1024*1024*10)) {

        let cacheURL = ResourceOptions.cacheURLIncludingSubdirectory(useSubdirectory: true)
        let resolvedCachePath = cachePath == nil ? cacheURL?.path : cachePath
        self.init(__accessToken: accessToken,
                  baseURL: baseUrl,
                  cachePath: resolvedCachePath,
                  assetPath: assetPath ?? Bundle.main.resourceURL?.path,
                  tileStorePath: tileStorePath,
                  loadTilePacksFromNetwork: loadTilePacksFromNetwork,
                  cacheSize: NSNumber(value: cacheSize))
    }

    var cacheSize: UInt64? {
        __cacheSize?.uint64Value
    }

    static func cacheURLIncludingSubdirectory(useSubdirectory: Bool) -> URL? {
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

            if useSubdirectory {
                cacheDirectoryURL.appendPathComponent(".mapbox")
            }

            do {
                try FileManager.default.createDirectory(at: cacheDirectoryURL,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            } catch {
                return nil
            }

            if useSubdirectory {
                cacheDirectoryURL.setTemporaryResourceValue(true, forKey: .isExcludedFromBackupKey)
            }

            return cacheDirectoryURL.appendingPathComponent("cache.db")
        }

}
