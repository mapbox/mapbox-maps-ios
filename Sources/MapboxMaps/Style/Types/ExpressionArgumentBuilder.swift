import Foundation
import UIKit
@_implementationOnly import MapboxCommon_Private

/// :nodoc:
/// This API enables the Expressions DSL syntax and is not designed to be called directly.
@resultBuilder
public struct ExpressionArgumentBuilder {
    /// :nodoc:
    public static func buildBlock(_ arguments: ExpressionArgumentConvertible...) -> [Exp.Argument] {
        return arguments.flatMap { $0.expressionArguments }
    }
}

/// :nodoc:
/// This API enables the Expressions DSL syntax and is not designed to be called directly.
public protocol ExpressionArgumentConvertible {
    /// :nodoc:
    var expressionArguments: [Exp.Argument] { get }
}

/// :nodoc:
/// This API enables the Expressions DSL syntax and is not designed to be called directly.
extension Int: ExpressionArgumentConvertible {
    public var expressionArguments: [Exp.Argument] {
        return [.number(Double(self))]
    }
}

/// :nodoc:
/// This API enables the Expressions DSL syntax and is not designed to be called directly.
extension UInt: ExpressionArgumentConvertible {
    public var expressionArguments: [Exp.Argument] {
        return [.number(Double(self))]
    }
}

/// :nodoc:
/// This API enables the Expressions DSL syntax and is not designed to be called directly.
extension Double: ExpressionArgumentConvertible {
    public var expressionArguments: [Exp.Argument] {
        return [.number(Double(self))]
    }
}

/// :nodoc:
/// This API enables the Expressions DSL syntax and is not designed to be called directly.
extension String: ExpressionArgumentConvertible {
    public var expressionArguments: [Exp.Argument] {
        return [.string(self)]
    }
}

/// :nodoc:
/// This API enables the Expressions DSL syntax and is not designed to be called directly.
extension Bool: ExpressionArgumentConvertible {
    public var expressionArguments: [Exp.Argument] {
        return [.boolean(self)]
    }
}

/// :nodoc:
/// This API enables the Expressions DSL syntax and is not designed to be called directly.
extension Array: ExpressionArgumentConvertible {
    public var expressionArguments: [Exp.Argument] {
        if let validStringArray = self as? [String] {
            return [.stringArray(validStringArray)]
        } else if let validNumberArray = self as? [Double] {
            return [.numberArray(validNumberArray)]
        } else {
            Log.warning("Unsupported array provided to Expression. Only [String] and [Double] are supported.", category: "Expressions")
            return []
        }
    }
}

/// :nodoc:
/// This API enables the Expressions DSL syntax and is not designed to be called directly.
extension Exp: ExpressionArgumentConvertible {
    public var expressionArguments: [Exp.Argument] {
        return [.expression(self)]
    }
}

/// :nodoc:
/// This API enables the Expressions DSL syntax and is not designed to be called directly.
extension Dictionary: ExpressionArgumentConvertible {
    public var expressionArguments: [Exp.Argument] {
        if let stopsDictionary = self as? [Double: ExpressionArgumentConvertible] {
            var arguments = [Exp.Argument]()
            for key in Array(stopsDictionary.keys).sorted(by: <) {
                guard key >= 0, let value = stopsDictionary[key] else {
                    fatalError("Invalid stops dictionary.")
                }
                arguments = arguments + key.expressionArguments + value.expressionArguments
            }
            return arguments
        } else if let dict = self as? [String: ExpressionArgumentConvertible] {
            return [.dictionary(dict.compactMapValues(\.expressionArguments.first))]
        }

        return []
    }
}

/// :nodoc:
/// This API enables the Expressions DSL syntax and is not designed to be called directly.
extension UIColor: ExpressionArgumentConvertible {
    public var expressionArguments: [Exp.Argument] {
        return [.string(StyleColor(self).rawValue)]
    }
}

/// :nodoc:
/// This API enables the Expressions DSL syntax and is not designed to be called directly.
extension GeoJSONObject: ExpressionArgumentConvertible {
    public var expressionArguments: [Exp.Argument] {
        return [.geoJSONObject(self)]
    }
}
