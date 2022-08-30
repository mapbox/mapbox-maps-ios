import Foundation

public struct ResourceRequestPayload: Decodable {
    public let dataSource: ResourceDataSource
    public let request: ResourceRequest
    public let response: ResourceResponse?
}

public enum ResourceDataSource: String, Decodable {
    case resourceLoader = "resource-loader"
    case network
    case database
    case asset
    case fileSystem = "file-system"
}

public struct ResourceRequest: Decodable {
    public enum Kind: String, Decodable {
        case unknown
        case style
        case source
        case tile
        case glyphs
        case spriteImage = "sprite-image"
        case spriteJSON = "sprite-json"
        case image
    }
    public enum Priority: String, Decodable {
        case regular
        case low
    }
    public enum LoadingMethod: String, Decodable {
        case cache
        case network
    }

    public let url: String
    public let kind: Kind
    public let priority: Priority
    public let loadingMethod: [LoadingMethod]
}

public struct ResourceResponse: Decodable {
    public enum Source: String, Decodable {
        case network
        case cache
        case tileStore = "tile-store"
        case localFile = "local-file"
    }

    public struct Error: Swift.Error, Decodable {
        // swiftlint:disable:next nesting
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
