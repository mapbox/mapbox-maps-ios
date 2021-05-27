import MapboxMaps

extension TileStore {
    internal static func fileURLForDirectory(for relativePath: String) throws -> URL {
        var cacheDirectoryURL = try FileManager.default.url(for: .applicationSupportDirectory,
                                                            in: .userDomainMask,
                                                            appropriateFor: nil,
                                                            create: true)

        cacheDirectoryURL = cacheDirectoryURL.appendingPathComponent(".mapbox")
        cacheDirectoryURL = cacheDirectoryURL.appendingPathComponent("maps")
        cacheDirectoryURL = cacheDirectoryURL.appendingPathComponent("tile-store")
        cacheDirectoryURL = cacheDirectoryURL.appendingPathComponent(relativePath)

        try FileManager.default.createDirectory(at: cacheDirectoryURL,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
        cacheDirectoryURL.setTemporaryResourceValue(true, forKey: .isExcludedFromBackupKey)
        return cacheDirectoryURL
    }

    internal static func removeDirectory(at fileURL: URL) throws {
        let fileManager = FileManager.default
        let resourceKeys = Set<URLResourceKey>([.isDirectoryKey])
        var fileURLs: [URL] = []

        guard let enumerator = fileManager.enumerator(at: fileURL, includingPropertiesForKeys: Array(resourceKeys)) else {
            return
        }

        for case let pathURL as URL in enumerator {
            let resourceValues = try? pathURL.resourceValues(forKeys: resourceKeys)

            if let isDirectory = resourceValues?.isDirectory, isDirectory {
                continue
            }

            fileURLs.append(pathURL)
        }

        // Remove files
        try fileURLs.forEach {
            try fileManager.removeItem(at: $0)
        }
        try fileManager.removeItem(at: fileURL)
    }
}
