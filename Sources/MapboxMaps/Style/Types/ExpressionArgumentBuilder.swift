import Foundation
import UIKit

@_functionBuilder
public struct ExpressionArgumentBuilder {

    public static func buildBlock(_ arguments: ExpressionArgumentConvertible...) -> [Expression.Argument] {

        var expressionArguments = [Expression.Argument]()

        for arg in arguments {
            expressionArguments = expressionArguments + arg.expressionArguments
        }

        return expressionArguments
    }
}

public protocol ExpressionArgumentConvertible {
    var expressionArguments: [Expression.Argument] { get }
}

extension Int: ExpressionArgumentConvertible {
    public var expressionArguments: [Expression.Argument] {
        return [.number(Double(self))]
    }
}

extension UInt: ExpressionArgumentConvertible {
    public var expressionArguments: [Expression.Argument] {
        return [.number(Double(self))]
    }
}

extension Double: ExpressionArgumentConvertible {
    public var expressionArguments: [Expression.Argument] {
        return [.number(Double(self))]
    }
}

extension String: ExpressionArgumentConvertible {
    public var expressionArguments: [Expression.Argument] {
        return [.string(self)]
    }
}

extension Bool: ExpressionArgumentConvertible {
    public var expressionArguments: [Expression.Argument] {
        return [.boolean(self)]
    }
}

extension Array: ExpressionArgumentConvertible where Element == Double {
    public var expressionArguments: [Expression.Argument] {
        return [.numberArray(self)]
    }
}

extension Expression: ExpressionArgumentConvertible {
    public var expressionArguments: [Expression.Argument] {
        return [.expression(self)]
    }
}

extension Dictionary: ExpressionArgumentConvertible where Key == Double,
                                                    Value: ExpressionArgumentConvertible {
    public var expressionArguments: [Expression.Argument] {
        var arguments = [Expression.Argument]()
        for key in Array(keys).sorted(by: <) {
            guard key >= 0, let value = self[key] else {
                fatalError("Invalid stops dictionary.")
            }
            arguments = arguments + key.expressionArguments + value.expressionArguments
        }
        return arguments
    }
}
