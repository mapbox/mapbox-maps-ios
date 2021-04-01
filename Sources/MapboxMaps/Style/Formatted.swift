// MARK: Formatted Enum
public enum Formatted: Codable {
    case format([Element])
    case string(String)

    // MARK: Initializer

    /// Initializer to create an array of `Formatted` elements.
    /// - Parameter formattedDictionary: Dictionary that maps a substring to a set of format options.
    public init(with formattedDictionary: [String: FormatOptions]) {
        var formattedElements: [Element] = [.format]

        for element in formattedDictionary {
            formattedElements.append(.substring(.constant(element.key)))
            formattedElements.append(.formatOptions(element.value))
        }
        self = .format(formattedElements)
    }

    /// Initializer to create Formatted type from a `String`.
    /// - Parameter string: String representation of `Formatted` type.
    public init(with string: String) {
        self = .string(string)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let validFormattedElements = try? container.decode([Element].self) {
            self = .format(validFormattedElements)
        } else if let validString = try? container.decode(String.self) {
            self = .string(validString)
        } else {
            let context = DecodingError.Context(codingPath: decoder.codingPath,
                                            debugDescription: "Failed to decode Formatted")
            throw DecodingError.dataCorrupted(context)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .format(let elements):
            try container.encode(elements)
        case .string(let string):
            try container.encode(string)
        }
    }

    // MARK: Element Enum
    public enum Element: Codable {
        case format
        case step
        case substring(Value<String>)
        case formatOptions(FormatOptions)

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()

            if let validString = try? container.decode(String.self), validString == Expression.Operator.format.rawValue {
                self = .format
            } else if let validString = try? container.decode(String.self), validString == Expression.Operator.step.rawValue {
                self = .step
            } else if let validString = try? container.decode(Value<String>.self) {
                self = .substring(validString)
            } else if let validOptions = try? container.decode(FormatOptions.self) {
                self = .formatOptions(validOptions)
            } else {
                let context = DecodingError.Context(codingPath: decoder.codingPath,
                                                debugDescription: "Failed to decode FormattedElement")
                throw DecodingError.dataCorrupted(context)
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()

            switch self {
            case .format:
                try container.encode(Expression.Operator.format.rawValue)
            case .step:
                try container.encode(Expression.Operator.step.rawValue)
            case .substring(let substring):
                try container.encode(substring)
            case .formatOptions(let options):
                try container.encode(options)
            }
        }
    }
}
