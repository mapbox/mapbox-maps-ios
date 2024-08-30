import Foundation

public enum PromoteId: Equatable, Codable, Sendable {
    case string(String)
    case object([String: String])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let decodedString = try? container.decode(String.self) {
            self = .string(decodedString)
            return

        } else if let decodedObject = try? container.decode([String: String].self) {
            self = .object(decodedObject)
            return
        }

        let context = DecodingError.Context(codingPath: decoder.codingPath,
                                            debugDescription: "Failed to decode PromoteId")
        throw DecodingError.dataCorrupted(context)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .string(let string):
            try container.encode(string)
        case .object(let object):
            try container.encode(object)
        }
    }
}
