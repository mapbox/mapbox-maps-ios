import Foundation

/// An ``Expression`` defines a formula for computing the value of any layout property, paint property,
/// or filter within a map style. Expressions allow you to style data with multiple feature
/// properties at once, apply conditional logic, and manipulate data with mathematical, logical, and
/// string operators. This allows for sophisticated runtime styling.
@available(*, renamed: "Exp", message: "Use Exp type instead to avoid name clash with Foundation.Expression.")
public typealias Expression = Exp

/// An ``Exp``(expression) defines a formula for computing the value of any layout property, paint property,
/// or filter within a map style. Expressions allow you to style data with multiple feature
/// properties at once, apply conditional logic, and manipulate data with mathematical, logical, and
/// string operators. This allows for sophisticated runtime styling.
public struct Exp: Codable, CustomStringConvertible, Equatable, Sendable {

    /// The individual elements of the expression in an array
    internal var elements: [Element]

    /// The operator of this expression
    /// If the expression starts with an argument instead of an operator
    /// then return the first operator of a contained expression if available.
    public var `operator`: Operator {
        switch elements.first {
        case .operator(let op): return op
        case .argument(.expression(let expression)): return expression.operator
        default:
            fatalError("First element of the expression is not an operator nor another expression.")
        }
    }

    /// The arguments contained in this expression
    public var arguments: [Argument] {
        /// If the expression starts with an argument instead of an operator, return all of the arguments
        if case .argument = elements.first {
            return elements.map(returnArgument)
        }
        return elements.dropFirst().map(returnArgument)
    }

    /// Check if element is argument and return, fatalError if not
    internal func returnArgument(element: Element) -> Argument {
        guard case Element.argument(let arg) = element else {
            fatalError("All elements after the first element in the expression must be arguments.")
        }
        return arg
    }

    public init(_ op: Operator,
                @ExpressionArgumentBuilder content: () -> [Exp.Argument]) {
        self.init(operator: op, arguments: content())
    }

    /// Create an operator-only expression.
    public init(_ op: Operator) {
        self.init(operator: op, arguments: [])
    }

    /// Initialize an expression with an operator and basic Swift types like Double, String, or even UIColor
    public init(_ operator: Operator, _ arguments: ExpressionArgumentConvertible...) {
        self.elements = [.operator(`operator`)] + arguments.flatMap { $0.expressionArguments }.map(Element.argument)
    }

    /// Initialize an expression with an operator and arguments
    public init(operator op: Operator, arguments: [Argument]) {
        self.elements = [.operator(op)] + arguments.map { Element.argument($0) }
    }

    /// Initialize an expression with only arguments
    public init(@ExpressionArgumentBuilder content: () -> [Exp.Argument]) {
        self.init(arguments: content())
    }

    /// Initialize an expression with only arguments
    public init(arguments: [Argument]) {
        self.elements = arguments.map { Element.argument($0) }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()

        for element in elements {
            try container.encode(element)
        }
    }

    public var description: String {
        return "[" + elements.map { "\($0)" }.joined(separator: ", ") + "]"
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        elements = []
        guard !container.isAtEnd else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Expression requires an operator or argument, but neither was present.")
        }
        // First element can be an operator or argument
        if let decodedOperator = try? container.decode(Operator.self) {
            elements.append(.operator(decodedOperator))
        }
        // Subsequent elements must be arguments
        while !container.isAtEnd {
            let decodedArgument = try container.decode(Argument.self)
            elements.append(.argument(decodedArgument))
        }
    }

    /**
     An `ExpressionElement` can be either a `op` (associated with a `String`)
     OR an `argument` (associated with an `ExpressionArgument`)
     */
    public indirect enum Element: Codable, CustomStringConvertible, Equatable, Sendable {

        case `operator`(Operator)
        case argument(Argument)

        public var description: String {
            switch self {
            case .operator(let op):
                return op.rawValue
            case .argument(let arg):
                return "\(arg)"
            }
        }

        public static func == (lhs: Exp.Element, rhs: Exp.Element) -> Bool {
            switch (lhs, rhs) {
            case (.operator(let lhsOp), .operator(let rhsOp)):
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
            case .operator(let op):
                try container.encode(op)
            case .argument(let argument):
                try container.encode(argument)
            }
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()

            if let validOp = try? container.decode(Operator.self) {
                self = .operator(validOp)
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

    /// An `Exp.Argument` is either a literal (associated with a double, string, boolean, or null value)
    /// or another `Exp`
    public indirect enum Argument: Codable, CustomStringConvertible, Equatable, Sendable {

        case number(Double)
        case string(String)
        case boolean(Bool)
        case numberArray([Double])
        case stringArray([String])
        case dictionary([String: Argument])
        case option(Option)
        case geoJSONObject(GeoJSONObject)
        case null
        case expression(Exp)

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
            case .geoJSONObject(let object):
                return "\(object)"
            case .numberArray(let array):
                return "\(array)"
            case .stringArray(let stringArray):
                return "\(stringArray)"
            case .dictionary(let dictionary):
                return "\(dictionary)"
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
            case .geoJSONObject(let object):
                try container.encode(object)
            case .null:
                try container.encodeNil()
            case .numberArray(let array):
                try container.encode(array)
            case .stringArray(let stringArray):
                try container.encode(stringArray)
            case .dictionary(let dictionary):
                try container.encode(dictionary)
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
            } else if let object = try? container.decode(GeoJSONObject.self) {
                self = .geoJSONObject(object)
            } else if let validExpression = try? container.decode(Exp.self) {
                self = .expression(validExpression)
            } else if let validOption = try? container.decode(Option.self) {
                self = .option(validOption)
            } else if let validArray = try? container.decode([Double].self) {
                self = .numberArray(validArray)
            } else if let validStringArray = try? container.decode([String].self) {
                self = .stringArray(validStringArray)
            } else if let dict = try? container.decode([String: Argument].self) {
                self = dict.isEmpty ? .null : .dictionary(dict)
            } else {
                let context = DecodingError.Context(codingPath: decoder.codingPath,
                                                    debugDescription: "Failed to decode ExpressionArgument")
                throw DecodingError.dataCorrupted(context)
            }
        }
    }
}

extension Exp {
    var asCore: Any? {
        let encoder = DictionaryEncoder()
        encoder.shouldEncodeNilValues = false
        return try? encoder.encodeAny(self)
    }
}
