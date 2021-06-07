import XCTest

extension XCTestCase {

    internal func temporaryCacheDirectory() throws -> URL {

        let processId = ProcessInfo().processIdentifier
        var cacheDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        cacheDirectoryURL = cacheDirectoryURL.appendingPathComponent("mapbox/tests/\(processId)")
        cacheDirectoryURL = cacheDirectoryURL.appendingPathComponent(name.fileSystemSafeString())

        try FileManager.default.createDirectory(at: cacheDirectoryURL,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
        cacheDirectoryURL.setTemporaryResourceValue(true, forKey: .isExcludedFromBackupKey)

        print("Created temp directory: \(cacheDirectoryURL)")

        return cacheDirectoryURL
    }

    internal func removeFilesInDirectoryTree(at fileURL: URL) throws {
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

        //try fileManager.removeItem(at: fileURL)
    }
}
