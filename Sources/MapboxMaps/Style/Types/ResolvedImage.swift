import Foundation

// Represents the resolved image type used in MapboxCoreMaps
// When assigning a value to a layer, use the `name` case
// When retrieving a value from a layer, the `data` case is populated
public enum ResolvedImage: Codable, Sendable {

    /// Use to assign a new resolved image with a name
    case name(String)

    /// A decode layer contains information in the form of `ResolvedImageData`.
    case data(ResolvedImageData)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let decodedData = try? container.decode(ResolvedImageData.self) {
            self = .data(decodedData)
            return
        }

        if let decodedString = try? container.decode(String.self) {
            self = .name(decodedString)
            return
        }

        let context = DecodingError.Context(codingPath: decoder.codingPath,
                                            debugDescription: "Failed to decode ResolvedImage")
        throw DecodingError.dataCorrupted(context)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .data(let data):
            try container.encode(data)
        case .name(let string):
            try container.encode(string)
        }
    }
}

public struct ResolvedImageData: Codable, Equatable, Sendable {
    public var available: Bool
    public var name: String
}

extension ResolvedImage: Equatable {
    public static func == (lhs: ResolvedImage, rhs: ResolvedImage) -> Bool {
        switch (lhs, rhs) {
        case (let .name(lhsName), let .name(rhsName)):
            return lhsName == rhsName
        case (let .data(lhsData), let .data(rhsData)):
            return lhsData == rhsData
        default:
            return false
        }
    }
}
