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
