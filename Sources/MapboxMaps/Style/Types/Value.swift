import Foundation

public enum Value<T: Codable>: Codable {
    case constant(T)
    case expression(Exp)

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

        if let decodedExpression = try? container.decode(Exp.self) {
            self = .expression(decodedExpression)
            return
        }

        let context = DecodingError.Context(codingPath: decoder.codingPath,
                                            debugDescription: "Failed to decode Value<\(T.self)>")
        throw DecodingError.dataCorrupted(context)
    }
}

extension Value: Equatable where T: Equatable {}
extension Value: Sendable where T: Sendable {}

extension Value {
    internal init(constant: T) {
        self = .constant(constant)
    }

    internal var asConstant: T? {
        switch self {
        case let .constant(c):
            return c
        case .expression:
            return nil
        }
    }
}
