import Foundation

public struct SourceDataLoadedPayload: Decodable {
    public let id: String
    public let type: SourceDataType
    public let loaded: Bool?
    public var tileId: CanonicalTileID? {
        return decodedTileId?.tileID
    }
    public let dataId: String?

    internal let decodedTileId: DecodableCanonicalTileID?
}

public enum SourceDataType: String, Decodable {
    case metadata
    case tile
}
