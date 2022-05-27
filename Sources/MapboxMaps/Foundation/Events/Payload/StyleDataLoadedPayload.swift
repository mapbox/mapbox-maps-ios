import Foundation

public struct StyleDataLoadedPayload: Decodable {
    public let type: StyleDataType
}

public enum StyleDataType: String, Decodable {
    case style, sprite, sources
}
