import Foundation
import UIKit

@_functionBuilder
public struct ExpressionBuilder {

    public static func buildBlock(_ arguments: ExpressionArgumentConvertible...) -> Expression {

        var expressionElements = [Expression.Element]()

        for arg in arguments {
            expressionElements = expressionElements + arg.expressionElements
        }

        return Expression(elements: expressionElements)
    }
}

public protocol ExpressionArgumentConvertible {
    var expressionElements: [Expression.Element] { get }
}

extension Int: ExpressionArgumentConvertible {
    public var expressionElements: [Expression.Element] {
        return [.argument(.number(Double(self)))]
    }
}

extension UInt: ExpressionArgumentConvertible {
    public var expressionElements: [Expression.Element] {
        return [.argument(.number(Double(self)))]
    }
}

extension Double: ExpressionArgumentConvertible {
    public var expressionElements: [Expression.Element] {
        return [.argument(.number(Double(self)))]
    }
}

extension String: ExpressionArgumentConvertible {
    public var expressionElements: [Expression.Element] {
        return [.argument(.string(self))]
    }
}

extension Bool: ExpressionArgumentConvertible {
    public var expressionElements: [Expression.Element] {
        return [.argument(.boolean(self))]
    }
}

extension Array: ExpressionArgumentConvertible where Element == Double {
    public var expressionElements: [Expression.Element] {
        return [.argument(.numberArray(self))]
    }
}

extension Expression.Element: ExpressionArgumentConvertible {
    public var expressionElements: [Expression.Element] {
        return [self]
    }
}

extension Expression: ExpressionArgumentConvertible {
    public var expressionElements: [Expression.Element] {
        return [.argument(.expression(self))]
    }
}

extension Expression.Argument: ExpressionArgumentConvertible {
    public var expressionElements: [Expression.Element] {
        return [.argument(self)]
    }
}

extension Expression.Operator: ExpressionArgumentConvertible {
    public var expressionElements: [Expression.Element] {
        return [.operator(self)]
    }
}

extension Dictionary: ExpressionArgumentConvertible where Key == Double,
                                                    Value: ExpressionArgumentConvertible {
    public var expressionElements: [Expression.Element] {
        var elements = [Expression.Element]()
        for key in Array(keys).sorted(by: <) {
            guard key >= 0, let value = self[key] else {
                assertionFailure("Invalid stops dictionary with negative key")
                return []
            }
            elements = elements + key.expressionElements + value.expressionElements
        }
        return elements
    }
}
