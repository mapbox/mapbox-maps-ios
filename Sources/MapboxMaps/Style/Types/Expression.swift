import Foundation

public typealias Exp = Expression

public struct Expression: Codable, CustomStringConvertible, Equatable {

    /// The individual elements of the expression in an array
    public var elements: [Element]

    // swiftlint:disable identifier_name
    public init(_ op: Expression.Operator,
                @ExpressionBuilder content: () -> Expression = { Expression(with: [.argument(.null)])}) {
        var elements = content().elements

        if elements.count == 1 && elements[0] == .argument(.null) {
            elements = []
        }

        elements.insert(.op(op), at: 0)
        self.init(with: elements)
    }

    /// Attempts to create an Expression from a jsonObject.
    public init?(from jsonObject: Any) {
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
            let exp = try JSONDecoder().decode(Expression.self, from: data)
            self = exp
        } catch {
            return nil
        }
    }

    /// Returns a jsonObject representation of this expression if serialization is successful,  throws otherwise
    public func jsonObject() throws -> Any {
        let data = try JSONEncoder().encode(self)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        return jsonObject
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()

        for element in elements {
            try container.encode(element)
        }
    }

    public init(with elements: [Element]) {
        self.elements = elements
    }

    public var description: String {
        return "[" + elements.map { "\($0)" }.joined(separator: ", ") + "]"
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        elements = []
        while !container.isAtEnd {
            let decodedElement = try container.decode(Element.self)
            elements.append(decodedElement)
        }
    }

    /**
     An `ExpressionElement` can be either a `op` (associated with a `String`)
     OR an `argument` (associated with an `ExpressionArgument`)
     */
    public indirect enum Element: Codable, CustomStringConvertible, Equatable {

        case op(Operator)
        case argument(Argument)

        public var description: String {
            switch self {
            case .op(let op):
                return op.rawValue
            case .argument(let arg):
                return "\(arg)"
            }
        }

        public static func == (lhs: Expression.Element, rhs: Expression.Element) -> Bool {
            switch (lhs, rhs) {
            case (.op(let lhsOp), .op(let rhsOp)):
                return lhsOp.rawValue == rhsOp.rawValue
            case (.argument(let lhsArg), .argument(let rhsArg)):
                return lhsArg == rhsArg
            default:
                return false
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()

            switch self {
            case .op(let op):
                try container.encode(op)
            case .argument(let argument):
                try container.encode(argument)
            }
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()

            if let validOp = try? container.decode(Operator.self) {
                self = .op(validOp)
                return
            }

            if let validArg = try? container.decode(Argument.self) {
                self = .argument(validArg)
                return
            }

            let context = DecodingError.Context(codingPath: decoder.codingPath,
                                                debugDescription: "Failed to decode ExpressionElement")
            throw DecodingError.dataCorrupted(context)
        }
    }

    /// An `ExpressionArgument` is either a literal (associated with a double, string, boolean, or null value)
    /// or another `Expression`
    public indirect enum Argument: Codable, CustomStringConvertible, Equatable {

        case number(Double)
        case string(String)
        case boolean(Bool)
        case array([Double])
        case option(Option)
        case null
        case expression(Expression)

        public var description: String {
            switch self {
            case .number(let number):
                return "\(number)"
            case .string(let string):
                return string
            case .boolean(let bool):
                return "\(bool)"
            case .null:
                return "<null>"
            case .expression(let exp):
                return "\(exp)"
            case .option(let option):
                return "\(option)"
            case .array(let array):
                return "\(array)"
            }
        }

        public static func == (lhs: Expression.Argument, rhs: Expression.Argument) -> Bool {
            switch (lhs, rhs) {
            case (.number(let lhsNumber), .number(let rhsNumber)):
                return lhsNumber == rhsNumber
            case (.string(let lhsString), .string(let rhsString)):
                return lhsString == rhsString
            case (.boolean(let lhsBool), .boolean(let rhsBool)):
                return lhsBool == rhsBool
            case (.option(let lhsOption), .option(let rhsOption)):
                return lhsOption == rhsOption
            case (.null, .null):
                return true
            case (.expression(let lhsExpression), .expression(let rhsExpression)):
                return lhsExpression == rhsExpression
            case (.array(let lhsArray), .array(let rhsArray)):
                return lhsArray == rhsArray
            default:
                return false
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()

            switch self {
            case .expression(let expression):
                try container.encode(expression)
            case .number(let number):
                try container.encode(number)
            case .string(let string):
                try container.encode(string)
            case .boolean(let boolean):
                try container.encode(boolean)
            case .option(let option):
                try container.encode(option)
            case .null:
                try container.encodeNil()
            case .array(let array):
                try container.encode(array)
            }
        }

        public init(from decoder: Decoder) throws {

            let container = try decoder.singleValueContainer()

            if let validString = try? container.decode(String.self) {
                self = .string(validString)
            } else if let validNumber = try? container.decode(Double.self) {
                self = .number(validNumber)
            } else if let validBoolean = try? container.decode(Bool.self) {
                self = .boolean(validBoolean)
            } else if let validExpression = try? container.decode(Expression.self) {
                self = .expression(validExpression)
            } else if let validOption = try? container.decode(Option.self) {
                self = .option(validOption)
            } else if let validArray = try? container.decode([Double].self) {
                self = .array(validArray)
            } else if let dict = try? container.decode([String: String].self), dict.isEmpty {
                self = .null
            } else {
                let context = DecodingError.Context(codingPath: decoder.codingPath,
                                                debugDescription: "Failed to decode ExpressionArgument")
                throw DecodingError.dataCorrupted(context)
            }
        }
    }
}
