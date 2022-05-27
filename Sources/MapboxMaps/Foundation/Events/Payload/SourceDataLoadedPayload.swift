import Foundation

public struct SourceDataLoadedPayload {
    public let id: String
    public let type: SourceDataType
    public let loaded: Bool?
    public var tileId: CanonicalTileID? {
        return decodedTileId?.tileID
    }

    internal let decodedTileId: DecodableCanonicalTileID?
}

extension SourceDataLoadedPayload: Decodable {
    enum CodingKeys: String, CodingKey {
        case id, type, loaded, decodedTileId = "tile-id"
    }
}

public enum SourceDataType: String, Decodable {
    case metadata, tile
}
