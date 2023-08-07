import Foundation

final class ManifestCache<T> {

    private let manifestProvider: (URL) throws -> T
    private var cache = [URL: T]()

    init(manifestProvider: @escaping (URL) throws -> T) {
        self.manifestProvider = manifestProvider
    }

    func manifest(for url: URL) throws -> T {
        let manifest = try cache[url] ?? manifestProvider(url)
        cache[url] = manifest
        return manifest
    }
}
