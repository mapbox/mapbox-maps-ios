import Foundation
import UIKit
@_implementationOnly import MapboxCommon_Private

#if swift(>=5.4)
@resultBuilder
public struct ExpressionArgumentBuilder {
    public static func buildBlock(_ arguments: ExpressionArgumentConvertible...) -> [Expression.Argument] {
        return arguments.flatMap { $0.expressionArguments }
    }
}
#else
@_functionBuilder
public struct ExpressionArgumentBuilder {
    public static func buildBlock(_ arguments: ExpressionArgumentConvertible...) -> [Expression.Argument] {
        return arguments.flatMap { $0.expressionArguments }
    }
}
#endif

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

extension Array: ExpressionArgumentConvertible {
    public var expressionArguments: [Expression.Argument] {
        if let validStringArray = self as? [String] {
            return [.stringArray(validStringArray)]
        } else if let validNumberArray = self as? [Double] {
            return [.numberArray(validNumberArray)]
        } else {
            Log.warning(forMessage: "Unsupported array provided to Expression. Only [String] and [Double] are supported.", category: "Expressions")
            return []
        }
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

extension UIColor: ExpressionArgumentConvertible {
    public var expressionArguments: [Expression.Argument] {
        return [.string(StyleColor(self).rgbaString)]
    }
}
