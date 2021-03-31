public enum Formatted: Codable {
    case format([Element])
    case string(String)

    public init(with formattedDictionary: [String: FormatOptions]) {
        var formattedElements: [Element] = [.format]

        for element in formattedDictionary {
            formattedElements.append(.substring(.constant(element.key)))
            formattedElements.append(.formatOptions(element.value))
        }
        self = .format(formattedElements)
    }

    public init(with string: String) {
        self = .string(string)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let validFormattedElements = try? container.decode([Element].self) {
            self = .format(validFormattedElements)
            return
        } else if let validString = try? container.decode(String.self){
            self = .string(validString)
            return
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

    public enum Element: Codable {
        case format
        case substring(Value<String>)
        case formatOptions(FormatOptions)

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()

            if let validString = try? container.decode(String.self), validString == Expression.Operator.format.rawValue {
                self = .format
                return
            } else if let validString = try? container.decode(Value<String>.self) {
                self = .substring(validString)
                return
            } else if let validOptions = try? container.decode(FormatOptions.self) {
                self = .formatOptions(validOptions)
                return
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
            case .substring(let substring):
                try container.encode(substring)
            case .formatOptions(let options):
                try container.encode(options)
            }
        }
    }
}
