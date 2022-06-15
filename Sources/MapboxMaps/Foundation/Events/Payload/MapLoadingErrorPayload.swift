import Foundation
import MapboxCoreMaps

public struct MapLoadingErrorPayload {
    public let error: MapLoadingError
    public let sourceId: String?
    public var tileId: CanonicalTileID? {
        return decodedTileId?.tileID
    }

    internal let decodedTileId: DecodableCanonicalTileID?
}

extension MapLoadingErrorPayload: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
        case message
        case sourceId
        case tileId
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let type = try container.decode(String.self, forKey: .type)
        let message = try container.decode(String.self, forKey: .message)
        let sourceId = try container.decodeIfPresent(String.self, forKey: .sourceId)
        let decodedTileId = try container.decodeIfPresent(DecodableCanonicalTileID.self, forKey: .tileId)

        let error = MapLoadingError(type: type, message: message)

        self.init(error: error, sourceId: sourceId, decodedTileId: decodedTileId)
    }
}

internal struct DecodableCanonicalTileID: Decodable {
    enum CodingKeys: String, CodingKey {
        case x
        case y
        case z
    }

    let tileID: CanonicalTileID

    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let z = try container.decode(UInt8.self, forKey: .z)
        let x = try container.decode(UInt32.self, forKey: .x)
        let y = try container.decode(UInt32.self, forKey: .y)

        self.tileID = CanonicalTileID(z: z, x: x, y: y)
    }
}
