import XCTest

extension XCTestCase {
    func temporaryCacheDirectory() throws -> URL {
        let processId = ProcessInfo().processIdentifier
        var cacheDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        cacheDirectoryURL = cacheDirectoryURL.appendingPathComponent("mapbox/tests/\(processId)")
        cacheDirectoryURL = cacheDirectoryURL.appendingPathComponent(name.fileSystemSafe())

        try FileManager.default.createDirectory(at: cacheDirectoryURL,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
        cacheDirectoryURL.setTemporaryResourceValue(true, forKey: .isExcludedFromBackupKey)

        print("Created temp directory: \(cacheDirectoryURL)")

        return cacheDirectoryURL
    }
}
