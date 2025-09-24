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

    /// Builds an optional expression argument.
    /// Enables support for optional values in Expression DSL, allowing `if let` and `guard let` constructs.
    ///
    /// - Parameter component: An optional expression argument convertible value
    /// - Returns: Array of expression arguments, empty if component is nil
    public static func buildOptional(_ component: ExpressionArgumentConvertible?) -> [Exp.Argument] {
        return component?.expressionArguments ?? []
    }

    /// Builds expression arguments for the first branch of a conditional.
    /// Enables support for `if/else` constructs in Expression DSL.
    ///
    /// - Parameter argument: Expression argument from the first conditional branch
    /// - Returns: Array of expression arguments
    public static func buildEither(first argument: ExpressionArgumentConvertible) -> [Exp.Argument] {
        return argument.expressionArguments
    }

    /// Builds expression arguments for the second branch of a conditional.
    /// Enables support for `if/else` constructs in Expression DSL.
    ///
    /// - Parameter argument: Expression argument from the second conditional branch
    /// - Returns: Array of expression arguments
    public static func buildEither(second argument: ExpressionArgumentConvertible) -> [Exp.Argument] {
        return argument.expressionArguments
    }

    /// Builds expression arguments from an array of convertible values.
    /// Enables support for `for` loops in Expression DSL, allowing iteration over collections
    /// to generate multiple expression arguments dynamically.
    ///
    /// - Parameter arguments: Array of expression argument convertible values
    /// - Returns: Flattened array of expression arguments
    public static func buildArray(_ arguments: [ExpressionArgumentConvertible]) -> [Exp.Argument] {
        return arguments.flatMap { $0.expressionArguments }
    }

    /// Builds expression arguments with limited availability checks.
    /// Enables support for `#available` constructs in Expression DSL.
    ///
    /// - Parameter argument: Expression argument from availability-guarded code
    /// - Returns: Array of expression arguments
    public static func buildLimitedAvailability(_ argument: ExpressionArgumentConvertible) -> [Exp.Argument] {
        return argument.expressionArguments
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
        } else if let argumentArray = self as? [Exp.Argument] {
            return argumentArray
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
