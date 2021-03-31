public typealias Formatted = [FormattedElement]

public enum FormattedElement: Codable {
    case format
    case substring(String)
    case formatOptions(FormatOptions)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let validString = try? container.decode(String.self), validString == Expression.Operator.format.rawValue {
            self = .format
            return
        }

        if let validString = try? container.decode(String.self) {
            self = .substring(validString)
            return
        }

        if let validOptions = try? container.decode(FormatOptions.self) {
            self = .formatOptions(validOptions)
            return
        }

        let context = DecodingError.Context(codingPath: decoder.codingPath,
                                            debugDescription: "Failed to decode Formatted")
        throw DecodingError.dataCorrupted(context)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .format:
            try container.encode(Expression.Operator.format.rawValue)
        case .substring(let substring):
            try container.encode(substring)
        case .formatOptions(let options):
            try container.encode(options)
        }
    }
}
