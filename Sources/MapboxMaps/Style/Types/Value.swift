import Foundation

public enum Value<T: Codable>: Codable {
    case constant(T)
    case expression(Expression)

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .constant(let constant):
            try container.encode(constant)
        case .expression(let expression):
            try container.encode(expression)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let decodedConstant = try? container.decode(T.self) {
            self = .constant(decodedConstant)
            return
        }

        if let decodedExpression = try? container.decode(Expression.self) {
            self = .expression(decodedExpression)
            return
        }

        let context = DecodingError.Context(codingPath: decoder.codingPath,
                                            debugDescription: "Failed to decode Value<\(T.self)>")
        throw DecodingError.dataCorrupted(context)
    }
}

extension Value: Equatable where T: Equatable {
}

extension Value: ExpressibleByFloatLiteral where T == FloatLiteralType {
    public init(floatLiteral value: FloatLiteralType) {
        self = .constant(value)
    }
}

extension Value: ExpressibleByStringLiteral, ExpressibleByExtendedGraphemeClusterLiteral, ExpressibleByUnicodeScalarLiteral where T == StringLiteralType {
    public init(stringLiteral value: StringLiteralType) {
        self = .constant(value)
    }

    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self = .constant(String(value))
    }

    public init(unicodeScalarLiteral value: StringLiteralType) {
        self = .constant(String(value))
    }
}

extension Value: ExpressibleByIntegerLiteral where T == IntegerLiteralType {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .constant(value)
    }
}

extension Value: ExpressibleByBooleanLiteral where T == BooleanLiteralType {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .constant(value)
    }
}
