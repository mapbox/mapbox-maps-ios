import Foundation

public struct ResourceRequestPayload {
    public let dataSource: ResourceDataSource
    public let request: ResourceRequest
    public let response: ResourceResponse

}

extension ResourceRequestPayload: Decodable {
    enum CodingKeys: String, CodingKey {
        case dataSource = "data-source"
        case request, response
    }
}

public enum ResourceDataSource: String, Decodable {
    case resourceLoader = "resource-loader", network, database, asset, fileSystem = "file-system"
}

public struct ResourceRequest: Decodable {
    enum CodingKeys: String, CodingKey {
        case url, kind, priority, loadingMethod = "loading-method"
    }
    public enum Kind: String, Decodable {
        case unknown, style, source, tile, glyphs, spriteImage = "sprite-image", spriteJSON = "sprite-json", image
    }
    public enum Priority: String, Decodable {
        case regular, low
    }
    public enum LoadingMethod: String, Decodable {
        case cache, network
    }

    let url: String
    let kind: Kind
    let priority: Priority
    let loadingMethod: [LoadingMethod]
}

public struct ResourceResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case noContent = "no-content"
        case notModified = "not-modified"
        case mustRevalidate = "must-revalidate"
        case source, size, modified, expires, etag, error, cancelled
    }
    public enum Source: String, Decodable {
        case network, cache, tileStore = "tile-store", localFile = "local-file"
    }

    public struct Error: Swift.Error, Decodable {
        public enum Reason: String, Decodable {
            case success
            case notFound = "not-found"
            case server
            case connection
            case rateLimit = "rate-limit"
            case inOfflineMode = "in-offline-mode"
            case other
        }
        public let reason: Reason
        public let message: String
    }

    public let noContent: Bool
    public let notModified: Bool
    public let mustRevalidate: Bool
    public let source: Source
    public let size: Int
    public let modified: Date?
    public let expires: Date?
    public let etag: String?
    public let error: Error?
    public let cancelled: Bool?
}
