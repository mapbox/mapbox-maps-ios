import Foundation
import UIKit
@_implementationOnly import MapboxCommon_Private

/// :nodoc:
/// This API enables the Expressions DSL syntax and is not designed to be called directly.
@resultBuilder
public struct ExpressionArgumentBuilder {
    /// :nodoc:
    public static func buildBlock(_ arguments: ExpressionArgumentConvertible...) -> [Expression.Argument] {
        return arguments.flatMap { $0.expressionArguments }
    }
}

/// :nodoc:
/// This API enables the Expressions DSL syntax and is not designed to be called directly.
public protocol ExpressionArgumentConvertible {
    /// :nodoc:
    var expressionArguments: [Expression.Argument] { get }
}

/// :nodoc:
/// This API enables the Expressions DSL syntax and is not designed to be called directly.
extension Int: ExpressionArgumentConvertible {
    public var expressionArguments: [Expression.Argument] {
        return [.number(Double(self))]
    }
}

/// :nodoc:
/// This API enables the Expressions DSL syntax and is not designed to be called directly.
extension UInt: ExpressionArgumentConvertible {
    public var expressionArguments: [Expression.Argument] {
        return [.number(Double(self))]
    }
}

/// :nodoc:
/// This API enables the Expressions DSL syntax and is not designed to be called directly.
extension Double: ExpressionArgumentConvertible {
    public var expressionArguments: [Expression.Argument] {
        return [.number(Double(self))]
    }
}

/// :nodoc:
/// This API enables the Expressions DSL syntax and is not designed to be called directly.
extension String: ExpressionArgumentConvertible {
    public var expressionArguments: [Expression.Argument] {
        return [.string(self)]
    }
}

/// :nodoc:
/// This API enables the Expressions DSL syntax and is not designed to be called directly.
extension Bool: ExpressionArgumentConvertible {
    public var expressionArguments: [Expression.Argument] {
        return [.boolean(self)]
    }
}

/// :nodoc:
/// This API enables the Expressions DSL syntax and is not designed to be called directly.
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

/// :nodoc:
/// This API enables the Expressions DSL syntax and is not designed to be called directly.
extension Expression: ExpressionArgumentConvertible {
    public var expressionArguments: [Expression.Argument] {
        return [.expression(self)]
    }
}

/// :nodoc:
/// This API enables the Expressions DSL syntax and is not designed to be called directly.
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

/// :nodoc:
/// This API enables the Expressions DSL syntax and is not designed to be called directly.
extension UIColor: ExpressionArgumentConvertible {
    public var expressionArguments: [Expression.Argument] {
        return [.string(StyleColor(self).rgbaString)]
    }
}

/// :nodoc:
/// This API enables the Expressions DSL syntax and is not designed to be called directly.
extension GeoJSONObject: ExpressionArgumentConvertible {
    public var expressionArguments: [Expression.Argument] {
        return [.geoJSONObject(self)]
    }
}
