import Foundation

public struct ResourceRequestPayload: Decodable {
    public let dataSource: ResourceDataSource
    public let request: ResourceRequest
    public let response: ResourceResponse?
}

public enum ResourceDataSource: String, Decodable {
    case resourceLoader, network, database, asset, fileSystem
}

public struct ResourceRequest: Decodable {
    public enum Kind: String, Decodable {
        case unknown, style, source, tile, glyphs, spriteImage, spriteJSON, image
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
    public enum Source: String, Decodable {
        case network, cache, tileStore, localFile
    }

    public struct Error: Swift.Error, Decodable {
        // swiftlint:disable:next nesting
        public enum Reason: String, Decodable {
            case success
            case notFound
            case server
            case connection
            case rateLimit
            case inOfflineMode
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
